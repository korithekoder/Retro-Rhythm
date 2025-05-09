package objects.gameplay;

import backend.util.CacheUtil;
import backend.data.ClientPrefs;
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

    public var data(get, never):Dynamic;
    private var _data:Dynamic;

    @:noCompletion
    public function get_data():Dynamic {
        return _data;
    }
    
    public function new(laneX:Float, lane:Int, scrollType:ScrollType, speed:Float, data:Dynamic) {
        super();
        this.makeGraphic(Std.int(100), Std.int(100), FlxColor.RED);
        this.updateHitbox();
        this.setPosition(laneX, (scrollType == DOWNSCROLL) ? -this.height : FlxG.height);
        this._lane = lane;
        this._scrollType = scrollType;
        this._speed = speed;
        this._data = data;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

		this.y += (ClientPrefs.options.scrollType == DOWNSCROLL ? 1 : -1) * _speed * elapsed;

        if (_scrollType == DOWNSCROLL) {
            if (this.y > FlxG.height) {
                this.destroy();
            }
        } else {
            if (this.y < 0) {
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
