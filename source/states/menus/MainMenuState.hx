package states.menus;

import backend.data.Constants;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class MainMenuState extends FlxTransitionableState {

    var menuText:FlxText;
    
    override function create() {
        super.create();

        GeneralUtil.playMenuMusic();

        menuText = new FlxText();
        menuText.text = 'Retro\nRhythm';
        menuText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(25, 25, 25), 5);
        menuText.size = 128;
        menuText.updateHitbox();
        menuText.x = 30;
        menuText.y = 50;
        add(menuText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ANY) {
            GeneralUtil.fadeIntoState(new PlayState(), Constants.TRANSITION_DURATION, false);
        }
    }
}
