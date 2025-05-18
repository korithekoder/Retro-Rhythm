package objects.ui;

import backend.util.PathUtil;
import flixel.FlxG;
import objects.ui.Option;
import backend.Controls;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/**
 * Enum for how a selection list scrolls when the user
 * presses the up/down bind(s).
 */
enum SelectionScrollType {
    DEFAULT;  // Regular scrolling, nothing fancy
    STICK_OUT;  // Makes the selected option "stick out", similar to the options on the options menu
    NONE;  // No scrolling at all (might depreciate later since you can just make individual clickable texts :p)
}

/**
 * Enum for how the options in a selection list are aligned.
 */
enum SelectionAlignType {
    LEFT;
    RIGHT;
}

/**
 * Object that displays a list of clickable and selectable options.
 */
class OptionSelectionList extends FlxTypedGroup<Option> {
    
    /**
     * How `this` selection list scrolls.
     */
    public var scrollType:SelectionScrollType;

    /**
     * The way that `this` selection list gets aligned.
     */
    public var alignType:SelectionAlignType;

    /**
     * How far apart each option is spaced apart. 
     * This is also used for changing how far `this` selection list scrolls.
     */
    public var spacing:Float;

    /**
     * How long it takes to scroll through each option.
     */
    public var scrollDuration:Float;

    /**
     * The currently hovered over option in `this` selection list.
     */
    public var currentSelected(get, never):Int;
    private var _currentSelected:Int = 0;
    
    private var _canScroll:Bool = true;
    private var _originalOrigins:Map<Option, Array<Float>> = [];

    /**
     * Constructor.
     * 
     * @param scrollType     How `this` selection list scrolls.
     * @param alignType      The way that `this` selection list gets aligned.
     * @param spacing        How far apart each option is spaced apart. This is also used
     *                       for changing how far `this` selection list scrolls.
     * @param scrollDuration How long it takes to scroll through each option.
     */
    public function new(scrollType:SelectionScrollType, alignType:SelectionAlignType, spacing:Float, scrollDuration:Float = 0.1) {
        super();
        this.scrollType = scrollType;
        this.alignType = alignType;
        this.spacing = spacing;
        this.scrollDuration = scrollDuration;
    }

    // ------------------------------
    //      GETTERS AND SETTERS
    // ------------------------------

    @:noCompletion
    public function get_currentSelected():Int {
        return this._currentSelected;
    }

    // -----------------------------
    //            METHODS
    // -----------------------------

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (this.members.length == 0) return;

        if (this.scrollType != SelectionScrollType.NONE) {
            if (Controls.getBinds().UI_UP_JUST_PRESSED) {
                _scrollThroughOptions(1);
            } else if (Controls.getBinds().UI_DOWN_JUST_PRESSED) {
                _scrollThroughOptions(-1);
            }

            if (FlxG.mouse.wheel != 0) {
                // Scroll through the options based on the mouse wheel movement
                if (FlxG.mouse.wheel > 0) {
                    _scrollThroughOptions(1);
                } else {
                    _scrollThroughOptions(-1);
                }
            }

            if (Controls.getBinds().UI_SELECT_JUST_PRESSED || FlxG.mouse.justPressed && members[_currentSelected].isFocused) {
                this.members[this._currentSelected].onSelected();
            }
        }
    }

    override function add(basic:Option):Option {
        
        this._originalOrigins.set(basic, []);

        for (mbr in basic.members) {
            this._originalOrigins.get(basic).push(mbr.x);
        }

        super.add(basic);

        if (members.length == 1) {
            this.members[0].isFocused = true;
            // For each object contained in each option
            var mbrIdx:Int = 0;
            for (o in basic) {
                // The new x value (for tweening each option back and forth when the STICK_OUT type is used)
                var newX:Float;
                if (this.scrollType == SelectionScrollType.STICK_OUT) {
                    // Tween the object to the side if the scroll type is STICK_OUT
                    newX = o.x + ((this.alignType == SelectionAlignType.LEFT) ? 120 : -120);
                } else {
                    // Get the original X position for the current option member
                    newX = this._originalOrigins.get(basic)[mbrIdx];
                }
                // The properties to tween
                var options:Dynamic = {
                    x: newX
                    // y: o.y + ((dir < 0) ? spacing * -1 : spacing) 
                };
                // Tween the current object in the looped option
                FlxTween.tween(o, options, this.scrollDuration, { type: FlxTweenType.PERSIST, ease: FlxEase.quadOut });
                mbrIdx++;
            }
        }

        return basic;
    }

    private function _scrollThroughOptions(dir:Int):Void {
        // To prevent the user from spamming the up/down buttons and breaking shit
        if (!this._canScroll) return;

        // To prevent index out of bounds errors
        if (dir > 0) {
            if (this._currentSelected <= 0) return; 
        } else {
            if (this._currentSelected >= this.members.length - 1) return; 
        }

        this._canScroll = false;
        this._currentSelected += (dir < 0) ? 1 : -1;

        for (m in 0...members.length) {
            if (m == this._currentSelected) {
                this.members[m].isFocused = true;
            } else {
                this.members[m].isFocused = false;
            }
        }

        // For each option and its group
        var idx:Int = 0;  
        for (optn in this.members) {
            // For each object contained in each option
            var mbrIdx:Int = 0;
            for (o in optn.members) {
                // The new x value (for tweening each option back and forth when the STICK_OUT type is used)
                var newX:Float;
                if ((this.scrollType == SelectionScrollType.STICK_OUT) && (idx == this._currentSelected)) {
                    // Tween the object to the side if the scroll type is STICK_OUT
                    newX = o.x + ((this.alignType == SelectionAlignType.LEFT) ? 120 : -120);
                } else {
                    // Get the original X position for the current option member
                    newX = this._originalOrigins.get(optn)[mbrIdx];
                }
                // The properties to tween
                var options:Dynamic = {
                    x: newX,
                    y: o.y + ((dir < 0) ? spacing * -1 : spacing) 
                };
                // Tween the current object in the looped option
                FlxTween.tween(o, options, this.scrollDuration, { type: FlxTweenType.PERSIST, ease: FlxEase.quadOut });
                mbrIdx++;
            }
            idx++;
        }

        // Play a sound
        FlxG.sound.play(PathUtil.ofSound('blip'));
        // Start a timer that allows the user to scroll again (for preventing spamming)
        new FlxTimer().start(this.scrollDuration, (_) -> { this._canScroll = true; });
    }
}
