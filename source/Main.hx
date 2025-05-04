package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {

	private static final _GAME:Dynamic = {
		width: 1280,
		height: 720,
		initState: InitState,
		framerate: 60,
		skipSplash: false,
		startFullscreen: false
	};

	public function new() {
		super();
		addChild(new FlxGame(
			_GAME.width,
			_GAME.height,
			_GAME.initState,
			_GAME.framerate,
			_GAME.framerate,
			_GAME.skipSplash,
			_GAME.startFullscreen
		));
	}
}
