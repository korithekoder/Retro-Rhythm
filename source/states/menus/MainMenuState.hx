package states.menus;

import backend.data.Constants;
import backend.Controls;
import objects.ui.ClickableText;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class MainMenuState extends FlxTransitionableState {

    var menuText:FlxText;
    var bgSprite:FlxSprite;

    var buttons:FlxTypedGroup<ClickableText>;
    
    override function create() {
        super.create();

        GeneralUtil.playMenuMusic();

        var bgFiles = [];

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

        menuText = new FlxText();
        menuText.text = 'Retro\nRhythm';
        menuText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(25, 25, 25), 5);
        menuText.size = 128;
        menuText.updateHitbox();
        menuText.x = 60;
        menuText.y = 80;
        add(menuText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_SELECT_JUST_PRESSED) {
            GeneralUtil.fadeIntoState(new SongSelectionState(), Constants.TRANSITION_DURATION, false);
        }

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }
}
