package objects.gameplay;

import backend.data.ClientPrefs.ScrollType;
import backend.data.ClientPrefs;
import backend.data.Constants;
import backend.util.CacheUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import states.PlayState;

class Note extends FlxSprite {

    public var id(get, never):Int;
    private var _id:Int;

    public var lane(get, never):Int;
    private var _lane:Int;
    
    private var _scrollType:ScrollType;
    private var _speed:Float;
    private var _canScroll:Bool = true;

    public var data(get, never):Dynamic;
    private var _data:Dynamic;

    @:noCompletion
    public function get_id():Int {
        return _id;
    }

    @:noCompletion
    public function get_data():Dynamic {
        return _data;
    }

    @:noCompletion
    public function get_lane():Int {
        return _lane;
    }
    
    public function new(laneX:Float, lane:Int, scrollType:ScrollType, speed:Float, data:Dynamic, id:Int) {
        super();
        this._id = id;
        this._lane = lane;
        this._scrollType = scrollType;
        this._speed = speed;
        this._data = data;
        this.loadGraphic(PathUtil.ofImage('note-$lane'));
		this.setGraphicSize(Constants.NOTE_LANE_WIDTH, Constants.NOTE_SIZE_HEIGHT);
        this.updateHitbox();
        this.setPosition(laneX, (scrollType == DOWNSCROLL) ? -this.height : FlxG.height);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (_canScroll && this.exists) {
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

            if (!CacheUtil.botModeEnabled) {
                if (GeneralUtil.getJustPressedStrumBind(_lane) && this.exists) {
                    var firstNote:Note = PlayState.firstNotes.get(lane);
                    var canHit:Bool = (firstNote != null) ? (firstNote.alive) ? firstNote.id == this.id : false : true;
                    if (canHit && strumlineDistance <= Constants.HIT_WINDOW_OFFSETS[Constants.YIKES_INDEX]) {
                        var idx:Int = GeneralUtil.getHitTypeIndexByDistance(strumlineDistance);
                        _increaseAndEnlargeCombo(idx);
						if (ClientPrefs.options.showHitSplash)
							_createNoteHitPopup(idx);
                        fadeAndDestroy();
                        if (ClientPrefs.options.noteHitSound) {
							FlxG.sound.play(PathUtil.ofSound('hitsound'), ClientPrefs.options.hitSoundVolume, false);
                        }
                    }
                }
            } else {
                if (strumlineDistance <= Constants.HIT_WINDOW_OFFSETS[Constants.MARVELOUS_INDEX]) {
                    _increaseAndEnlargeCombo(Constants.MARVELOUS_INDEX, false, false);
					if (ClientPrefs.options.showHitSplash)
						_createNoteHitPopup(Constants.MARVELOUS_INDEX);
                    fadeAndDestroy();
                    if (ClientPrefs.options.noteHitSound) {
						FlxG.sound.play(PathUtil.ofSound('hitsound'), ClientPrefs.options.hitSoundVolume, false);
                    }
                }
            }
        }
    }

    public function fadeAndDestroy():Void {
        this._canScroll = false;
        PlayState.firstNotes.get(lane).alive = false;
        FlxTween.num(0, 1, (Constants.NOTE_DESTROY_DURATION / 2), { ease: FlxEase.quadOut }, (b:Float) -> {
            FlxSpriteUtil.setBrightness(this, b);
        });
        FlxTween.tween(this, { alpha: 0 }, Constants.NOTE_DESTROY_DURATION, { type: ONESHOT, onComplete: (_) -> this.destroy() });
    }

    public function missAndDestroy():Void {
        _increaseAndEnlargeCombo(Constants.MISS_INDEX, true, true);
		if (ClientPrefs.options.showHitSplash)
			_createNoteHitPopup(Constants.MISS_INDEX);
        this.destroy();
        PlayState.firstNotes.get(lane).alive = false;
        FlxG.sound.play(PathUtil.ofSound('miss'), false);
    }

    private function _increaseAndEnlargeCombo(idx:Int, increaseCombo:Bool = true, resetCombo:Bool = false) {
        if (increaseCombo) {
            PlayState.noteHitsGroup.members[idx].size = Constants.HIT_WINDOW_TEXT_SIZE + 8;
            CacheUtil.realHitPoints += Constants.HIT_WINDOW_ACCURACY_INCREMENTS[idx];
            CacheUtil.totalHitPoints += Constants.HIT_WINDOW_ACCURACY_INCREMENTS[Constants.MARVELOUS_INDEX];
            CacheUtil.hits[idx]++;
            CacheUtil.score += Constants.HIT_WINDOW_SCORES[idx];
		}

		CacheUtil.health += Constants.HIT_WINDOW_HEALTH_INCREMENTS[idx];

        if (CacheUtil.health > Constants.MAX_HEALTH) {
            CacheUtil.health = Constants.MAX_HEALTH;
        }
        if (CacheUtil.health < 0) {
            CacheUtil.health = 0;
        }
        
        if (!resetCombo) {
            CacheUtil.combo++;
        } else {
            CacheUtil.combo = 0;
        }
    }

    private function _createNoteHitPopup(type:Int):Void {
        FlxTween.cancelTweensOf(PlayState.noteHitTypePopup);
        FlxTween.cancelTweensOf(PlayState.comboPopup);
        var color:FlxColor = Constants.HIT_WINDOW_DISPLAY_COLORS[type];
        var scOffset:Int = Constants.HIT_TYPE_TEXT_SHADOW_OFFSET;
        var shadowColor:FlxColor = FlxColor.fromRGB(color.red - scOffset, color.green - scOffset, color.blue - scOffset);

        var minX:Float = Math.POSITIVE_INFINITY;
        var maxX:Float = Math.NEGATIVE_INFINITY;
        for (s in PlayState.noteLanesGroup.members) {
            if (s != null) {
                minX = Math.min(minX, s.x);
                maxX = Math.max(maxX, s.x);
            }
        }

        PlayState.noteHitTypePopup.text = Constants.HIT_WINDOW_DISPLAY_TEXTS[type];
        PlayState.noteHitTypePopup.color = color;
        PlayState.noteHitTypePopup.setBorderStyle(FlxTextBorderStyle.SHADOW, shadowColor, 5);
        PlayState.noteHitTypePopup.updateHitbox();
		PlayState.noteHitTypePopup.x = ((minX + maxX) / 2) - (PlayState.noteHitTypePopup.width / 2) + 50;
		PlayState.noteHitTypePopup.y = 325;
		PlayState.noteHitTypePopup.alpha = 1;

        PlayState.comboPopup.text = 'x${CacheUtil.combo}';
        PlayState.comboPopup.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 5);
		PlayState.comboPopup.x = ((minX + maxX) / 2) - (PlayState.comboPopup.width / 2) + 50;
		PlayState.comboPopup.y = PlayState.noteHitTypePopup.y + PlayState.noteHitTypePopup.height - 12;
		PlayState.comboPopup.alpha = 1;

        FlxTween.tween(PlayState.noteHitTypePopup, { y: PlayState.noteHitTypePopup.y - 50 }, 0.25, { ease: FlxEase.quadOut, onComplete: (_) -> {
            FlxTween.tween(PlayState.noteHitTypePopup, { alpha: 0 }, 1);
        }});
        FlxTween.tween(PlayState.comboPopup, { y: PlayState.comboPopup.y - 50 }, 0.25, { ease: FlxEase.quadOut, onComplete: (_) -> {
            FlxTween.tween(PlayState.comboPopup, { alpha: 0 }, 1);
        }});
    }
}
