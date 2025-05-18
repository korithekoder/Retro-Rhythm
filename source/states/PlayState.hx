package states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import backend.Controls;
import backend.data.ClientPrefs;
import backend.data.Constants;
import backend.util.AssetUtil;
import backend.util.CacheUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import objects.gameplay.Note;
import objects.gameplay.NoteLane;
import objects.states.MusicBeatState;
import states.menus.MainMenuState;
import substates.PauseSubState;

class PlayState extends MusicBeatState {

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
	var songEvents:Array<Dynamic>;
	var songMetadata:Dynamic;

	var songComposer:String;
	var songCharter:String;
	var songName:String;

	var songSpeed:Float;
	var songLength:Float;

	var accuracyText:FlxText;
	var comboText:FlxText;
	var scoreText:FlxText;
	var healthText:FlxText;
	var timeText:FlxText;

	var songNameText:FlxText;

	var healthBar:FlxBar;
	var timeBar:FlxBar;
	var healthBarShadow:FlxSprite;
	var timeBarShadow:FlxSprite;
	var healthBarTextDisplay:FlxText;
	var timeBarTextDisplay:FlxText;

	var musicTime:Float;
	var musicTimeMS:Float;

	var currentNoteIdx:Int = 0;
	var noteSpeed:Float;
	var notesGroup:FlxTypedGroup<Note>;

	var noteHitsBg:FlxSprite;
	var strumline:FlxSprite;

	var bgSprite:FlxSprite;

	public function new(songId:String) {
		super();
		this.songId = songId;

		songData = AssetUtil.getJsonData(PathUtil.ofChart(songId), {});
		songNotes = AssetUtil.getDynamicField(songData, 'notes', []);
		songEvents = AssetUtil.getDynamicField(songData, 'events', []);
		songMetadata = AssetUtil.getDynamicField(songData, 'metadata', Constants.DEFAULT_METADATA);

		songName = AssetUtil.getDynamicField(songMetadata, 'name', 'Unknown');
		songComposer = AssetUtil.getDynamicField(songMetadata, 'composer', 'Unknown');
		songCharter = AssetUtil.getDynamicField(songMetadata, 'charter', 'Unknown');

		songBPM = AssetUtil.getDynamicField(songData, 'bpm', 60);
		songSpeed = AssetUtil.getDynamicField(songData, 'speed', 1);
		songCamZoomIntensity = AssetUtil.getDynamicField(songData, 'camzoom', 2);

		beatDuration = 60 / songBPM;
		beatDurationMS = 60000 / songBPM;
		beatsBeforeHit = AssetUtil.getDynamicField(songData, 'beatsbeforehit', 4);

		noteSpeed = (FlxG.height / beatDuration) * songSpeed;

		songNotes.sort((a, b) -> {
			var aTime:Float = AssetUtil.getDynamicField(a, 'time', 0);
			var bTime:Float = AssetUtil.getDynamicField(b, 'time', 0);
			return Std.int(aTime - bTime);
		});
		songEvents.sort((a, b) -> {
			var aTime:Float = AssetUtil.getDynamicField(a, 'time', 0);
			var bTime:Float = AssetUtil.getDynamicField(b, 'time', 0);
			return Std.int(aTime - bTime);
		});
	}
	
	override public function create() {
		super.create();

		CacheUtil.canPlayMenuMusic = true;
		CacheUtil.realHitPoints = 0;
		CacheUtil.totalHitPoints = 0;
		CacheUtil.combo = 0;
		CacheUtil.score = 0;
		CacheUtil.health = Constants.MAX_HEALTH;
		CacheUtil.currentSongId = songId;
		GeneralUtil.resetHitsArray();

		firstNotes = [
			0 => null,
			1 => null,
			2 => null,
			3 => null
		];

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
		noteHitTypePopup.cameras = [gameplayCamera];
		add(noteHitTypePopup);

		comboPopup = new FlxText();
		comboPopup.size = 60;
		comboPopup.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 5);
		comboPopup.x = 0;
		comboPopup.y = noteHitTypePopup.y + noteHitTypePopup.height + 8;
		comboPopup.alpha = 0;
		comboPopup.cameras = [gameplayCamera];
		add(comboPopup);

		healthBarShadow = new FlxSprite();
		healthBarShadow.makeGraphic((Constants.NOTE_LANE_WIDTH * 4) + (Std.int(Constants.NOTE_LANE_SPACING) * 5), Constants.STAT_BAR_HEIGHT, FlxColor.fromRGB(25, 25, 25));
		healthBarShadow.updateHitbox();
		healthBarShadow.setPosition(noteLanesGroup.members[0].x - (Constants.NOTE_LANE_SPACING) + 5,
			(ClientPrefs.options.scrollType == DOWNSCROLL) ? Constants.STAT_BAR_OFFSET + 65 : FlxG.height - (Constants.STAT_BAR_OFFSET + 55));
		healthBarShadow.cameras = [uiCamera];
		add(healthBarShadow);

