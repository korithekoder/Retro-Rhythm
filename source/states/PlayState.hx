package states;

import flixel.FlxState;
import backend.util.AssetUtil;
import backend.data.ClientPrefs;
import backend.data.Constants;
import backend.util.CacheUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.gameplay.Note;
import objects.gameplay.NoteLane;
import states.menus.MainMenuState;

class PlayState extends FlxState {

	public static var noteHitsGroup:FlxTypedGroup<FlxText>;
	public static var statsGroup:FlxTypedGroup<FlxText>;
	public static var noteLanesGroup:FlxTypedGroup<NoteLane>;

	public static var bgCamera:FlxCamera;
	public static var gameplayCamera:FlxCamera;
	public static var uiCamera:FlxCamera;

	public static var noteHitTypePopup:FlxText;
	public static var comboPopup:FlxText;

	public static var firstNotes:Map<Int, Note> = [
		0 => null,
		1 => null,
		2 => null,
		3 => null
	];

	var songId:String;
	var songData:Dynamic;
	var songNotes:Array<Dynamic>;
	var songMetadata:Dynamic;

	var songComposer:String;
	var songCharter:String;
	var songName:String;

	var songSpeed:Float;
	var songBPM:Int;
	var songCamZoomIntensity:Float;
	var songLength:Float;

	var accuracyText:FlxText;
	var comboText:FlxText;
	var scoreText:FlxText;

	var beatDuration:Float;
	var beatDurationMS:Float;
	var beatCounter:Int = 0;
	var lastBeat:Int = -1;

	var currentNoteIdx:Int = 0;
	var noteSpeed:Float;
	var notesGroup:FlxTypedGroup<Note>;

	var noteHitsBg:FlxSprite;
	var strumline:FlxSprite;

	var bgSprite:FlxSprite;

	public function new(songId:String) {
		super();

		this.songId = songId;
		this.songData = AssetUtil.getJsonData(PathUtil.ofChart(songId), {});

		this.songNotes = AssetUtil.getDynamicField(this.songData, 'notes', []);

		this.songMetadata = AssetUtil.getDynamicField(this.songData, 'metadata', Constants.DEFAULT_METADATA);
		this.songComposer = AssetUtil.getDynamicField(this.songMetadata, 'composer', 'Unknown');
		this.songCharter = AssetUtil.getDynamicField(this.songMetadata, 'charter', 'Unknown');
		this.songName = AssetUtil.getDynamicField(this.songMetadata, 'name', 'Unknown');

		this.songSpeed = AssetUtil.getDynamicField(this.songData, 'speed', 1);
		this.songBPM = AssetUtil.getDynamicField(this.songData, 'songBPM', 60);
		this.songCamZoomIntensity = AssetUtil.getDynamicField(this.songData, 'camzoom', 2);

		this.beatDuration = 60 / this.songBPM;
		this.beatDurationMS = 60000 / this.songBPM;

		this.noteSpeed = (FlxG.height / this.beatDuration) * this.songSpeed;
	}
	
