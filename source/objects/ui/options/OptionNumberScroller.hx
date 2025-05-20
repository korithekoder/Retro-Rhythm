package objects.ui.options;

import backend.util.SaveUtil;
import backend.Controls;
import backend.data.ClientPrefs;
import backend.data.Constants;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionNumberScroller extends Option {

    private var _displayText:FlxText;
    private var _minValue:Float;
    private var _maxValue:Float;
    private var _increment:Float;
    private var _decimalPlaces:Int;
    private var _isPercent:Bool;
    private var _isValidNumOption:Bool;
    private var _callback:Void->Void;
    
    public function new(x:Float, y:Float,  name:String, option:String, minValue:Float, maxValue:Float, increment:Float, decimalPlaces:Int, isPercent:Bool, callback:Void->Void = null, description:String = '[No Description Set]') {
        var clientPreference:Any = ClientPrefs.getClientPreference(option);
        var value:Float;
        if (clientPreference != null) {
            value = (Type.typeof(clientPreference) == TFloat || Type.typeof(clientPreference) == TInt) ? clientPreference : 0;
        } else {
            value = 0;
        }
        this._isValidNumOption = Std.isOfType(clientPreference, Float);

        super(name, option, description);

        this._callback = callback;

        this._increment = increment;
        this._decimalPlaces = decimalPlaces;
        this._isPercent = isPercent;
        this._minValue = minValue;
        this._maxValue = maxValue;

        this._displayText = new FlxText();
        var displayValue:Float = (_isPercent)
                ? FlxMath.roundDecimal(value * 100, 0)
                : FlxMath.roundDecimal(value, _decimalPlaces);
        this._displayText.text = (_isValidNumOption) ? _displayText.text = '${name}: < ${displayValue}${(_isPercent) ? '%' : ''} >' : 'OPTION "${option}" IS NOT A VALID NUMBER';
        this._displayText.size = Constants.OPTION_DISPLAY_TEXT_SIZE;
        this._displayText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
        this._displayText.updateHitbox();
        this._displayText.setPosition(x, y);
        add(_displayText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (isFocused) {
            if (Controls.getBinds().UI_LEFT_JUST_PRESSED) {
                _changeValue(-1);
            } else if (Controls.getBinds().UI_RIGHT_JUST_PRESSED) {
                _changeValue(1);
            }
        }
    }

    public function onSelected():Void {
        _changeValue(1);
    }

    private function _changeValue(multiplier:Int):Void {
        if (_isValidNumOption) {
            FlxG.sound.play(PathUtil.ofSound('blip'), false);
            var value:Float = ClientPrefs.getClientPreference(_option);
            value += _increment * multiplier;

            if (value < _minValue) {
                value = _maxValue;
            } else if (value > _maxValue) {
                value = _minValue;
            }

            ClientPrefs.setClientPreference(_option, value);

            var displayValue = (_isPercent)
                ? FlxMath.roundDecimal(value * 100, 0)
                : FlxMath.roundDecimal(value, _decimalPlaces);
            _displayText.text = '${name}: < ${displayValue}${(_isPercent) ? '%' : ''} >';

            SaveUtil.saveUserOptions();

            if (_callback != null) _callback();
        } else {
            FlxG.camera.shake(0.03, 0.1);
            FlxG.sound.play(PathUtil.ofSound('nope'));
        }
    }
}
