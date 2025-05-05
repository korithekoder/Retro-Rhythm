package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import backend.data.Constants;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxState;

class PlayState extends FlxTransitionableState {

	var test:FlxText;
	
	override public function create() {
		super.create();
		test = new FlxText();
		test.text = 'OMMGGGGGGGGGGGG CAMERA ZOOMJING!!!1!!\n(Press space lmao)';
		test.alignment = FlxTextAlign.CENTER;
		test.color = FlxColor.WHITE;
		test.size = 128;
		test.updateHitbox();
		test.x = (FlxG.width / 2) - (test.width / 2);
		test.y = (FlxG.height / 2) - (test.height / 2);
		add(test);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));

		if (FlxG.keys.justPressed.SPACE) {
			FlxG.camera.zoom += 0.015 * 5;
		}
	}
}