	override public function create() {
		super.create();

		CacheUtil.canPlayMenuMusic = true;
		CacheUtil.realHitPoints = 0;
		CacheUtil.totalHitPoints = 0;
		CacheUtil.combo = 0;
		GeneralUtil.resetHitsArray();

		bgCamera = new FlxCamera();
		gameplayCamera = new FlxCamera();
		gameplayCamera.bgColor.alpha = 0;
		uiCamera = new FlxCamera();
		uiCamera.bgColor.alpha = 0;

		FlxG.cameras.add(bgCamera);
		FlxG.cameras.add(gameplayCamera);
		FlxG.cameras.add(uiCamera);

		bgSprite = new FlxSprite();
		bgSprite.loadGraphic(PathUtil.ofBackground(songId));
		bgSprite.setGraphicSize(FlxG.width, FlxG.height);
		bgSprite.updateHitbox();
		bgSprite.setPosition(0, 0);
		bgSprite.cameras = [bgCamera];
		add(bgSprite);

		noteLanesGroup = new FlxTypedGroup<NoteLane>();
		noteLanesGroup.cameras = [gameplayCamera];
		add(noteLanesGroup);

		var newX:Float = 275;
		for (i in 0...4) {
			var newLane:NoteLane = new NoteLane(newX, Constants.NOTE_LANE_COLORS[i], i);
			newLane.cameras = [gameplayCamera];
			noteLanesGroup.add(newLane);
			newX += Constants.NOTE_LANE_WIDTH + Constants.NOTE_LANE_SPACING;
		}

		notesGroup = new FlxTypedGroup<Note>();
		notesGroup.cameras = [gameplayCamera];
		add(notesGroup);

		strumline = new FlxSprite();
		strumline.makeGraphic((Constants.NOTE_LANE_WIDTH * 4) + (Std.int(Constants.NOTE_LANE_SPACING) * 5), 10, FlxColor.GRAY);
		strumline.updateHitbox();
		strumline.alpha = 0.6;
		strumline.x = noteLanesGroup.members[0].x - (Constants.NOTE_LANE_SPACING);
		strumline.y = (ClientPrefs.options.scrollType == DOWNSCROLL) ? FlxG.height - Constants.STRUMLINE_Y_OFFSET : Constants.STRUMLINE_Y_OFFSET;
		strumline.cameras = [gameplayCamera];
		add(strumline);
		
		noteHitsBg = new FlxSprite();
		noteHitsBg.makeGraphic(400, FlxG.height, FlxColor.BLACK);
		noteHitsBg.updateHitbox();
		noteHitsBg.alpha = 0.6;
		noteHitsBg.x = FlxG.width - 475;
		noteHitsBg.y = 0;
		noteHitsBg.cameras = [uiCamera];
		add(noteHitsBg);

		noteHitsGroup = new FlxTypedGroup<FlxText>();
		noteHitsGroup.cameras = [uiCamera];
		add(noteHitsGroup);

		var newY:Float = 40;
		for (i in 0...7) {
			var color:FlxColor = Constants.HIT_WINDOW_DISPLAY_COLORS[i];
			var scOffset:Int = Constants.HIT_TYPE_TEXT_SHADOW_OFFSET;
			var shadowColor:FlxColor = FlxColor.fromRGB(color.red - scOffset, color.green - scOffset, color.blue - scOffset);
			var newText:FlxText = new FlxText();
			newText.text = '${Constants.HIT_WINDOW_DISPLAY_TEXTS[i]}: 0';
			newText.color = Constants.HIT_WINDOW_DISPLAY_COLORS[i];
			newText.size = Constants.HIT_WINDOW_TEXT_SIZE;
			newText.setBorderStyle(FlxTextBorderStyle.SHADOW, shadowColor, 4);
			newText.updateHitbox();
			// newText.x = noteHitsBg.x + (noteHitsBg.width - newText.width);
			newText.x = noteHitsBg.x + 8;  // Use the commented out line to align it to the right side!
			newText.y = newY;
			noteHitsGroup.add(newText);
			newY += newText.height - 12;
		}

		statsGroup = new FlxTypedGroup<FlxText>();
		statsGroup.cameras = [uiCamera];
		add(statsGroup);

		newY += 30;

		accuracyText = new FlxText();
		accuracyText.text = 'Accuracy: 0%';
		accuracyText.size = 32;
		accuracyText.color = FlxColor.WHITE;
		accuracyText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
		accuracyText.updateHitbox();
		accuracyText.x = noteHitsBg.x + 8;
		accuracyText.y = newY;
		statsGroup.add(accuracyText);

		newY += accuracyText.height - 8;

		comboText = new FlxText();
		comboText.text = 'Combo: x0';
		comboText.size = 32;
		comboText.color = FlxColor.WHITE;
		comboText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
		comboText.updateHitbox();
		comboText.x = noteHitsBg.x + 8;
		comboText.y = newY;
		statsGroup.add(comboText);

		newY += comboText.height - 8;

		scoreText = new FlxText();
		scoreText.text = 'Score: 0';
		scoreText.size = 32;
		scoreText.color = FlxColor.WHITE;
		scoreText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
		scoreText.updateHitbox();
		scoreText.x = noteHitsBg.x + 8;
		scoreText.y = newY;
		statsGroup.add(scoreText);

		noteHitTypePopup = new FlxText();
		noteHitTypePopup.size = 80;
		noteHitTypePopup.setBorderStyle(FlxTextBorderStyle.SHADOW, 0, 5);
		noteHitTypePopup.x = 0;
		noteHitTypePopup.y = 400;
		noteHitTypePopup.alpha = 0;
		noteHitTypePopup.cameras = [uiCamera];
		add(noteHitTypePopup);

		comboPopup = new FlxText();
		comboPopup.size = 60;
		comboPopup.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 5);
		comboPopup.x = 0;
		comboPopup.y = noteHitTypePopup.y + noteHitTypePopup.height + 8;
		comboPopup.alpha = 0;
		comboPopup.cameras = [uiCamera];
		add(comboPopup);

