package backend.util;

import flixel.FlxG;

/**
 * Utility class that creates and returns paths to assets or other files.
 */
final class PathUtil {

    private function new() {}
    
    /**
     * Get the path of an image asset.
     * 
     * @param name The name of the image (this does not include the file extension).
     * @return     The path of the image.
     */
    public static inline function ofImage(name:String):String {
        return 'assets/shared/images/$name.png';
    }

    /**
     * Get the path of a JSON asset.
     * 
     * @param name The name of the JSON file (this does not include the file extension).
     * @return     The path of the JSON file.
     */
    public static inline function ofJson(name:String):String {
        return 'assets/shared/data/$name.json';
    }

    /**
     * Get the path of a font asset that is of format `.ttf`.
     * 
     * @param name The name of the font (this does not include the file extension).
     * @return     The path of the font.
     */
    public static inline function ofFont(name:String):String {
        return 'assets/fonts/$name.ttf';
    }

    /**
     * Get the path of a sound effect asset.
     * 
     * @param name The name of the sound effect (this does not include the file extension).
     * @return     The path of the sound effect.
     */
    public static inline function ofSound(name:String):String {
        return 'assets/shared/sounds/$name${#if web '.mp3' #else '.ogg' #end}';
    }

    /**
     * Get the path of a music soundtrack asset.
     * 
     * @param name The name of the soundtrack (this does not include the file extension).
     * @return     The path of the soundtrack.
     */
    public static inline function ofMusic(name:String):String {
        return 'assets/shared/music/$name${#if web '.mp3' #else '.ogg' #end}';
    }

    /**
     * Get the path of a song's chart data.
     * 
     * @param name The name of the chart (this does not include the file extension).
     * @return     The path of the chart.
     */
    public static inline function ofChart(name:String):String {
        return 'assets/charts/$name.json';
    }

    /**
     * Get the path of a song music file.
     * 
     * @param name The name of the song (this does not include the file extension).
     * @return     The path of the song.
     */
    public static inline function ofSong(name:String):String {
        return 'assets/songs/$name${#if web '.mp3' #else '.ogg' #end}';
    }

    /**
     * Get the path of a song's background.
     * 
     * @param name The name of the background (this does not include the file extension).
     * @return     The path of the background.
     */
    public static inline function ofBackground(name:String) {
        return 'assets/backgrounds/$name.png';
    }

    /**
     * Get the paths of a sprite sheets' image and `.xml` file.
     * Note that this will return an array of both pathways, with the
     * first element being to the image and the second one being its
     * `.xml` file.
     * 
     * ***WARNING***: The sprite sheets' image and `.xml` file *must*
     * be in the same location or otherwise this function will fail.
     * 
     * @param name The name of the sprite sheet.
     * @return     An array of the paths to the image and the `.xml` file.
     */
    public static inline function ofSpriteSheet(name:String):Array<String> {
        return ['assets/shared/images/spritesheets/$name.png', 'assets/shared/images/spritesheets/$name.xml'];
    }

    /**
     * Get the full pathway to the game's save folder and any extra files and data that may be needed.
     * 
     * @param trailingPath The path to concatenate with the save path.
     * @return             The path of the save folder or file (including anything 
     *                     that was appended after with `trailingPath`).
     */
    @:access(flixel.util.FlxSave.validate)
	public static function getSavePath(trailingPath:String = ''):String {
		var company:String = FlxG.stage.application.meta.get('company');
		var toReturn:String = '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		toReturn += (trailingPath != '') ? '/$trailingPath' : '';  // For making sure there isn't a trailing `/` if there isn't a trailing path
		return toReturn;
	}
}
