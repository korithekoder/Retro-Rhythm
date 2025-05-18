package states.menus;

import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import objects.states.MusicBeatState;
import backend.util.CacheUtil;
import backend.data.ClientPrefs;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import objects.ui.ClickableSprite;
import backend.util.PathUtil;
import backend.util.GeneralUtil;
import backend.Controls;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import backend.data.Constants;
import objects.ui.SongBoardObject;
import backend.util.AssetUtil;
import openfl.Assets;

class SongSelectionState extends MusicBeatState {

    var bgCamera:FlxCamera;
    var uiCamera:FlxCamera;
    
    var songBoardGroup:FlxTypedGroup<SongBoardObject>;
    var musicPlayerGroup:FlxTypedGroup<FlxSprite>;
    var bgSprite:FlxSprite;
    var bgSpriteOverlay:FlxSprite;  // For when switching the background to add an effect

    var musicPlayerBg:FlxSprite;
    var lastSongButton:ClickableSprite;
    var nextSongButton:ClickableSprite;
    var playButton:ClickableSprite;
    var timeBar:FlxBar;

    var songNameText:FlxText;
    var songDifficultyText:FlxText;
    var songBPMText:FlxText;
    var songSpeedText:FlxText;
    var songTimeText:FlxText;
    var focusedSongIdx:Int = 0;
    var musicTime:Float;

    var specialEventsWarningSymbol:FlxSprite;
    var specialEventsWarningText:FlxText;

    var isPaused:Bool = false;
    var canScroll:Bool = true;

    var dblaaSequence:Array<FlxKey> = [
        A,
        P,
        P,
        L,
        E
    ];
    var dblaaSequenceIndex:Int = 0;

    override function create() {
        super.create();

        FlxG.fullscreen = ClientPrefs.getClientPreference('fullscreen');
        CacheUtil.canPlayMenuMusic = true;

        bgCamera = new FlxCamera();
        uiCamera = new FlxCamera();
        uiCamera.bgColor.alpha = 0;
        FlxG.cameras.add(bgCamera);
        FlxG.cameras.add(uiCamera);

        bgSprite = new FlxSprite();
        bgSprite.cameras = [bgCamera];
        add(bgSprite);

        bgSpriteOverlay = new FlxSprite();
        bgSpriteOverlay.alpha = 0;
        bgSpriteOverlay.cameras = [bgCamera];
        add(bgSpriteOverlay);

        songBoardGroup = new FlxTypedGroup<SongBoardObject>();
        songBoardGroup.cameras = [uiCamera];
        add(songBoardGroup);

        var toAdd:Array<SongBoardObject> = [];
        for (asset in Assets.list()) {
            if (asset.indexOf('assets/charts/') == 0 && asset != PathUtil.ofChart('dead-built-like-an-apple')) {
                var song:Dynamic = AssetUtil.getJsonData(asset);
                var songId:String = asset.split('/')[asset.split('/').length - 1];
                var songEvents:Array<Dynamic> = AssetUtil.getDynamicField(song, 'events', []);
                var songMetadata = AssetUtil.getDynamicField(song, 'metadata', Constants.DEFAULT_METADATA);
		        var songName = AssetUtil.getDynamicField(songMetadata, 'name', 'Unknown');
                var songDifficulty = AssetUtil.getDynamicField(songMetadata, 'difficulty', '?');
                var songBannerColor = AssetUtil.getDynamicField(songMetadata, 'bannercolor', ["0", "0", "0"]);
                var songSpeed = AssetUtil.getDynamicField(song, 'speed', '?');
		        var songBPM = AssetUtil.getDynamicField(song, 'bpm', '?');
                var songHasSpecialEvents:Bool = false;

                for (event in songEvents) {
                    var name = AssetUtil.getDynamicField(event, 'name', Constants.NON_SPECIAL_EVENTS[0]);
                    if (!Constants.NON_SPECIAL_EVENTS.contains(name)) {
                        songHasSpecialEvents = true;
                        break;
                    }
                }

                var banner:SongBoardObject = new SongBoardObject(
                    0, 
                    songId.substring(0, songId.length - 5),
                    songName,
                    songBPM,
                    songSpeed,
                    songDifficulty,
                    songBannerColor,
                    songHasSpecialEvents
                );
                
                toAdd.push(banner);
            }
        }

        toAdd.sort((a, b) -> {
            return a.difficulty - b.difficulty;
        });

        var newY:Float = FlxG.height / 2;
        for (b in toAdd) {
            b.bg.setPosition(FlxG.width / 2 - b.bg.width / 2, newY);
            songBoardGroup.add(b);
            newY += b.bg.height + Constants.SONG_BANNER_SPACING;
        }

        for (i in 0...songBoardGroup.length) {
            var banner:SongBoardObject = songBoardGroup.members[i];
            banner.bg.setPosition(FlxG.width / 2 - banner.bg.width / 2, banner.bg.y);
        }

        musicPlayerGroup = new FlxTypedGroup<FlxSprite>();
        musicPlayerGroup.cameras = [uiCamera];
        add(musicPlayerGroup);

        specialEventsWarningSymbol = new FlxSprite();
        specialEventsWarningSymbol.loadGraphic(PathUtil.ofImage('warning'));
        specialEventsWarningSymbol.scale.set(4, 4);
        specialEventsWarningSymbol.updateHitbox();
        specialEventsWarningSymbol.x = (FlxG.width - specialEventsWarningSymbol.width) - 128;
        specialEventsWarningSymbol.y = (FlxG.height / 2) - 40;
        specialEventsWarningSymbol.cameras = [uiCamera];
        add(specialEventsWarningSymbol);

        specialEventsWarningText = new FlxText();
        specialEventsWarningText.text = 'This song has special events\nwhich might affect gameplay!';
        specialEventsWarningText.size = 25;
        specialEventsWarningText.color = FlxColor.ORANGE;
        specialEventsWarningText.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 3);
        specialEventsWarningText.alignment = FlxTextAlign.RIGHT;
        specialEventsWarningText.updateHitbox();
        specialEventsWarningText.x = (FlxG.width - specialEventsWarningText.width) - 60;
        specialEventsWarningText.y = (specialEventsWarningSymbol.y + specialEventsWarningSymbol.height) + 15;
        specialEventsWarningText.cameras = [uiCamera];
        add(specialEventsWarningText);

