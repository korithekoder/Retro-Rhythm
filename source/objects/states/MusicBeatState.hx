package objects.states;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

abstract class MusicBeatState extends FlxTransitionableState {
    
	public var beatsBeforeHit:Int = 4;

    var songBPM:Int;
    var songCamZoomIntensity:Float;

    var beatDuration:Float;
	var beatDurationMS:Float;
	var beatCounter:Int = 0;
	var lastBeat:Int = -1;

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        // Handle beat logic
		var currentBeat:Int = Math.floor(FlxG.sound.music.time / beatDurationMS);
		if (currentBeat != lastBeat) {
			lastBeat = currentBeat;
			beatCounter++;
			if (beatCounter % beatsBeforeHit == 0) {
				beatHit();
			}
		}
    }

    abstract public function beatHit():Void;
}
