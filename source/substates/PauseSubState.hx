package substates;

import flixel.FlxCamera;
import backend.Controls;
import backend.data.Constants;
import backend.util.CacheUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.ui.ClickableText;
import states.PlayState;
import states.menus.SongSelectionState;

class PauseSubState extends FlxSubState {
    
    var bg:FlxSprite;

    var buttonsGroup:FlxTypedGroup<ClickableText>;
    var buttonIds:Array<String> = ['Resume', 'Enable Bot Play', 'Exit'];
    var buttonClickFunctions:Map<String, Void->Void>;
	var buttonWasClicked:Bool = false;

    var pausedText:FlxText;

    override function create() {
        super.create();

		var pauseCam = new FlxCamera();
		pauseCam.bgColor = FlxColor.TRANSPARENT;
		pauseCam.zoom = 1; // No zoom
		FlxG.cameras.add(pauseCam, false); // Add as overlay, not the main camera

		cameras = [pauseCam];

        FlxG.sound.music.pause();

        bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);

        pausedText = new FlxText();
        pausedText.text = 'Paused!';
        pausedText.size = 150;
        pausedText.color = FlxColor.WHITE;
        pausedText.alpha = 0;
        pausedText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
        pausedText.updateHitbox();
        pausedText.setPosition(80, 90);
        add(pausedText);

        FlxTween.tween(bg, { alpha: 0.6 }, 0.5, { ease: FlxEase.quartIn });
        FlxTween.tween(pausedText, { alpha: 1 }, 0.5, {ease: FlxEase.quartIn });

        buttonClickFunctions = [
            'Resume' => () -> {
				if (buttonWasClicked)
					return;
				buttonWasClicked = true;
                FlxG.sound.music.resume();
                close();
            },
            'Enable Bot Play' => () -> {
				if (buttonWasClicked)
					return;
				buttonWasClicked = true;
				FlxG.sound.play(PathUtil.ofSound('select'));
                FlxG.sound.music.stop();
                CacheUtil.botModeEnabled = !CacheUtil.botModeEnabled;
                GeneralUtil.fadeIntoState(new PlayState(CacheUtil.currentSongId), Constants.TRANSITION_DURATION, false);
            },
            'Exit' => () -> {
				if (buttonWasClicked)
					return;
				buttonWasClicked = true;
				FlxG.sound.play(PathUtil.ofSound('select'));
                FlxG.sound.music.stop();
                GeneralUtil.fadeIntoState(new SongSelectionState(), Constants.TRANSITION_DURATION, false);
            }
        ];

        buttonsGroup = new FlxTypedGroup<ClickableText>();
        add(buttonsGroup);

        var newY:Float = 275;
        var newTweenTime:Float = 0.6;
        for (btn in buttonIds) {
            var b:ClickableText = new ClickableText();
            b.text = (btn == 'Enable Bot Play' && CacheUtil.botModeEnabled) ? 'Disable Bot Mode' : btn ;
            b.size = 100;
            b.color = FlxColor.WHITE;
            b.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
            b.updateHitbox();
            b.x = -b.width;
            b.y = newY;
            b.onClick = buttonClickFunctions.get(btn);
            b.onHover = () -> {
                FlxG.sound.play(PathUtil.ofSound('blip'), false);
                FlxTween.cancelTweensOf(b);
                FlxTween.tween(b, { x: 175 }, 0.3, {
                    ease: FlxEase.quadOut
                });
            };
            b.onHoverLost = () -> {
                FlxTween.cancelTweensOf(b);
                FlxTween.tween(b, { x: 80 }, 0.3, {
                    ease: FlxEase.quadOut
                });
            };
            new FlxTimer().start(newTweenTime, (_) -> {
                FlxTween.tween(b, { x: 80 }, 0.3, {
                    ease: FlxEase.quadOut,
                    onComplete: (_) -> {
                        b.updateHoverBounds();
                    }
                });
            });
            buttonsGroup.add(b);

            newY += b.height - 5;
            newTweenTime += 0.15;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.music.resume();
            close();
        }
    }
}
