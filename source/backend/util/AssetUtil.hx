package backend.util;

import haxe.Json;
import openfl.utils.Assets;

/**
 * Utility class for obtaining and manipulating data in files or variables.
 */
final class AssetUtil {
    
    private function new() {}

    /**
     * Gets regular JSON data from the specified file pathway.
     * 
     * @param path The pathway to obtain the JSON data.
     * @return     The data that was obtained from the said file. If it was not found, then `null` is returned instead.
     */
    public static inline function getJsonData(path:String, defaultData:Dynamic = null):Dynamic {
        return (Assets.exists(path)) ? Json.parse(Assets.getText(path)) : defaultData;
    }

    /**
     * Get a dynamic value from a `Dynamic` object. Note that this is meant 
     * for JSON specific objects.
     * 
     * @param object   The JSON `Dynamic` object to obtain the field from.
     * @param field    The field to get.
     * @return         The value found from the said field. If it isn't found, then the
     *                 `defaultValue` parameter is returned instead.
     */
    public static inline function getDynamicField(object:Dynamic, field:String, defaultValue:Any = null):Any {
        return (Reflect.hasField(object, field)) ? Reflect.field(object, field) : defaultValue;
    }

    /**
     * Caches a list of sounds from an `Array`.
     * 
     * @param soundArray The list of the file pathways for each sound file to precache.
     */
    public static function precacheSoundArray(soundArray:Array<String>):Void {
        for (snd in soundArray) {
            Assets.loadSound(snd);
        }
    }
}
