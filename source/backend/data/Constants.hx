package backend.data;

import openfl.filters.GlowFilter;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;

/**
 * Class that holds all of the general values that do not change.
 */
final class Constants {

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

    public static final OPTIONS_SAVE_BIND_ID:String = 'options';

    public static final CONTROLS_SAVE_BIND_ID:String = 'controls';

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

    public static final DEFAULT_METADATA:Dynamic = {
		composer: 'Unknown',
		charter: 'Unknown',
		name: 'Unknown'
	};

	public static final TRANSITION_DURATION:Float = 0.2;

    public static final MENU_MUSIC_NAME:String = 'Bit Destroyer';

    public static final CAMERA_ZOOM_DECAY:Float = 1;

	public static final HIT_TYPE_TEXT_DECAY = 0.7;

    public static final HIT_TYPE_TEXT_SHADOW_OFFSET:Int = 60;

	public static final NOTE_LANE_COLORS:Array<FlxColor> = [FlxColor.LIME, FlxColor.BLUE, FlxColor.RED, FlxColor.YELLOW];

	public static final NOTE_LANE_ALPHA_DECAY:Float = 1.5;

    public static final NOTE_DESTROY_DURATION:Float = 0.15;

    public static final DEFAULT_CAM_ZOOM:Float = 1.0;

	public static final DEFAULT_NOTE_LANE_ALPHA:Float = 0.3;

    public static final CAM_ZOOM_MULTIPLIER:Float = 3;

    public static final STRUMLINE_Y_OFFSET:Int = 120;

    public static final NOTE_SIZE:Int = 100;

	public static final NOTE_LANE_WIDTH:Int = 100;

    public static final NOTE_LANE_SPACING:Float = 15;

	public static final MARVELOUS_INDEX:Int = 0;

	public static final SICK_INDEX:Int = 1;

	public static final GREAT_INDEX:Int = 2;

	public static final GOOD_INDEX:Int = 3;

	public static final OKAY_INDEX:Int = 4;

	public static final YIKES_INDEX:Int = 5;

	public static final MISS_INDEX:Int = 6;

    public static final HIT_WINDOW_DISPLAY_TEXTS:Array<String> = ['Marvelous!!!', 'Sick!!', 'Great!', 'Good', 'Okay', 'Yikes', 'Miss'];

	public static final HIT_WINDOW_TEXT_SIZE:Int = 64;

    public static final HIT_WINDOW_DISPLAY_COLORS:Array<FlxColor> = [FlxColor.BLUE, FlxColor.CYAN, FlxColor.LIME, FlxColor.GREEN, FlxColor.ORANGE, FlxColor.RED, FlxColor.GRAY];

	public static final HIT_WINDOW_OFFSETS:Array<Float> = [30.0, 50.0, 70.0, 90.0, 100.0, 120.0]; // In the order of "Marvelous!!!", "Sick!!", "Great!", "Good", "Okay", "Yikes"

    public static final NEW_HIT_NOTES_ARRAY:Array<Int> = [0, 0, 0, 0, 0, 0, 0];

    private function new() {}
}
