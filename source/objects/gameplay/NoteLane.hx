package objects.gameplay;

import backend.data.ClientPrefs;
import backend.util.CacheUtil;
import flixel.math.FlxMath;
import backend.data.Constants;
import backend.util.GeneralUtil;
import backend.Controls;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class NoteLane extends FlxSprite {

    private var _lane:Int;

    public function new(x:Float, color:FlxColor, lane:Int) {
        super();
        this.makeGraphic(Constants.NOTE_LANE_WIDTH, FlxG.height, color);
        this.updateHitbox();
        this.setPosition(x, 0);
        this.alpha = ClientPrefs.options.noteLaneBaseAlpha;
        this._lane = lane;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (GeneralUtil.getPressedStrumBind(_lane) && !CacheUtil.botModeEnabled && ClientPrefs.options.noteLaneFlash) {
            this.alpha = 0.9;
        }

        this.alpha = FlxMath.lerp(ClientPrefs.options.noteLaneBaseAlpha, this.alpha, Math.exp(-elapsed * 3.125 * Constants.NOTE_LANE_ALPHA_DECAY));
    }
}