		FlxG.sound.playMusic(PathUtil.ofSong(songName), false);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		// Get the current music time in seconds
		var musicTime:Float = FlxG.sound.music.time / 1000;

		// Handle beat logic
		var currentBeat:Int = Math.floor(FlxG.sound.music.time / beatDurationMS);
		if (currentBeat != lastBeat) {
			lastBeat = currentBeat;
			if (beatCounter % 4 == 0) {
				beatHit();
			}
		}

		for (note in notesGroup.members) {
			if (!note.exists) {
				notesGroup.remove(note, true);
			}
		}

		// Calculate the spawn buffer based on note speed, strumline position, and note height
		var strumlinePosition:Float = (ClientPrefs.options.scrollType == DOWNSCROLL) ? FlxG.height
			- Constants.STRUMLINE_Y_OFFSET : Constants.STRUMLINE_Y_OFFSET;
		var spawnBuffer:Float = (strumlinePosition + (Constants.NOTE_SIZE / 2)) / noteSpeed;

		// Spawn notes in sync with the music
		for (note in songNotes) {
			var noteTime:Float = AssetUtil.getDynamicField(note, 'time', 0);
			var noteLane:Int = AssetUtil.getDynamicField(note, 'lane', 0);

			// Spawn the note when its time matches the music time minus the spawn buffer
			if (noteTime <= musicTime + spawnBuffer) {
				var noteLaneX:Float = noteLanesGroup.members[noteLane].x;
				var newNote:Note = new Note(noteLaneX, noteLane, ClientPrefs.options.scrollType, noteSpeed, note, currentNoteIdx);
				newNote.cameras = [gameplayCamera];
				notesGroup.add(newNote);
				songNotes.shift();
				currentNoteIdx++;
			}
		}

		for (note in notesGroup.members) {
			for (lane in 0...4) {
				var firstNote:Note = firstNotes.get(lane);
				if (firstNote == null) {
					firstNotes.set(lane, note);
				} else if (note.lane == lane && !firstNotes.get(lane).alive) {
					firstNotes.set(lane, note);
				}
			}
		}

		if (FlxG.keys.justPressed.R) {
			GeneralUtil.fadeIntoState(new PlayState(songId), Constants.TRANSITION_DURATION, false);
		}

		if (FlxG.sound.music.time >= FlxG.sound.music.length) {
			trace('song complete!');
			GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
		}

		var idx:Int = 0;
		for (ht in noteHitsGroup.members) {
			ht.text = '${Constants.HIT_WINDOW_DISPLAY_TEXTS[idx]}: ${CacheUtil.hits[idx]}';
			ht.size = Std.int(FlxMath.lerp(Constants.HIT_WINDOW_TEXT_SIZE, ht.size, Math.exp(-elapsed * 3.125 * Constants.HIT_TYPE_TEXT_DECAY)));
			idx++;
		}

		CacheUtil.accuracy = FlxMath.roundDecimal((CacheUtil.realHitPoints / CacheUtil.totalHitPoints) * 100, 2);
		accuracyText.text = 'Accuracy: ${(!Math.isNaN(CacheUtil.accuracy)) ? CacheUtil.accuracy : 0}%';
		comboText.text = 'Combo: x${CacheUtil.combo}';
		scoreText.text = 'Score: ${CacheUtil.score}';

		// Camera zoom logic
		bgCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, bgCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
		gameplayCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, gameplayCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
		uiCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, uiCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
	}

	function beatHit():Void {
		bgCamera.zoom += 0.015 * songCamZoomIntensity;
		gameplayCamera.zoom += 0.020 * songCamZoomIntensity;
		uiCamera.zoom += 0.025 * songCamZoomIntensity;
	}
}