		healthBar = new FlxBar(
			noteLanesGroup.members[0].x - (Constants.NOTE_LANE_SPACING), 
			(ClientPrefs.options.scrollType == DOWNSCROLL) ? Constants.STAT_BAR_OFFSET + 60 : FlxG.height - (Constants.STAT_BAR_OFFSET + 60),   
			LEFT_TO_RIGHT, 
			(Constants.NOTE_LANE_WIDTH * 4) + (Std.int(Constants.NOTE_LANE_SPACING) * 5), 
			Constants.STAT_BAR_HEIGHT, 
			CacheUtil,   
			"health", 
			0.0, 
			Constants.MAX_HEALTH
		);
		healthBar.createFilledBar(FlxColor.RED, FlxColor.GREEN);
		healthBar.updateHitbox();
		healthBar.cameras = [uiCamera];
		add(healthBar);

		newY += scoreText.height + 8;

		timeBarShadow = new FlxSprite();
		timeBarShadow.makeGraphic(Constants.STAT_BAR_WIDTH - 3, Constants.STAT_BAR_HEIGHT - 5, FlxColor.fromRGB(25, 25, 25));
		timeBarShadow.updateHitbox();
		timeBarShadow.setPosition(noteHitsBg.x + 13, newY + 5);
		timeBarShadow.cameras = [uiCamera];
		add(timeBarShadow);

		timeBar = new FlxBar(
			noteHitsBg.x + 8, 
			newY, 
			LEFT_TO_RIGHT, 
			Constants.STAT_BAR_WIDTH, 
			Constants.STAT_BAR_HEIGHT, 
			this,
			"musicTimeMS",
			0.0,
			new FlxSound().loadEmbedded(PathUtil.ofSong(songId)).length
		);
		timeBar.createFilledBar(FlxColor.fromRGB(50, 50, 50), FlxColor.WHITE);
		timeBar.updateHitbox();
		timeBar.numDivisions = 400;
		timeBar.cameras = [uiCamera];
		add(timeBar);

		healthText = new FlxText();
		healthText.text = '';
		healthText.size = 64;
		healthText.color = FlxColor.WHITE;
		healthText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		healthText.updateHitbox();
		healthText.x = healthBar.x + ((healthBar.width / 2) - (healthText.width / 2)) + 4;
		healthText.y = healthBar.y + ((healthBar.height / 2) - (healthText.height / 2));
		healthText.cameras = [uiCamera];
		add(healthText);

