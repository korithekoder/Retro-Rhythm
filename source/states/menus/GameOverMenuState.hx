package states.menus;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import backend.util.PathUtil;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import backend.data.Constants;
import backend.util.CacheUtil;
import backend.util.GeneralUtil;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import objects.ui.ClickableText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;

class GameOverMenuState extends FlxTransitionableState {
    
    var gameOverText:FlxText;

    var buttonsGroup:FlxTypedGroup<ClickableText>;
    var buttonIds:Array<String> = ['Retry', 'Exit'];

    var buttonClickFunctions:Map<String, Void->Void>;

    var gameOverSound:FlxSound;

    override function create() {
        super.create();

        FlxG.mouse.visible = true;

        gameOverSound = new FlxSound();
        gameOverSound.loadEmbedded(PathUtil.ofSound('game-over'), false, false);
        gameOverSound.onComplete = () -> {
            FlxTween.tween(gameOverText, { alpha: 1 }, 0.75, { ease: FlxEase.quadInOut });
            for (b in buttonsGroup.members) {
                FlxTween.tween(b, { alpha: 1 }, 0.75, { ease: FlxEase.quadInOut });
            }
        }
        gameOverSound.volume = 0.75;

        gameOverText = new FlxText();
        gameOverText.text = 'You Tried Your Best...';
        gameOverText.size = 130;
        gameOverText.color = FlxColor.fromRGB(150, 0, 0);
        gameOverText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4);
        gameOverText.alignment = 'center';
        gameOverText.updateHitbox();
        gameOverText.screenCenter(FlxAxes.X);
        gameOverText.y = 50;
        gameOverText.alpha = 0;
        add(gameOverText);

        buttonsGroup = new FlxTypedGroup<ClickableText>();
        add(buttonsGroup);

        buttonClickFunctions = [
            'Retry' => () -> {
                GeneralUtil.fadeIntoState(new PlayState(CacheUtil.currentSongId), Constants.TRANSITION_DURATION, false);
            },
            'Exit' => () -> {
                GeneralUtil.fadeIntoState(new SongSelectionState(), Constants.TRANSITION_DURATION, false);
            }
        ];

        var newY:Float = (gameOverText.y + gameOverText.height) + 80;
        for (btn in buttonIds) {
            var b:ClickableText = new ClickableText();
            b.text = btn;
            b.color = FlxColor.WHITE;
            b.size = 75;
            b.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
            b.updateHitbox();
            b.screenCenter(FlxAxes.X);
            b.y = newY;
            b.alpha = 0;
            b.updateHoverBounds();
            b.onClick = buttonClickFunctions.get(btn);
            b.onHover = () -> {
                FlxG.sound.play(PathUtil.ofSound('blip'), false);
                b.underline = true;
            };
            b.onHoverLost = () -> {
                b.underline = false;
            };
            buttonsGroup.add(b);
            newY += b.height + 5;
        }

        gameOverSound.play();
    }
}
