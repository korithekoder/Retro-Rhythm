import backend.Controls;
import openfl.events.KeyboardEvent;
import backend.util.SaveUtil;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import backend.util.CacheUtil;
import backend.data.ClientPrefs;
import backend.util.PathUtil;
import flixel.system.FlxAssets;
import states.menus.MainMenuState;
import flixel.FlxG;
import flixel.FlxState;
#if DISCORD_ALLOWED
import backend.api.DiscordClient;
#end
import lime.app.Application;
import openfl.Lib;
import openfl.display.StageScaleMode;
#if html5
import js.Browser;
#end

/**
 * The initial state of the game. This is where
 * you can load assets and set up the game.
 */
class InitState extends FlxState {

	override public function create() {
		// Assign and configure flixel settings
		configureFlixelSettings();

		// Add the processes that always run in the background
		addBackgroundProcesses();

		// Add the event listeners
		addEventListeners();

		// Load all of the player's settings and options
		// Note that if this line is not present, it will
		// cause null errors and crash the game!
		ClientPrefs.loadAll();

		// Center the window to be in the middle of the display
		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);

		// Set the game to fullscreen if option is ON
		FlxG.fullscreen = ClientPrefs.options.fullscreen;

		// Switch to the main menu state after everything has loaded
		FlxG.switchState(() -> new MainMenuState());
	}

	function configureFlixelSettings():Void {
		// Set the cursor to be the system default
		FlxG.mouse.useSystemCursor = true;

		// Set auto pause to false
		FlxG.autoPause = false;

		// Set the stage and scaling modes
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		// Set the default font
		FlxAssets.FONT_DEFAULT = PathUtil.ofFont('Born2bSportyFS');

		// Disable the right-click context menu for HTML5
		#if html5
		Browser.document.addEventListener('contextmenu', (e) -> {
			e.preventDefault();
		});
		#end

		// Set the volume slider shit
		// (thats my todo lol)
	}

	function addBackgroundProcesses():Void {}

	function addEventListeners():Void {
		#if desktop
        // Fullscreen :sparkles:
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (_) -> {
            if (Controls.binds.FULLSCREEN_JUST_PRESSED) {
				FlxG.fullscreen = !FlxG.fullscreen;
				ClientPrefs.setClientPreference('fullscreen', FlxG.fullscreen);
			}
        });

		// Minimize volume when the window is out of focus
		Application.current.window.onFocusIn.add(() -> {
			// Bring the volume back up when the window is focused again
			if (ClientPrefs.options.minimizeVolume && !CacheUtil.isWindowFocused) {
				// Set back to one decimal place (0.1) when the screen gains focus again
				// (note that if the user had the volume all the way down, it will be set to zero)
				FlxG.sound.volume = (!(Math.abs(FlxG.sound.volume) < FlxMath.EPSILON)) ? 0.1 : 0;
				CacheUtil.isWindowFocused = true;
				// Set the volume back to the last volume used
				FlxTween.num(FlxG.sound.volume, CacheUtil.lastVolumeUsed, 0.3, { type: FlxTweenType.ONESHOT }, (v) -> {
					FlxG.sound.volume = v;
				});
			}
		});
		Application.current.window.onFocusOut.add(() -> {
			// Minimize the volume when the window loses focus
			if (ClientPrefs.options.minimizeVolume && CacheUtil.isWindowFocused) {
				// Set the last volume used to the current volume
				CacheUtil.lastVolumeUsed = FlxG.sound.volume;
				CacheUtil.isWindowFocused = false;
				// Tween the volume to 0.03
				FlxTween.num(FlxG.sound.volume, (!(Math.abs(FlxG.sound.volume) < FlxMath.EPSILON)) ? 0.03 : 0, 0.3, { type: FlxTweenType.ONESHOT }, (v) -> {
					FlxG.sound.volume = v;
				});
			}
		});
		#end

		// Do shit like saving the user's data when the game closes
		Application.current.window.onClose.add(() -> {
			// Save all of the user's data
			SaveUtil.saveAll();
		});
	}
}
