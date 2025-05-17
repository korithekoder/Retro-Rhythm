package substates.options;

import objects.ui.options.OptionNumberScroller;
import objects.ui.options.OptionCheckBox;
import flixel.FlxG;
import backend.data.ClientPrefs.ScrollType;
import objects.ui.options.OptionStringScroller;
import objects.substates.OptionsDisplaySubState;

class GameplayOptionsSubState extends OptionsDisplaySubState {
    
    public function addOptions() {
        options = [
            ['Scroll Type', 'scrollType'],
            ['Play Sound on Note Hit', 'noteHitSound'],
            ['Note Hit Sfx Volume', 'hitSoundVolume'],
            ['Note Lane Flash', 'noteLaneFlash'],
            ['Note Hit Splashes', 'showHitSplash']
        ];

        var newY:Float = (FlxG.height / 2);
        _selectionList.add(new OptionStringScroller(20, newY, options[0][0], options[0][1], [ScrollType.DOWNSCROLL, ScrollType.UPSCROLL]));
        _selectionList.add(new OptionCheckBox(20, newY + 200, options[1][0], options[1][1]));
        _selectionList.add(new OptionNumberScroller(20, newY + 400, options[2][0], options[2][1], 0.1, 1.0, 0.1, 0, true));
        _selectionList.add(new OptionCheckBox(20, newY + 600, options[3][0], options[3][1]));
        _selectionList.add(new OptionCheckBox(20, newY + 800, options[4][0], options[4][1]));
    }
}
