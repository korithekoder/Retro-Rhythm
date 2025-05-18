package objects.substates;

import backend.util.PathUtil;
import backend.Controls;
import flixel.FlxG;
import objects.ui.OptionSelectionList;
import flixel.FlxSubState;

abstract class OptionsDisplaySubState extends FlxSubState {
    
    /**
     * An array of arrays with strings that hold the display name
     * and client preference ID for each option.
     * 
     * The first element is the display name, and the second element
     * is the ID of the client preference to change. 
     */
    public var options(get, set):Array<Array<String>>;
    private var _options:Array<Array<String>>;

    private var _selectionList:OptionSelectionList;

    @:noCompletion
    public function get_options():Array<Array<String>> {
        return _options;
    }

    @:noCompletion
    public function set_options(value:Array<Array<String>>):Array<Array<String>> {
        _options = value;
        return _options;
    }

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
