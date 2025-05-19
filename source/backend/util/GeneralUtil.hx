package backend.util;

import flixel.input.keyboard.FlxKey;
import backend.data.Constants;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.gameplay.NoteLane;
#if DISCORD_ALLOWED
import backend.api.DiscordClient;
#end
#if html5
import js.Browser;
#end

/**
 * Utility class which holds functions that don't fit into any other category.
 */
final class GeneralUtil {

    private function new() {}

    /**
     * Fades into a state with a cool transition effect.
     * 
     * @param state             The states to switch to.
     * @param duration          How long it takes to switch from one state to the next state.
     * @param playTransitionSfx Should the game play a sound when it switches states?
     */
    public static function fadeIntoState(state:FlxState, duration:Float, playTransitionSfx:Bool = true):Void {
        if (playTransitionSfx) {
            FlxG.sound.play(PathUtil.ofSound(''), 1, false, false);
        }
        
        FlxG.camera.fade(FlxColor.BLACK, duration, false, () -> {
            FlxG.switchState(() -> state);
        });
    }

    /**
     * Play menu music ***if*** it hasn't already started.
     */
	public static function playMenuMusic(trackName:String = '', volume:Float = 1):Void {
        if (CacheUtil.canPlayMenuMusic) {
			FlxG.sound.playMusic(PathUtil.ofMusic(!(trackName == '') ? trackName : Constants.DEFAULT_MENU_MUSIC_NAME), volume, true);
            CacheUtil.canPlayMenuMusic = false;
        }
    }

    public static function getPressedStrumBind(lane:Int):Bool {
        var arr:Array<Bool> = [
            Controls.getBinds().S_LEFT_PRESSED,
            Controls.getBinds().S_DOWN_PRESSED,
            Controls.getBinds().S_UP_PRESSED,
            Controls.getBinds().S_RIGHT_PRESSED
        ];
        return arr[lane];
    }

    public static function getJustPressedStrumBind(lane:Int):Bool {
        var arr:Array<Bool> = [
            Controls.getBinds().S_LEFT_JUST_PRESSED,
            Controls.getBinds().S_DOWN_JUST_PRESSED,
            Controls.getBinds().S_UP_JUST_PRESSED,
            Controls.getBinds().S_RIGHT_JUST_PRESSED
        ];
        return arr[lane];
    }

    public static function getHitTypeIndexByDistance(distance:Float):Int {
        var idx:Int = 0;
        for (t in Constants.HIT_WINDOW_OFFSETS) {
            if (distance <= t) {
                return idx;
            }
            idx++;
        }
        return 5;
    }

    public static function getDifficultyColor(d:Int):FlxColor {
        if (d <= 5) {
            return FlxColor.GREEN;
        } else if (d <= 9) {
            return FlxColor.YELLOW;
        } else if (d <= 15) {
            return FlxColor.RED;
        } else if (d <= 20) {
            return FlxColor.fromRGB(110, 0, 0);
        } else {
            return FlxColor.PURPLE;
        }
    }

    public static function darkenFlxColor(color:FlxColor, shade:Int):FlxColor {
        return FlxColor.fromRGB(color.red - shade, color.green - shade, color.blue - shade);
    }

    /**
     * Tweens an `FlxSpriteGroup`'s members with ease.
     * 
     * @param group    The group to tween.
     * @param options  Dynamic object with the attributes to tween.
     * @param duration How long the tween should last for.
     * @param types    The types and eases for the group to tween with.
     */
    public static function tweenSpriteGroup(group:FlxTypedGroup<FlxSprite>, options:Dynamic, duration:Float, types:Dynamic):Void {
        for (obj in group.members) {  
            if (obj != null) {            
                FlxTween.tween(obj, options, duration, types);
            }
        }
    }

    public static function getSpriteGroupWidthAndHeight(group:FlxGroup):Array<Float> {
        var minX:Float = Math.NEGATIVE_INFINITY;
        var minY:Float = Math.NEGATIVE_INFINITY;
        var maxX:Float = Math.POSITIVE_INFINITY;
        var maxY:Float = Math.POSITIVE_INFINITY;

        for (spr in group.members) {
            var s:FlxSprite = cast(spr, FlxSprite);
            if (s != null) {
                minX = Math.min(minX, s.x);
                minY = Math.min(minY, s.y);
                maxX = Math.max(maxX, s.x);
                maxY = Math.max(maxY, s.y);
            }
        }

        return [
            (minX + maxX) / 2,
            (minY + maxY) / 2
        ];
    }

    public static function getNoteLaneWidth(group:FlxTypedGroup<NoteLane>):Float {
        var toReturn:Float = 0;
        for (s in group.members) {
            toReturn += s.width;
        }
        return toReturn;
    }

    public static function resetHitsArray():Void {
        for (i in 0...CacheUtil.hits.length) {
            CacheUtil.hits[i] = 0;
        }
    }

    public static function getLastKeyPressed():FlxKey {
        var lastKey:FlxKey = FlxKey.NONE;
        for (key in 9...303) {
            if (FlxG.keys.anyJustPressed([key])) {
                lastKey = key;
                break; // Stop after finding the first one this frame
            }
        }
        return lastKey;
    }

    public static function getBindPrefix(bind:String):String {
        for (i in 0...bind.length) {
            if (bind.charAt(i) == '_') {
                return bind.substr(0, i);
            }
        }
        return '';
    }

    /**
     * Closes the entire game.
     */
    public static function closeGame():Void {
        // Save all of the user's data
        SaveUtil.saveAll();
        // Close the game respectfully
        #if html5
        Browser.window.close();
        #elseif desktop
        Sys.exit(0);
        #end
    }
}
