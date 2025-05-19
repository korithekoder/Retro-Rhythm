package objects.ui.options;

import backend.data.Constants;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class OptionAction extends Option {
    
    private var _callback:Void->Void;
    private var _displayText:FlxText;

    public function new(x:Float, y:Float, name:String, callback:Void->Void, description:String = '[No Description Set]') {
        super(name, '', description);

        this._callback = callback;

        this._displayText = new FlxText();
        this._displayText.text = name;
        this._displayText.color = FlxColor.WHITE;
        this._displayText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
        this._displayText.size = Constants.OPTION_DISPLAY_TEXT_SIZE;
        this._displayText.updateHitbox();
        this._displayText.x = x;
        this._displayText.y = y;
        add(this._displayText);
    }

    public function onSelected() {
        _callback();
    }
}
