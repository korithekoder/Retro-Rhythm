package states.menus;

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
import flixel.addons.transition.FlxTransitionableState;

class SongSelectionState extends FlxTransitionableState {
    
    var songBoard:FlxTypedGroup<SongBoardObject>;
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

    var focusedSongIdx:Int = 0;

    var isPaused:Bool = false;
    var canScroll:Bool = true;

    override function create() {
        super.create();

        bgSprite = new FlxSprite();
        add(bgSprite);

        bgSpriteOverlay = new FlxSprite();
        bgSpriteOverlay.alpha = 0;
        add(bgSpriteOverlay);

        songBoard = new FlxTypedGroup<SongBoardObject>();
        add(songBoard);

        var toAdd:Array<SongBoardObject> = [];
        for (asset in Assets.list()) {
            if (asset.indexOf('assets/charts/') == 0) {
                var song:Dynamic = AssetUtil.getJsonData(asset);
                var songId:String = asset.split('/')[asset.split('/').length - 1];
                var songMetadata = AssetUtil.getDynamicField(song, 'metadata', Constants.DEFAULT_METADATA);
		        var songName = AssetUtil.getDynamicField(songMetadata, 'name', 'Unknown');
                var songDifficulty = AssetUtil.getDynamicField(songMetadata, 'difficulty', '?');
                var songBannerColor = AssetUtil.getDynamicField(songMetadata, 'bannercolor', ["0", "0", "0"]);
                var songSpeed = AssetUtil.getDynamicField(song, 'speed', '?');
		        var songBPM = AssetUtil.getDynamicField(song, 'bpm', '?');

                var banner:SongBoardObject = new SongBoardObject(
                    0, 
                    songId.substring(0, songId.length - 5),
                    songName,
                    songBPM,
                    songSpeed,
                    songDifficulty,
                    songBannerColor
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
            songBoard.add(b);
            newY += b.bg.height + Constants.SONG_BANNER_SPACING;
        }

        for (i in 0...songBoard.length) {
            var banner:SongBoardObject = songBoard.members[i];
            banner.bg.setPosition(FlxG.width / 2 - banner.bg.width / 2, banner.bg.y);
        }

        musicPlayerGroup = new FlxTypedGroup<FlxSprite>();
        add(musicPlayerGroup);

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
                scrollSongs(-1);
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
            scrollSongs(1);
        };
        musicPlayerGroup.add(nextSongButton);

        timeBar = new FlxBar(
            20,
            0,
            FlxBarFillDirection.HORIZONTAL_INSIDE_OUT,
            FlxG.width - 40,
            5,
            FlxG.sound.music,
            'time',
            0.0,
            FlxG.sound.music.length
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

        var firstMember:SongBoardObject = songBoard.members[0];
        firstMember.isFocusedOn = true;
        setSongInfo(firstMember);
        bgSprite.loadGraphic(PathUtil.ofBackground(firstMember.id), false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);
        FlxG.sound.playMusic(PathUtil.ofSong(songBoard.members[0].id));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        playButton.loadGraphic(isPaused ? PathUtil.ofImage('play-button') : PathUtil.ofImage('pause-button'));

        if (Controls.getBinds().UI_UP_JUST_PRESSED) {
            // FlxG.sound.play(PathUtil.ofSound('menu-navigate'), false);
            scrollSongs(1);
        } else if (Controls.getBinds().UI_DOWN_JUST_PRESSED) {
            // FlxG.sound.play(PathUtil.ofSound('menu-navigate'), false);
            scrollSongs(-1);
        }

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.play(PathUtil.ofSound('menu-back'), false);
            GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
        }
    }

    function scrollSongs(dir:Int):Void {
        isPaused = false;

        if (!canScroll) return;
        if ((focusedSongIdx + dir) < 0) return;
        if ((focusedSongIdx + dir) > songBoard.members.length - 1) return;

        focusedSongIdx += dir;
        canScroll = false;
        FlxG.sound.music.stop();

        var banner = songBoard.members[focusedSongIdx];

        for (bnr in songBoard.members) {
            bnr.isFocusedOn = (bnr == banner);
        }

        for (bnr in songBoard.members) {
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
                        FlxG.sound.playMusic(PathUtil.ofSong(banner.id));
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
    }

    function setSongInfo(banner:SongBoardObject) {
        songNameText.text = 'Currently Playing: ${banner.name}';
        songDifficultyText.text = 'Difficulty: ${banner.difficulty}';
        songDifficultyText.color = GeneralUtil.getDifficultyColor(banner.difficulty);
        songDifficultyText.setBorderStyle(FlxTextBorderStyle.SHADOW, GeneralUtil.darkenFlxColor(GeneralUtil.getDifficultyColor(banner.difficulty), 70), 3);
        songBPMText.text = 'BPM: ${banner.bpm}';
        songSpeedText.text = 'Speed: ${banner.speed}';
    }
}
