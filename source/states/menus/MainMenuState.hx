package states.menus;

import objects.ui.ClickableText;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import flixel.FlxSprite;
import backend.data.Constants;
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
            if (id.indexOf('assets/backgrounds/') == 0) {
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

        if (FlxG.keys.justPressed.ANY) {
            GeneralUtil.fadeIntoState(new PlayState('tight-spot'), Constants.TRANSITION_DURATION, false);
        }
    }
}
