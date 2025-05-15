package states.menus;

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
    var bgSprite:FlxSprite;

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
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.play(PathUtil.ofSound('menu-back'), false);
            GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
        }
    }
}
