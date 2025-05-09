package states;

import backend.data.ClientPrefs;
import backend.data.Constants;
import backend.util.AssetUtil;
import backend.util.CacheUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.gameplay.Note;
import objects.gameplay.NoteLane;

class PlayState extends FlxState {

	public static var bgCamera:FlxCamera;
	public static var gameplayCamera:FlxCamera;
	public static var uiCamera:FlxCamera;

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

	var beatDuration:Float;
	var beatCounter:Int = 0;
	var timeSinceLastBeat:Float = 0;

	var noteSpeed:Float;
	var noteLanesGroup:FlxTypedGroup<NoteLane>;
	var notesGroup:FlxTypedGroup<Note>;

	var strumline:FlxSprite;

	var totalTimePassed:Float = 0;

	var bgSprite:FlxSprite;

	var songDoneTimer:FlxTimer;

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

		this.noteSpeed = (FlxG.height / this.beatDuration) * this.songSpeed;
	}
	
	override public function create() {
		super.create();
		CacheUtil.canPlayMenuMusic = true;

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

		var newX:Float = 350;
		for (i in 0...4) {
			var newLane:NoteLane = new NoteLane(newX, FlxColor.BLUE, i);
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

		var songFile:FlxSound = new FlxSound();
		CacheUtil.musicTime = 0;
		songFile.loadEmbedded(PathUtil.ofSong(songName));
		FlxG.sound.playMusic(PathUtil.ofSong(songName), false);

		songDoneTimer = new FlxTimer();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		timeSinceLastBeat += elapsed;

		// Get the current music time in seconds
		var musicTime:Float = FlxG.sound.music.time / 1000;
		CacheUtil.musicTime = musicTime;

		// Handle beat logic
		if (timeSinceLastBeat >= beatDuration) {
			timeSinceLastBeat -= beatDuration;
			beatCounter++;

			if (beatCounter % 1 == 0) {
				beatHit();
			}
		}

		// Calculate the spawn buffer based on note speed, strumline position, and note height
		var strumlinePosition:Float = (ClientPrefs.options.scrollType == DOWNSCROLL) ? FlxG.height
			- Constants.STRUMLINE_Y_OFFSET : Constants.STRUMLINE_Y_OFFSET;
		var spawnBuffer:Float = (strumlinePosition + (Constants.NOTE_SIZE / 2)) / noteSpeed;

		// Spawn notes in sync with the music
		if (songNotes.length > 0) {
			var note:Dynamic = songNotes[0];
			var noteTime:Float = AssetUtil.getDynamicField(note, 'time', 0);
			var noteLane:Int = AssetUtil.getDynamicField(note, 'lane', 0);

			// Spawn the note when its time matches the music time minus the spawn buffer
			if (noteTime <= musicTime + spawnBuffer + 0.4) {
				var noteLaneX:Float = noteLanesGroup.members[noteLane].x;
				var newNote:Note = new Note(noteLaneX, noteLane, ClientPrefs.options.scrollType, noteSpeed, note);
				newNote.cameras = [gameplayCamera];
				notesGroup.add(newNote);
				songNotes.shift();
			}
		}

		// Update the position of falling notes
		for (note in notesGroup.members) {
			if (note != null) {
				// Remove notes that are off-screen
				if ((ClientPrefs.options.scrollType == DOWNSCROLL && note.y > FlxG.height)
					|| (ClientPrefs.options.scrollType != DOWNSCROLL && note.y < 0)) {
					notesGroup.remove(note, true);
				}
			}
		}

		// Camera zoom logic
		bgCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, bgCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
		gameplayCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, bgCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
	}

	function beatHit():Void {
		bgCamera.zoom += 0.015 * songCamZoomIntensity;
		gameplayCamera.zoom += 0.010 * songCamZoomIntensity;
	}
}
