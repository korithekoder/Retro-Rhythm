package backend.util;

import backend.data.Constants;

/**
 * Class that holds general, temporary data for pretty much anything.
 * Examples of general temporary data can be things such as the last volume used.
 */
final class CacheUtil {
    
    public static var lastVolumeUsed:Float;

	public static var isWindowFocused:Bool = true;

    public static var canPlayMenuMusic:Bool = true;

    public static var health:Float = Constants.MAX_HEALTH;

    public static var score:Int = 0;

    public static var hits:Array<Int> = [0, 0, 0, 0, 0, 0, 0];

    public static var combo:Int = 0;

    public static var accuracy:Float = Math.NaN;

    public static var totalHitPoints:Int = 0;  // Used for accuracy (this is all of the actual notes that the player)

    public static var realHitPoints:Int = 0;  // Used for accuracy (this is basically if all of the notes were marvelous notes added together)

    public static var botModeEnabled:Bool = false;

    public static var currentSongId:String = '';

    private function new() {}
}
