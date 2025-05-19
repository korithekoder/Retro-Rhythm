package objects.ui.options;

import flixel.input.keyboard.FlxKey;
import backend.util.PathUtil;
import flixel.FlxG;
import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import backend.data.Constants;
import flixel.text.FlxText;
import flixel.FlxSprite;
import backend.data.ClientPrefs;

class OptionControl extends Option {
    
    public var isWaitingForInput:Bool = false;

    private var _displayText:FlxText;
    private var _isValidControlPref:Bool;
    private var _bindId:String;
    
    public function new(x:Float, y:Float, bind:String, bindId:String, description:String = '[No Description Set]') {

        this._isValidControlPref = ClientPrefs.controlsKeyboard.exists(bindId);

        super(bind, bindId, description);

        this._displayText = new FlxText();
        this._displayText.text = (this._isValidControlPref) ? '$bind: ${ClientPrefs.controlsKeyboard.get(bindId).toString()}' : 'BIND "$option" DOES NOT EXIST';
        this._displayText.color = FlxColor.WHITE;
        this._displayText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
        this._displayText.size = Constants.OPTION_DISPLAY_TEXT_SIZE;
        this._displayText.updateHitbox();
        this._displayText.setPosition(x, y);

        this.add(this._displayText);
    }

    public function onSelected() {
        if (isFocused) {
            if (!isWaitingForInput) {
                isWaitingForInput = true;
                _displayText.text = '$name: ...';
                FlxG.sound.play(PathUtil.ofSound('blip'));
            } else {
                FlxG.sound.play(PathUtil.ofSound('menu-select'));
            }
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (isWaitingForInput) {
            var key:FlxKey = GeneralUtil.getLastKeyPressed();
            if (key != FlxKey.NONE) {
                isWaitingForInput = false;
                if (this._isValidControlPref) {
                    ClientPrefs.setClientControl(option, key);
                    _displayText.text = '$name: $key';

                    // Ensure the key is not already bound to another action
                    for (bind in ClientPrefs.controlsKeyboard.keys()) {
                        var thisBindPrefix:String = GeneralUtil.getBindPrefix(option);
                        var loopBindPrefix:String = GeneralUtil.getBindPrefix(bind);
                        if (bind != option && ClientPrefs.controlsKeyboard.get(bind) == key && thisBindPrefix == loopBindPrefix) {
                            ClientPrefs.setClientControl(bind, FlxKey.NONE);
                            FlxG.keys.reset();  // Reset all key presses to prevent weird shit from happening
                            break;
                        }
                    }

                    FlxG.sound.volumeUpKeys = [ClientPrefs.controlsKeyboard.get('v_up')];
                    FlxG.sound.volumeDownKeys = [ClientPrefs.controlsKeyboard.get('v_down')];
                    FlxG.sound.muteKeys = [ClientPrefs.controlsKeyboard.get('v_mute')];

                    FlxG.keys.reset();  // Reset all key presses to prevent weird shit from happening

                    FlxG.sound.play(PathUtil.ofSound('select'));
                } else {
                    _displayText.text = 'BIND "$option" DOES NOT EXIST';
                }
            }
        } else if (this._isValidControlPref) {
            _displayText.text = '$name: ${ClientPrefs.controlsKeyboard.get(option).toString()}';
        }
    }
}
