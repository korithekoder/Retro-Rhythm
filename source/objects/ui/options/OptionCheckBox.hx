package objects.ui.options;

import backend.util.SaveUtil;
import backend.data.Constants;
import backend.data.ClientPrefs;
import flixel.FlxG;
import backend.util.PathUtil;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;

/**
 * Object for creating an option that is of type `Bool`.
 * (This is displayed as a checkbox, obviously.)
 */
class OptionCheckBox extends Option {

    private var _isChecked:Bool = false;

    private var _checkmarkSymbol:FlxSprite;
    private var _displayText:ClickableText;

    private var _isValidBoolPref:Bool;

    private var _callback:Void->Void;

    /**
     * Constructor.
     * 
     * @param x           The X coordinate of the checkbox.
     * @param y           The Y coordinate of the checkbox.
     * @param name        The name of the checkbox.
     * @param option      The option key associated with the checkbox. 
     *                    (This is the preference ID that is made in `SaveVariables` in `backend.data.ClientPrefs`.)
     * @param description A description of the checkbox (default is '[No Description Set]').
     */
    public function new(x:Float, y:Float, name:String, option:String, canBeClickedOn:Bool = false, callback:Void->Void = null, description:String = '[No Description Set]') {

        this._isValidBoolPref = Type.typeof(Reflect.field(ClientPrefs.options, 'noteHitSound')) == TBool;
        this._isChecked = (this._isValidBoolPref) ? ClientPrefs.getClientPreference(option) : false;

        super(name, option, description);

        this._callback = callback;

        this._checkmarkSymbol = new FlxSprite();
        this._checkmarkSymbol.loadGraphic(PathUtil.ofImage((this._isValidBoolPref) ? (_isChecked) ? 'checked' : 'unchecked' : 'unchecked'));
        this._checkmarkSymbol.scale.set(5, 5);
        this._checkmarkSymbol.updateHitbox();
        this._checkmarkSymbol.x = x;
        this._checkmarkSymbol.y = y;

        this._displayText = new ClickableText();
        this._displayText.text = (this._isValidBoolPref) ? name : 'OPTION "$option" IS NOT A VALID BOOLEAN';
        this._displayText.color = FlxColor.WHITE;
        this._displayText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
        this._displayText.size = Constants.OPTION_DISPLAY_TEXT_SIZE;
        this._displayText.updateHitbox();
        this._displayText.x = (this._checkmarkSymbol.x + this._checkmarkSymbol.width) + 10;
        this._displayText.y = (this._checkmarkSymbol.y) + (this._checkmarkSymbol.height - this._displayText.height);
        this._displayText.updateHoverBounds();
        this._displayText.onClick = (canBeClickedOn) ? onSelected : () -> {};

        this.add(this._checkmarkSymbol);
        this.add(this._displayText);
    }

    public function onSelected():Void {
        if (this._isValidBoolPref) {
            this._isChecked = !this._isChecked;
            ClientPrefs.setClientPreference(this._option, this._isChecked);
            this._checkmarkSymbol.loadGraphic(PathUtil.ofImage((_isChecked) ? 'checked' : 'unchecked'));
            this._checkmarkSymbol.updateHitbox();
            FlxG.sound.play(PathUtil.ofSound((_isChecked) ? 'select' : 'unselect'), 0.8);
            if (_callback != null) _callback();
            this._isChecked = ClientPrefs.getClientPreference(option);
            SaveUtil.saveUserOptions();
        } else {
            FlxG.camera.shake(0.03, 0.1);
            FlxG.sound.play(PathUtil.ofSound('nope'));
        }
    }
}
