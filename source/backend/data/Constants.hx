package backend.data;

import flixel.input.keyboard.FlxKey;

/**
 * Class that holds all of the general values that do not change.
 */
final class Constants {
    
    /**
	 * The default controls for the player. This is typically used when
     * the player wishes to reset all of their binds.
     */
	public static final DEFAULT_CONTROLS_KEYBOARD:Map<String, FlxKey> = [
        // Strumline
        's_left'     => FlxKey.D,
        's_down'     => FlxKey.F,
        's_up'       => FlxKey.J,
        's_right'    => FlxKey.K,

        // Volume
        'v_up'       => FlxKey.PLUS,
        'v_down'     => FlxKey.MINUS,
        'v_mute'     => FlxKey.F12,

        // Misc.
        'fullscreen' => FlxKey.F11
    ];
    
    /**
     * The name of the save file for the player's options.
     */
    public static final OPTIONS_SAVE_BIND_ID:String = 'options';

    /**
     * The name of the save file for the player's controls.
     */
    public static final CONTROLS_SAVE_BIND_ID:String = 'controls';

    /**
     * The splash texts that are displayed on the main menu.
     * Each array contains two strings that are displayed on the screen.
     * Note that any extra strings after the first two will be ignored.
     */
    public static final SPLASH_TEXTS:Array<Array<String>> = [
        ['we gonna do', 'this thang'],
        ['bruh', 'moment'],
        ['I', 'AM STEVE'],
        ['THIS...', 'is an  E N D E R  P E A R L'],
        ['CHICKEN JOCKEY', 'asl fqeflQKH FQKEH ADsff'],
		['i am gonna', 'tickle your toes :3'],
        ['why the fuck', 'are you playing this game??'],
        ['friday night funkin', 'peak rhythm game imo'],
        ['you\'re dead built', 'like an apple'],
        ['you\'re dead built', 'like a *insert main subject of convo here*'],
        ['swag shit', 'money money'],
        ['uwu', 'owo'],
        ['i would like my check please', 'give it to me right  N E O W'],
        ['if you\'re reading this', 'you like men'],
        ['eeeeeeeuuuuuuuuuuuuuu', 'mmmmmmhhhhhhhhhh'],
        ['eeeeeeeeeeeeeeeeeeeeeeeee', 'eeeeeeeeeeeeeeeeeeeeeeeee'],
        ['i\'m gonna crash', 'the fuck out'],
        ['inspired by', 'noobs in combat'],
        ['where is', 'my goddamn money'],
        ['how do you 20 pairs of pants', 'and 3 pairs of underwear?!'],
        ['"please don\'t scam meeeeeeeee"', '-dfam 3/14/2025'],
        ['"be a good kitty and stop running away"', '-kori 3/8/2025'],
        ['"little goober, STOP" -kori', '"did you say little GOONER?!" -vixen'],
        ['"*skibidi"', '-kori 3/1/2025'],
        ['"get your twink out of my house of god"', '-kira 2/24/2025'],
        ['"CUMpany"', '-dfam 2/21/2025'],
        ['"YOUCH!! *says in a zesty tone*"', '-dfam 3/16/2025'],
        ['erm', 'what the sigma'],
        ['skibidi', 'rizzler'],
        ['"19 dola hairbrush, who wants it?"', '-dfam'],
		['"SHUUTT SHUUUPUPUPUPP"', '-kori 4/4/2025'],
		['monopoly', 'such a gruesome game fr']
    ];

    /**
     * How long it takes for the fade effect to last when switching states.
     */
    public static final TRANSITION_DURATION:Float = 0.4;

    /**
	 * Name of the music that plays when in the main menus.
     */
    public static final MENU_MUSIC_NAME:String = 'Bit Destroyer';

    private function new() {}
}