        musicPlayerBg = new FlxSprite();
        musicPlayerBg.makeGraphic(FlxG.width, 150, FlxColor.BLACK);
        musicPlayerBg.updateHitbox();
        musicPlayerBg.alpha = 0.75;
        musicPlayerBg.setPosition(0, 0);
        musicPlayerGroup.add(musicPlayerBg);

        playButton = new ClickableSprite();
        playButton.loadGraphic(PathUtil.ofImage('pause-button'));
        playButton.scale.set(3, 3);
        playButton.updateHitbox();
        playButton.setPosition((FlxG.width / 2) - (playButton.width / 2), (musicPlayerBg.height / 2) - (playButton.height / 2));
        playButton.onClick = () -> {
            FlxG.sound.play(PathUtil.ofSound('hitsound'));
            isPaused = !isPaused;
            if (isPaused) {
                FlxG.sound.music.pause();
            } else {
                FlxG.sound.music.resume();
            }
        };
        musicPlayerGroup.add(playButton);

        lastSongButton = new ClickableSprite();
        lastSongButton.loadGraphic(PathUtil.ofImage('skip-button'));
        lastSongButton.scale.set(3, 3);
        lastSongButton.flipX = true;
        lastSongButton.updateHitbox();
        lastSongButton.setPosition(Math.abs(playButton.x - lastSongButton.width) - 20, (musicPlayerBg.height / 2) - (lastSongButton.height / 2));
        lastSongButton.onClick = () -> {
            FlxG.sound.play(PathUtil.ofSound('hitsound'));
            if ((FlxG.sound.music.time / 1000) > 0.5) {
                FlxG.sound.music.time = 0;
            } else {
                scrollSongs(-1, false);
            }
        };
        musicPlayerGroup.add(lastSongButton);

        nextSongButton = new ClickableSprite();
        nextSongButton.loadGraphic(PathUtil.ofImage('skip-button'));
        nextSongButton.scale.set(3, 3);
        nextSongButton.updateHitbox();
        nextSongButton.setPosition(playButton.x + lastSongButton.width + 20, (musicPlayerBg.height / 2) - (lastSongButton.height / 2));
        nextSongButton.onClick = () -> {
            FlxG.sound.play(PathUtil.ofSound('hitsound'));
            scrollSongs(1, false);
        };
        musicPlayerGroup.add(nextSongButton);

