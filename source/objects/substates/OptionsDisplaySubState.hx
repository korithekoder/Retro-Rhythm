package objects.substates;

import flixel.util.FlxColor;
import backend.data.ClientPrefs;
import flixel.text.FlxText;
import backend.util.PathUtil;
import backend.Controls;
import flixel.FlxG;
import objects.ui.OptionSelectionList;
import flixel.FlxSubState;

abstract class OptionsDisplaySubState extends FlxSubState {

    private var _selectionList:OptionSelectionList;
    private var _controlsHint:FlxText;

    override function create() {
        super.create();

        _selectionList = new OptionSelectionList(SelectionScrollType.STICK_OUT, SelectionAlignType.LEFT, 200);
        add(_selectionList);

        addOptions();

        _controlsHint = new FlxText();
        _controlsHint.color = FlxColor.WHITE;
        _controlsHint.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        _controlsHint.size = 40;
        _controlsHint.alpha = 0.5;
        _controlsHint.updateHitbox();
        _controlsHint.setPosition(0, FlxG.height - _controlsHint.height);
        add(_controlsHint);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        _controlsHint.text = 'Press ${ClientPrefs.controlsKeyboard.get('ui_up')}/${ClientPrefs.controlsKeyboard.get('ui_down')} or Scroll Wheel to Scroll...';
        _controlsHint.updateHitbox();
        _controlsHint.setPosition(0, FlxG.height - _controlsHint.height);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            close();
        }
    }

    /**
     * Abstract function that is intended to be overridden to 
     * add the options to the display.
     */
    public abstract function addOptions():Void;
}