		timeText = new FlxText();
		timeText.text = '';
		timeText.size = 32;
		timeText.color = FlxColor.WHITE;
		timeText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2.5);
		timeText.updateHitbox();
		timeText.x = (timeBar.x + (timeBar.width / 2)) - (timeText.width / 2);
		timeText.y = (timeBar.y + (timeBar.height / 2)) - (timeText.height / 2);
		timeText.cameras = [uiCamera];
		add(timeText);

		FlxG.sound.music.loadEmbedded(PathUtil.ofSong(songId), false, false);
		FlxG.sound.music.onComplete = () -> {
			GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
		};
		FlxG.sound.music.play();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (CacheUtil.health <= 0) {
			GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
		}

		// Get the current music time in seconds
		musicTime = FlxG.sound.music.time / 1000;
		musicTimeMS = FlxG.sound.music.time;

		for (note in notesGroup.members) {
			if (!note.exists) {
				notesGroup.remove(note, true);
			}
		}

		// Calculate the spawn buffer based on note speed, strumline position, and note height
		var strumlineY:Float = (ClientPrefs.options.scrollType == DOWNSCROLL) ? FlxG.height - Constants.STRUMLINE_Y_OFFSET : Constants.STRUMLINE_Y_OFFSET;
		var spawnY:Float = (ClientPrefs.options.scrollType == DOWNSCROLL) ? -Constants.NOTE_SIZE_HEIGHT : FlxG.height;
		var travelDistance:Float = Math.abs(strumlineY - spawnY);
		var spawnBuffer:Float = (travelDistance + (Constants.NOTE_SIZE_HEIGHT / 2)) / noteSpeed;

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

		// Check for events
		for (event in songEvents) {
			var eventName:String = AssetUtil.getDynamicField(event, 'name', '');
			var eventTime:Float = AssetUtil.getDynamicField(event, 'time', musicTime);
			var eventValues:Array<Dynamic> = AssetUtil.getDynamicField(event, 'values', []);

			if (eventTime <= musicTime) {
				triggerEvent(eventName, eventValues);
				songEvents.shift();
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

		if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
			openSubState(new PauseSubState());
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

		var minX:Float = Math.POSITIVE_INFINITY;
        var maxX:Float = Math.NEGATIVE_INFINITY;
        for (s in noteLanesGroup.members) {
            if (s != null) {
                minX = Math.min(minX, s.x);
                maxX = Math.max(maxX, s.x);
            }
        }
		noteHitTypePopup.x = ((minX + maxX) / 2) - (noteHitTypePopup.width / 2) + 50;
		comboPopup.x = ((minX + maxX) / 2) - (comboPopup.width / 2) + 50;

		var timeLeft:Float = FlxG.sound.music.length - FlxG.sound.music.time;
		var minutesLeft:Int = Math.floor(timeLeft / 60000);
		var secondsLeft:Int = Math.floor((timeLeft % 60000) / 1000);
		timeText.text = '${Std.string(minutesLeft)} : ${secondsLeft < 10 ? '0' : ''}${Std.string(secondsLeft)}';
		timeText.updateHitbox();
		timeText.x = (timeBar.x + (timeBar.width / 2)) - (timeText.width / 2) + 4;
		timeText.y = (timeBar.y + (timeBar.height / 2)) - (timeText.height / 2);

		healthText.text = (!CacheUtil.botModeEnabled) ? 'HP: ${Math.ceil(CacheUtil.health)}%' : 'BOT PLAY ENABLED';
		healthText.color = (CacheUtil.health > 30) ? FlxColor.WHITE : FlxColor.RED;
		healthText.updateHitbox();
		healthText.x = healthBar.x + ((healthBar.width / 2) - (healthText.width / 2));
		healthText.y = healthBar.y + ((healthBar.height / 2) - (healthText.height / 2));

		// Camera zoom logic
		bgCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, bgCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
		gameplayCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, gameplayCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
		uiCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, uiCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
	}

	function triggerEvent(name:String, values:Array<Dynamic>):Void {
		switch (name) {

			/*
			 * REGULAR EVENTS (NON GAMEPLAY CHANGING)
			 */

			case 'Add Camera Zoom':
				var v1:Float = Std.parseFloat(Std.string(values[0]));
				bgCamera.zoom += 0.015 * songCamZoomIntensity + v1;
				gameplayCamera.zoom += 0.020 * songCamZoomIntensity + v1;
				uiCamera.zoom += 0.025 * songCamZoomIntensity + v1;

			case 'Set Beats Before Hit':
				var v1 = Std.parseInt(Std.string(values[0]));
				beatsBeforeHit = v1;
				beatCounter = 0;
				lastBeat = -1;

			case 'Change Beats Before Hit':
				var v1 = Std.parseInt(Std.string(values[0]));
				if (beatsBeforeHit + v1 > 0) {
					beatCounter = 0;
					lastBeat = -1;
					beatsBeforeHit += v1;
				}

			case 'Set Cam Zoom Intensity':
				var v1:Float = Std.parseFloat(Std.string(values[0]));
				songCamZoomIntensity = v1;

			case 'Change Cam Zoom Intensity':
				var v1:Float = Std.parseFloat(Std.string(values[0]));
				songCamZoomIntensity += v1;

			/*
			 * SPECIAL EVENTS (GAMEPLAY CHANGING)
			 */

			case 'Move Note Lanes':
				var v1:Float = Std.parseFloat(Std.string(values[0]));
				var v2:Float = Std.parseFloat(Std.string(values[1]));
				for (member in noteLanesGroup.members) {
					FlxTween.tween(member, { x: member.x + v2 }, v1, {
						ease: FlxEase.quadInOut
					});
				}
				FlxTween.tween(strumline, { x: strumline.x + v2 }, v1, {
					ease: FlxEase.quadInOut
				});
				FlxTween.tween(uiCamera, { alpha: 0 }, v1 - 0.4, {
					ease: FlxEase.quadInOut
				});

			case 'Reset Note Lane Positions':
				var v1:Float = Std.parseFloat(Std.string(values[0]));
				var newX:Float = 275;
				for (member in noteLanesGroup.members) {
					FlxTween.tween(member, { x: newX }, v1, {
						ease: FlxEase.quadInOut
					});
					newX += Constants.NOTE_LANE_WIDTH + Constants.NOTE_LANE_SPACING;
				}
				FlxTween.tween(strumline, { x: 275 - (Constants.NOTE_LANE_SPACING) }, v1, {
					ease: FlxEase.quadInOut
				});
				FlxTween.tween(uiCamera, { alpha: 1 }, v1, {
					ease: FlxEase.quadInOut
				});

		}
	}

	public function beatHit():Void {
		bgCamera.zoom += 0.015 * songCamZoomIntensity;
		gameplayCamera.zoom += 0.020 * songCamZoomIntensity;
		uiCamera.zoom += 0.025 * songCamZoomIntensity;
	}
}