        songTimeText = new FlxText();
        songTimeText.text = '0:00 / 0:00';
        songTimeText.size = 20;
        songTimeText.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 2);
        songTimeText.updateHitbox();
        songTimeText.x = (FlxG.width / 2) - (songTimeText.width / 2);
        songTimeText.y = 115;
        musicPlayerGroup.add(songTimeText);

        timeBar = new FlxBar(
            20,
            0,
            FlxBarFillDirection.HORIZONTAL_INSIDE_OUT,
            FlxG.width - 40,
            5,
            FlxG.sound.music,
            'time'
        );
        timeBar.y = (musicPlayerBg.y + musicPlayerBg.height) - (timeBar.height) - 3;
        timeBar.createFilledBar(FlxColor.fromRGB(70, 70, 70), FlxColor.WHITE);
        musicPlayerGroup.add(timeBar);

        songNameText = new FlxText();
        songNameText.text = 'Currently Playing: SONG NAME HERE';
        songNameText.size = 32;
        songNameText.updateHitbox();
        songNameText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
        songNameText.x = musicPlayerBg.x + 4;
        songNameText.y = musicPlayerBg.y + 4;
        musicPlayerGroup.add(songNameText);

        songDifficultyText = new FlxText();
        songDifficultyText.text = 'Difficulty: SONG DIFF HERE';
        songDifficultyText.size = 20;
        songDifficultyText.color = FlxColor.WHITE;
        songDifficultyText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
        songDifficultyText.updateHitbox();
        songDifficultyText.x = musicPlayerBg.x + 4;
        songDifficultyText.y = songNameText.y + songNameText.height + 4;
        musicPlayerGroup.add(songDifficultyText);

        songBPMText = new FlxText();
        songBPMText.text = 'BPM: BPM HERE';
        songBPMText.size = 20;
        songBPMText.updateHitbox();
        songBPMText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
        songBPMText.x = musicPlayerBg.x + 4;
        songBPMText.y = songDifficultyText.y + songDifficultyText.height - 2;
        musicPlayerGroup.add(songBPMText);

        songSpeedText = new FlxText();
        songSpeedText.text = 'Speed: SONG SPEED HERE';
        songSpeedText.size = 20;
        songSpeedText.updateHitbox();
        songSpeedText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
        songSpeedText.x = musicPlayerBg.x + 4;
        songSpeedText.y = songBPMText.y + songBPMText.height - 2;
        musicPlayerGroup.add(songSpeedText);

        var firstMember:SongBoardObject = songBoardGroup.members[0];
        firstMember.isFocusedOn = true;
        setSongInfo(firstMember);
        bgSprite.loadGraphic(PathUtil.ofBackground(firstMember.id), false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);
        specialEventsWarningSymbol.visible = firstMember.hasSpecialEvents;
        specialEventsWarningText.visible = firstMember.hasSpecialEvents;
        setSongData(firstMember);
        FlxG.sound.music.loadEmbedded(PathUtil.ofSong(songBoardGroup.members[0].id), true, false);
        FlxG.sound.music.play();
        setSongTimeInfo();
        timeBar.setRange(0.0, FlxG.sound.music.length);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // notice how this is the first thing checked?
        // ( ͡° ͜ʖ ͡°)  <- copilot recommended me that LMFAO
        if (FlxG.keys.anyJustPressed([dblaaSequence[dblaaSequenceIndex]])) {
            dblaaSequenceIndex++;
            FlxG.sound.play(PathUtil.ofSound('hitsound'), false);
            if (dblaaSequenceIndex >= dblaaSequence.length) {
                FlxG.sound.play(PathUtil.ofSound('secret'), false);
                GeneralUtil.fadeIntoState(new PlayState('dead-built-like-an-apple'), Constants.TRANSITION_DURATION, false);
            }
        }

        musicTime = FlxG.sound.music.time / 1000;

        if (Controls.getBinds().UI_UP_JUST_PRESSED) {
            scrollSongs(-1, 'blip');
        } else if (Controls.getBinds().UI_DOWN_JUST_PRESSED) {
            scrollSongs(1, 'blip');
        }

        if (FlxG.mouse.wheel != 0) {
            if (FlxG.mouse.wheel > 0) {
                scrollSongs(-1, 'blip');
            } else {
                scrollSongs(1, 'blip');
            }
        }

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.play(PathUtil.ofSound('menu-back'), false);
            GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
        }

        setSongTimeInfo();
        playButton.loadGraphic(isPaused ? PathUtil.ofImage('play-button') : PathUtil.ofImage('pause-button'));
        bgCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, bgCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));
    }

    function scrollSongs(dir:Int, soundToPlay:String = 'hitsound', playSound:Bool = true):Void {
        isPaused = false;

        if (!canScroll) return;
        if ((focusedSongIdx + dir) < 0) return;
        if ((focusedSongIdx + dir) > songBoardGroup.members.length - 1) return;

        focusedSongIdx += dir;
        canScroll = false;
        FlxG.sound.music.stop();

        var banner = songBoardGroup.members[focusedSongIdx];

        specialEventsWarningSymbol.visible = banner.hasSpecialEvents;
        specialEventsWarningText.visible = banner.hasSpecialEvents;

        for (bnr in songBoardGroup.members) {
            bnr.isFocusedOn = (bnr == banner);
        }

        for (bnr in songBoardGroup.members) {
            var newY:Float = bnr.bg.y;
            newY += (bnr.bg.height + Constants.SONG_BANNER_SPACING) * dir * -1;
            FlxTween.tween(
                bnr.bg, 
                {
                    y: newY
                },
                Constants.SONG_BANNER_SCROLL_DELAY,
                {
                    ease: FlxEase.quadOut,
                    onUpdate: (_) -> {
                        bnr.bg.updateHoverBounds();
                    },
                    onComplete: (_) -> {
                        setSongData(banner);
                        FlxG.sound.music.loadEmbedded(PathUtil.ofSong(banner.id), true, false);
                        FlxG.sound.music.play();
                        setSongTimeInfo();
                        timeBar.setRange(0.0, FlxG.sound.music.length);
                    }
                }
            );
        }

        setSongInfo(banner);

        bgSpriteOverlay.loadGraphic(bgSprite.graphic, false);
        bgSpriteOverlay.setGraphicSize(FlxG.width, FlxG.height);
        bgSpriteOverlay.updateHitbox();
        bgSpriteOverlay.setPosition(0, 0);
        bgSpriteOverlay.alpha = 1;

        bgSprite.loadGraphic(PathUtil.ofBackground(banner.id), false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);

        FlxTween.cancelTweensOf(bgSpriteOverlay);
        FlxTween.tween(bgSpriteOverlay, { alpha: 0 }, Constants.SONG_BANNER_SCROLL_DELAY);

        new FlxTimer().start(Constants.SONG_BANNER_SCROLL_DELAY, (t) -> {
            canScroll = true;
        });

        if (playSound) {
            FlxG.sound.play(PathUtil.ofSound(soundToPlay));
        }
    }

    function setSongInfo(banner:SongBoardObject) {
        songNameText.text = 'Currently Playing: ${banner.name}';
        songDifficultyText.text = 'Difficulty: ${banner.difficulty}';
        songDifficultyText.color = GeneralUtil.getDifficultyColor(banner.difficulty);
        songDifficultyText.setBorderStyle(FlxTextBorderStyle.SHADOW, GeneralUtil.darkenFlxColor(GeneralUtil.getDifficultyColor(banner.difficulty), 70), 3);
        songBPMText.text = 'BPM: ${banner.bpm}';
        songSpeedText.text = 'Speed: ${banner.speed}';
    }

    function setSongTimeInfo():Void {
        var timePassedMinutes:Int = Math.floor(FlxG.sound.music.time / 60000);
        var timePassedSeconds:Int = Math.floor((FlxG.sound.music.time % 60000) / 1000);
        var timeLeftMinutes:Int = Math.floor(FlxG.sound.music.length / 60000);
        var timeLeftSeconds:Int = Math.floor((FlxG.sound.music.length % 60000) / 1000);
        var timePassedString:String = '$timePassedMinutes : ${(timePassedSeconds >= 10) ? '' : '0'}$timePassedSeconds';
        var timeLeftString:String = '$timeLeftMinutes : ${(timeLeftSeconds >= 10) ? '' : '0'}$timeLeftSeconds';
        songTimeText.text = '$timePassedString  /  $timeLeftString';
        songTimeText.updateHitbox();
        songTimeText.x = (FlxG.width / 2) - (songTimeText.width / 2);
        songTimeText.y = 115;
    }

    function setSongData(banner:SongBoardObject):Void {
        var songData:Dynamic = AssetUtil.getJsonData(PathUtil.ofChart(banner.id));
        beatCounter = 0;
        lastBeat = -1;
        songBPM = AssetUtil.getDynamicField(songData, 'bpm', 60);
        songCamZoomIntensity = AssetUtil.getDynamicField(songData, 'camzoom', 1.0);
        beatsBeforeHit = AssetUtil.getDynamicField(songData, 'beatsbeforehit', 4);
        beatDuration = 60 / songBPM;
        beatDurationMS = 60000 / songBPM;
    }

    function triggerEvent(name:String, values:Array<Dynamic>):Void {
		switch (name) {
			case 'Add Camera Zoom':
				var v1:Float = Std.parseFloat(Std.string(values[0]));
				bgCamera.zoom += 0.015 * songCamZoomIntensity + v1;

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
        }
    }

    public function beatHit() {
        bgCamera.zoom += 0.015 * songCamZoomIntensity;
    }
}
