package objects.gameplay;

import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import backend.Controls;
import flixel.FlxG;
import backend.data.ClientPrefs.ScrollType;
import flixel.FlxSprite;

class Note extends FlxSprite {
    
    public var canHit:Bool = false;

    private var _lane:Int;
    private var _scrollType:ScrollType;
    private var _speed:Float;
    
    public function new(laneX:Float, lane:Int, scrollType:ScrollType, speed:Float) {
        super();
        this.makeGraphic(Std.int(100), Std.int(100), FlxColor.RED);
        this.updateHitbox();
        this.setPosition(laneX, (scrollType == DOWNSCROLL) ? -this.height : FlxG.height);
        this._lane = lane;
        this._scrollType = scrollType;
        this._speed = speed;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (_scrollType == DOWNSCROLL) {
            this.y += _speed * elapsed;
        } else {
            this.y -= _speed * elapsed;
        }

        if (_scrollType == DOWNSCROLL) {
            if (this.y > FlxG.width) {
                this.destroy();
            }
        } else {
            if (this.y < -this.height) {
                this.destroy();
            }
        }

        if (GeneralUtil.getPressedStrumBind(_lane)) {
            if (canHit) {
                this.destroy();
            }
        }
    }
}
