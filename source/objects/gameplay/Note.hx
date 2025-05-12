package objects.gameplay;

import flixel.tweens.FlxEase;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import backend.data.Constants;
import backend.util.PathUtil;
import backend.util.CacheUtil;
import backend.data.ClientPrefs;
import backend.util.GeneralUtil;
import flixel.FlxG;
import backend.data.ClientPrefs.ScrollType;
import flixel.FlxSprite;

class Note extends FlxSprite {
    
    public var canHit:Bool = true;

    private var _lane:Int;
    private var _scrollType:ScrollType;
    private var _speed:Float;
    private var _canScroll:Bool = true;

    public var data(get, never):Dynamic;
    private var _data:Dynamic;

    @:noCompletion
    public function get_data():Dynamic {
        return _data;
    }
    
    public function new(laneX:Float, lane:Int, scrollType:ScrollType, speed:Float, data:Dynamic) {
        super();
        this.loadGraphic(PathUtil.ofImage('note'));
        this.setGraphicSize(100, 100);
        this.updateHitbox();
        this.setPosition(laneX, (scrollType == DOWNSCROLL) ? -this.height : FlxG.height);
        this._lane = lane;
        this._scrollType = scrollType;
        this._speed = speed;
        this._data = data;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (_canScroll) {
            var strumlinePosition:Float = (ClientPrefs.options.scrollType == DOWNSCROLL) ? FlxG.height
                - Constants.STRUMLINE_Y_OFFSET : Constants.STRUMLINE_Y_OFFSET;
            var strumlineDistance:Float = Math.abs(strumlinePosition - (this.y + (this.height / 2)));

            this.y += (ClientPrefs.options.scrollType == DOWNSCROLL ? 1 : -1) * _speed * elapsed;
                if (_scrollType == DOWNSCROLL) {
                    if (this.y >= FlxG.height) {
                        missAndDestroy();
                    }
                } else {
                    if (this.y <= -this.height) {
                        missAndDestroy();
                    }
                }

            if (GeneralUtil.getJustPressedStrumBind(_lane)) {
                if (canHit && strumlineDistance <= Constants.HIT_WINDOW_OFFSETS[Constants.YIKES_INDEX]) {
                    CacheUtil.hits[GeneralUtil.getHitTypeIndexByDistance(strumlineDistance)]++;
                    fadeAndDestroy();
                }
            }
        }
    }

    public function fadeAndDestroy():Void {
        this._canScroll = false;
        FlxTween.num(0, 1, 0.05, { ease: FlxEase.quadOut }, (b:Float) -> {
            FlxSpriteUtil.setBrightness(this, b);
        });
        FlxTween.tween(this, { alpha: 0 }, Constants.NOTE_DESTROY_DURATION, { type: ONESHOT, onComplete: (_) -> this.destroy() });
    }

    public inline function missAndDestroy():Void {
        CacheUtil.hits[Constants.MISS_INDEX]++;
        this.destroy();
    }
}
