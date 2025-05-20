package substates.options;

import objects.ui.options.OptionNumberScroller;
import objects.ui.options.OptionCheckBox;
import flixel.FlxG;
import backend.data.ClientPrefs.ScrollType;
import objects.ui.options.OptionStringScroller;
import objects.substates.OptionsDisplaySubState;

class GameplayOptionsSubState extends OptionsDisplaySubState {
    
    public function addOptions() {
        var newY:Float = (FlxG.height / 2);
        _selectionList.add(new OptionStringScroller(20, newY, 'Scroll Type', 'scrollType', [ScrollType.DOWNSCROLL, ScrollType.UPSCROLL]));
        _selectionList.add(new OptionCheckBox(20, newY + 200, 'Play Sound on Note Hit', 'noteHitSound'));
        _selectionList.add(new OptionNumberScroller(20, newY + 400, 'Note Hit Sfx Volume', 'hitSoundVolume', 0.1, 1.0, 0.1, 0, true));
        _selectionList.add(new OptionCheckBox(20, newY + 600, 'Note Lane Flash', 'noteLaneFlash'));
        _selectionList.add(new OptionCheckBox(20, newY + 800, 'Note Hit Splashes', 'showHitSplash'));
        _selectionList.add(new OptionCheckBox(20, newY + 1000, 'Hide Mouse During Gameplay', 'hideMouseDuringGameplay'));
    }
}
