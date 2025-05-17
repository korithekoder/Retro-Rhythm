package substates.options;

import flixel.FlxG;
import objects.ui.options.OptionCheckBox;
import objects.substates.OptionsDisplaySubState;

class MiscOptionsSubState extends OptionsDisplaySubState {
    
    public function addOptions() {
        var newY:Float = (FlxG.height / 2);
        _selectionList.add(new OptionCheckBox(20, newY, 'Minimize Volume on Lost Focus', 'minimizeVolume'));
    }
}
