package substates.options;

import backend.data.ClientPrefs;
import backend.util.PathUtil;
import objects.ui.options.OptionAction;
import flixel.FlxG;
import objects.ui.options.OptionControl;
import objects.substates.OptionsDisplaySubState;

class ControlsOptionsSubState extends OptionsDisplaySubState {
    
    public function addOptions() {
        var newY:Float = (FlxG.height / 2);
        _selectionList.add(new OptionControl(20, newY, 'Strum 1', 's_left'));
        _selectionList.add(new OptionControl(20, newY + 200, 'Strum 2', 's_down'));
        _selectionList.add(new OptionControl(20, newY + 400, 'Strum 3', 's_up'));
        _selectionList.add(new OptionControl(20, newY + 600, 'Strum 4', 's_right'));
        _selectionList.add(new OptionControl(20, newY + 800, 'UI Left', 'ui_left'));
        _selectionList.add(new OptionControl(20, newY + 1000, 'UI Down', 'ui_down'));
        _selectionList.add(new OptionControl(20, newY + 1200, 'UI Up', 'ui_up'));
        _selectionList.add(new OptionControl(20, newY + 1400, 'UI Right', 'ui_right'));
        _selectionList.add(new OptionControl(20, newY + 1600, 'UI Select', 'ui_select'));
        _selectionList.add(new OptionControl(20, newY + 1800, 'UI Pause/Back', 'ui_back'));
        _selectionList.add(new OptionControl(20, newY + 2000, 'Increase Volume', 'v_up'));
        _selectionList.add(new OptionControl(20, newY + 2200, 'Decrease Volume', 'v_down'));
        _selectionList.add(new OptionControl(20, newY + 2400, 'Mute Volume', 'v_mute'));
        _selectionList.add(new OptionControl(20, newY + 2600, 'Fullscreen', 'm_fullscreen'));
        _selectionList.add(new OptionAction(20, newY + 2800, 'Reset Controls', () -> {
            FlxG.sound.play(PathUtil.ofSound('select'));
            ClientPrefs.resetControls();
        }));
    }
}
