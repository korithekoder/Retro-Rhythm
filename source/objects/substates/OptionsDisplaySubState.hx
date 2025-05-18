package objects.substates;

import backend.util.PathUtil;
import backend.Controls;
import flixel.FlxG;
import objects.ui.OptionSelectionList;
import flixel.FlxSubState;

abstract class OptionsDisplaySubState extends FlxSubState {

    private var _selectionList:OptionSelectionList;

    override function create() {
        super.create();

        _selectionList = new OptionSelectionList(SelectionScrollType.STICK_OUT, SelectionAlignType.LEFT, 200);
        add(_selectionList);

        addOptions();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

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
