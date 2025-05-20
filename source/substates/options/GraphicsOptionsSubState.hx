package substates.options;

import objects.ui.options.OptionNumberScroller;
import backend.data.ClientPrefs;
import flixel.FlxG;
import objects.ui.options.OptionCheckBox;
import objects.substates.OptionsDisplaySubState;

class GraphicsOptionsSubState extends OptionsDisplaySubState {
    
    public function addOptions() {
        var newY:Float = (FlxG.height / 2);
        _selectionList.add(new OptionNumberScroller(20, newY, 'FPS', 'fps', 10, 240, 10, 0, false, () -> {
            FlxG.updateFramerate = ClientPrefs.options.fps;
            FlxG.drawFramerate = ClientPrefs.options.fps;
        }));
        _selectionList.add(new OptionCheckBox(20, newY + 200, 'Fullscreen', 'fullscreen', () -> {
            FlxG.fullscreen = !FlxG.fullscreen;
            ClientPrefs.options.fullscreen = FlxG.fullscreen;
        }));
    }
}
