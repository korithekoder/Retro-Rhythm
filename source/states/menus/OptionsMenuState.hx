package states.menus;

import backend.data.Constants;
import backend.util.GeneralUtil;
import backend.Controls;
import backend.util.CacheUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import backend.util.AssetUtil;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class OptionsMenuState extends FlxTransitionableState {
    
    var bgSprite:FlxSprite;

    override function create() {
        super.create();

        CacheUtil.canPlayMenuMusic = true;
        FlxG.sound.playMusic(PathUtil.ofMusic('Ennui'), true);

        bgSprite = new FlxSprite();
        bgSprite.loadGraphic(PathUtil.ofImage('options-bg'), false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);
        add(bgSprite);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.play(PathUtil.ofSound('menu-back'), false);
            FlxG.sound.music.stop();
            GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
        }
    }
}
