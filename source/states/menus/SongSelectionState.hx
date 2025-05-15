package states.menus;

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

    var musicPlayerBg:FlxSprite;
    var lastSongButton:ClickableSprite;
    var nextSongButton:ClickableSprite;
    var playButton:ClickableSprite;
    var timeBar:FlxBar;

    var isPaused:Bool = false;

    override function create() {
        super.create();

        var bgFiles:Array<String> = [];
        for (id in Assets.list()) {
            if (id.indexOf('assets/backgrounds/') == 0 && id.substring(id.length - 4) == '.png') {
                bgFiles.push(id);
            }
        }

        bgSprite = new FlxSprite();
        bgSprite.loadGraphic(bgFiles[FlxG.random.int(0, bgFiles.length - 1)], false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);
        add(bgSprite);

        songBoard = new FlxTypedGroup<SongBoardObject>();
        add(songBoard);

        var newY:Float = FlxG.height / 2;
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
                    newY, 
                    songId.substring(0, songId.length - 5),
                    songName,
                    songBPM,
                    songSpeed,
                    songDifficulty,
                    songBannerColor
                );
                
                songBoard.add(banner);

                newY += banner.getBannerHeight() + 20;
            }
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
            FlxG.sound.music.time = 0;
        };
        musicPlayerGroup.add(lastSongButton);

        nextSongButton = new ClickableSprite();
        nextSongButton.loadGraphic(PathUtil.ofImage('skip-button'));
        nextSongButton.scale.set(3, 3);
        nextSongButton.updateHitbox();
        nextSongButton.setPosition(playButton.x + lastSongButton.width + 20, (musicPlayerBg.height / 2) - (lastSongButton.height / 2));
        nextSongButton.onClick = () -> {
            FlxG.sound.play(PathUtil.ofSound('hitsound'));
            trace('do some fucking implementation here or some shit');
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
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        playButton.loadGraphic(isPaused ? PathUtil.ofImage('play-button') : PathUtil.ofImage('pause-button'));

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.play(PathUtil.ofSound('menu-back'), false);
            GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
        }
    }
}
