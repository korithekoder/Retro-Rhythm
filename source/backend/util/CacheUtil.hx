package backend.util;

/**
 * Class that holds general, temporary data for pretty much anything.
 * Examples of general temporary data can be things such as the last volume used.
 */
final class CacheUtil {
    
    public static var lastVolumeUsed:Float;

	public static var isWindowFocused:Bool = true;

    public static var canPlayMenuMusic:Bool = true;

    public static var score:Int = 0;

    public static var hits:Array<Int> = [0, 0, 0, 0, 0, 0, 0];

    private function new() {}
}
