package backend.data;

import backend.util.PathUtil;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;

/**
 * Enum for determining which way the notes fall.
 */
enum ScrollType {
    DOWNSCROLL;
    UPSCROLL;
}

/**
 * Private class that holds all of the user's options.
 */
@:structInit class SaveVariables {

    /**
     * Should the game minimize its volume when the window is out of focus?
     */
    public var minimizeVolume:Bool = true;

    /**
     * Does the user have fullscreen enabled?
     */
    public var fullscreen:Bool = false;

    /**
     * Which way the notes fall.
     */
    public var scrollType:ScrollType = DOWNSCROLL;

    /**
     * Should a note play a sound when it is hit?
     */
    public var noteHitSound:Bool = false;

    /**
     * Should the note lanes flash when their set bind is pressed?
     */
    public var noteLaneFlash:Bool = true;

    /**
     * How loud the hit sound volume is.
     */
    public var hitSoundVolume:Float = 1.0;

    /**
     * Should the game show a splash effect when a note is hit?
     */
    public var showHitSplash:Bool = true;

    /**
     * Should the game have a small cooldown when the game is unpaused?
     */
    public var unpauseCountdown:Bool = false;

    /**
     * How long the unpause countdown is in seconds.
     */
    public var unpauseCountdownTime:Int = 3;

    /**
     * Should the mouse be hidden while the user is playing the game?
     */
    public var hideMouseDuringGameplay:Bool = true;

    /**
     * How transparent the note lanes are when they are not pressed.
     */
    public var noteLaneBaseAlpha:Float = 0.5;

    /**
     * Pretty self explanatory, hm?
     */
    public var fps:Int = 60;
}

/**
 * Class that handles, modifies and stores the user's
 * preferences and settings.
 * 
 * When you are updating a setting, do *NOT* do it
 * manually. Instead, use `setClientPreference()` to update a user's preference(s)
 * or `setClientControl()` to change a bind.
 * 
 * Controls are saved in their own variable, *NOT* in `options`.
 * 
 * The way controls are created is with this structure: `'keybind_id' => FlxKey.YOUR_KEY`.
 * To create a control, go to `backend.data.Constants`, search for `DEFAULT_CONTROLS_KEYBOARD`
 * and then add your controls accordingly.
 * 
 * To access controls, use `backend.Controls`. (**TIP**: Read `backend.Controls`'s
 * documentation for accessing if binds are pressed!)
 */
final class ClientPrefs {

    /**
     * The user's settings and preferences. Note that this does not include
     * the user's controls, that is in its own respective variable.
     */
    public static var options(get, never):SaveVariables;
    private static var _options:SaveVariables = {};

    /**
     * Default options for the game.
     */
    public static var defaultOptions(get, never):SaveVariables;
    private static var _defaultOptions:SaveVariables = {};

	/**
	 * Controls set by the user for the keyboard.
	 */
    public static var controlsKeyboard(get, never):Map<String, FlxKey>;
	private static var _controlsKeyboard:Map<String, FlxKey>;

    private function new() {}

    // ------------------------------
    //      GETTERS AND SETTERS
    // ------------------------------

    @:noCompletion
    public static inline function get_options():SaveVariables {
        return _options;
    }

    @:noCompletion
    public static inline function get_controlsKeyboard():Map<String, FlxKey> {
        return _controlsKeyboard;
    }

    @:noCompletion
    public static inline function get_defaultOptions():SaveVariables {
        return _defaultOptions;
    }

    // -----------------------------
    //            METHODS
    // -----------------------------

    /**
     * Get and return a client preference by its ID.
     * 
     * @param preference The preference to get as a `String`.
     * @return           The value of the preference. If it does not exist, then
     *                   `null` is returned instead.
     */
    public static inline function getClientPreference(preference:String):Any {
        return Reflect.field(_options, preference);
    }

    /**
     * Sets a client's preference.
     * 
     * @param setting The setting to be set.
	 * @param value   The value to set it to.
     */
	public static function setClientPreference(setting:String, value:Dynamic):Void {
        try {
			Reflect.setField(_options, setting, value);
        } catch (e:Exception) {
            FlxG.log.error("Attempted to change non-existent option \"" + setting + "\".");
            throw new Exception("No such client preference as \"" + setting + "\".");
        }
    }

    /**
     * Set a specific key bind for the user.
     * 
     * @param bindId The bind to be set.
     * @param newKey The key to set it to.
     */
	public static function setClientControl(bindId:String, newKey:FlxKey):Void {
        if (_controlsKeyboard.exists(bindId)) {
			_controlsKeyboard.set(bindId, newKey);
        } else {
            FlxG.log.error("Attempted to change non-existent bind \"" + bindId + "\".");
            throw new Exception("No such bind as \"" + bindId + "\".");
        }
    }

    /**
     * Load and obtain all of the user's options and controls.
     */
    public static function loadAll():Void {
        // Create the binds
        var optionsData:FlxSave = new FlxSave();
        var controlsData:FlxSave = new FlxSave();

        // Connect to the saves
        optionsData.bind(Constants.OPTIONS_SAVE_BIND_ID, PathUtil.getSavePath());
        controlsData.bind(Constants.CONTROLS_SAVE_BIND_ID, PathUtil.getSavePath());

        // Load options
        if (optionsData.data.options != null)
            _options = optionsData.data.options;
        else
            _options = _defaultOptions;

        // Set the game to fullscreen if option is ON
		FlxG.fullscreen = options.fullscreen;

        // Load controls
        if (controlsData.data.keyboard != null)
            _controlsKeyboard = controlsData.data.keyboard;
        else
            _controlsKeyboard = Constants.DEFAULT_CONTROLS_KEYBOARD;

        // Load any options that may not be present
        // for (key in Reflect.fields(_defaultOptions)) {
        //     if (!Reflect.hasField(_options, key)) {
        //         Reflect.setField(_options, key, Reflect.field(_defaultOptions, key));
        //         FlxG.log.add('Added missing option "' + key + '" with default value.');
        //     }
        // }

        // Set the volume keys
        FlxG.sound.volumeUpKeys = [controlsKeyboard.get('v_up')];
        FlxG.sound.volumeDownKeys = [controlsKeyboard.get('v_down')];
        FlxG.sound.muteKeys = [controlsKeyboard.get('v_mute')];

        // Check if the user has any new controls
        // (this is for when new controls are added in an update!)
        for (key in Constants.DEFAULT_CONTROLS_KEYBOARD.keys()) {
            if (!_controlsKeyboard.exists(key)) {
                _controlsKeyboard.set(key, Constants.DEFAULT_CONTROLS_KEYBOARD.get(key));
            }
        }

        // Set the volume to the last used volume the user had
        if (optionsData.data.lastVolume != null)
            FlxG.sound.volume = optionsData.data.lastVolume;
        else
            FlxG.sound.volume = 1.0;

        FlxG.log.add('Loaded all client preferences and controls successfully!');

        // Respectfully close the saves to prevent data leaks
        optionsData.close();
        controlsData.close();
    }

    /**
     * Reset the user's controls to the default ones.
     */
    public static function resetControls():Void {
        for (key in Constants.DEFAULT_CONTROLS_KEYBOARD.keys()) {
            _controlsKeyboard.set(key, Constants.DEFAULT_CONTROLS_KEYBOARD.get(key));
        }
    }
}
