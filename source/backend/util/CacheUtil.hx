package backend.util;

/**
 * Class that holds general, temporary data for pretty much anything.
 * Examples of general temporary data can be things such as the last volume used.
 */
final class CacheUtil {
    
    /**
     * The last volume that the player had set before the game loses focus.
     */
    public static var lastVolumeUsed:Float;

	/**
	 * Is the game's window focused?
	 */
	public static var isWindowFocused:Bool = true;

    /**
     * Can the game play menu music when the user leaves gameplay?
     */
    public static var canPlayMenuMusic:Bool = true;

    private function new() {}
}
