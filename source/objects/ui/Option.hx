package objects.ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * Object used for creating new options. Note that this class is `abstract` because
 * it is intended to be extended to and create other kinds of options!
 */
abstract class Option extends FlxTypedGroup<FlxSprite> {
    
    /**
     * The name of the option.
     */
    public var name(get, never):String;
    private var _name:String;

    /**
     * The client preference to change when `this` option changes.
     * (Some examples might be `dialogueAnimations`, `discordRPC`, etc.)
     */
    public var option(get, never):String;
    private var _option:String;

    /**
     * A brief description of the option.
     */
    public var description(get, never):String;
    private var _description:String;

    /**
     * Whether or not the option is currently focused.
     */
    public var isFocused(get, set):Bool;
    private var _isFocused:Bool = false;

    /**
     * Constructor.
     * 
     * @param name        The name of the option.
     * @param option      The value or identifier of the option.
     * @param description A brief description of the option.
     */
    public function new(name:String, option:String, description:String) {
        super();
        this._name = name;
        this._option = option;
        this._description = description;
    }

    // ------------------------------
    //      GETTERS AND SETTERS
    // ------------------------------

    @:noCompletion
    public inline function get_name():String {
        return this._name;
    }

    @:noCompletion
    public inline function get_option():String {
        return this._option;
    }

    @:noCompletion
    public inline function get_description():String {
        return this._description;
    }

    @:noCompletion
    public inline function get_isFocused():Bool {
        return this._isFocused;
    }

    @:noCompletion
    public inline function set_isFocused(value:Bool):Bool {
        this._isFocused = value;
        return this._isFocused;
    }

    // -----------------------------
    //            METHODS
    // -----------------------------

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (isFocused) {
            return;
        }
    }

    /**
     * A callback function to be executed when the option is selected.
     */
    public abstract function onSelected():Void;
}
