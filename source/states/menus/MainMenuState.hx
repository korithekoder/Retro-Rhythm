package states.menus;

import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxState;

class MainMenuState extends FlxState {

    var menuText:FlxText;
    
    override function create() {
        super.create();

        GeneralUtil.playMenuMusic();

        menuText = new FlxText();
        menuText.text = 'Retro Rhythm';
        menuText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(25, 25, 25));
        menuText.size = 64;
        menuText.updateHitbox();
        add(menuText);
    }
}
