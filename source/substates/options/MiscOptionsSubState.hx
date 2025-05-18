package substates.options;

import objects.ui.options.OptionNumberScroller;
import flixel.FlxG;
import objects.ui.options.OptionCheckBox;
import objects.substates.OptionsDisplaySubState;

class MiscOptionsSubState extends OptionsDisplaySubState {
    
    public function addOptions() {
        var newY:Float = (FlxG.height / 2);
        _selectionList.add(new OptionCheckBox(20, newY, 'Minimize Volume on Lost Focus', 'minimizeVolume'));
        _selectionList.add(new OptionCheckBox(20, newY + 200, 'Unpause Countdown', 'unpauseCountdown'));
        _selectionList.add(new OptionNumberScroller(20, newY + 400, 'Unpause Countdown Time', 'unpauseCountdownTime', 1, 10, 1, 0, false));
    }
}
