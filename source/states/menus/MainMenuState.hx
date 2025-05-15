package states.menus;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import backend.util.PathUtil;
import backend.util.AssetUtil;
import backend.data.Constants;
import backend.Controls;
import objects.ui.ClickableText;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class MainMenuState extends FlxTransitionableState {

    var menuText:FlxText;
    var bgSprite:FlxSprite;
    var buttonBgSprite:FlxSprite;

    var buttons:FlxTypedGroup<ClickableText>;
    var buttonIds:Array<String> = ['Play', 'Options', 'Exit'];
    
    override function create() {
        super.create();

        GeneralUtil.playMenuMusic();
        FlxG.sound.music.resume();

        var bgFiles = AssetUtil.loadBackgrounds();

        bgSprite = new FlxSprite();
        bgSprite.loadGraphic(bgFiles[FlxG.random.int(0, bgFiles.length - 1)], false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);
        add(bgSprite);

        buttonBgSprite = new FlxSprite();
        buttonBgSprite.makeGraphic(400, FlxG.height, FlxColor.BLACK);
        buttonBgSprite.updateHitbox();
        buttonBgSprite.setPosition(FlxG.width - 400, 0);
        buttonBgSprite.alpha = 0.65;
        add(buttonBgSprite);

        buttons = new FlxTypedGroup<ClickableText>();
        add(buttons);

        var buttonClickFunctions:Map<String, Void->Void> = [
            'Play' => () -> {
                GeneralUtil.fadeIntoState(new SongSelectionState(), Constants.TRANSITION_DURATION, false);
            },
            'Options' => () -> {
                FlxG.sound.music.stop();
                GeneralUtil.fadeIntoState(new OptionsMenuState(), Constants.TRANSITION_DURATION, false);
            },
            'Exit' => () -> {
                GeneralUtil.closeGame();
            }
        ];

        var newY:Float = 132;
        for (btn in buttonIds) {
            var b:ClickableText = new ClickableText();
            b.text = btn;
            b.size = 100;
            b.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(25, 25, 25), 5);
            b.updateHitbox();
            b.x = buttonBgSprite.x + (buttonBgSprite.width - b.width);
            b.y = newY;
            b.updateHoverBounds();
            b.onClick = buttonClickFunctions.get(btn);
            b.onHover = () -> {
                FlxG.sound.play(PathUtil.ofSound('blip'), false);
                FlxTween.cancelTweensOf(b);
                FlxTween.tween(b, { x: buttonBgSprite.x + 30 }, 0.3, {
                    ease: FlxEase.quadOut
                });
            };
            b.onHoverLost = () -> {
                FlxTween.cancelTweensOf(b);
                FlxTween.tween(b, { x: buttonBgSprite.x + (buttonBgSprite.width - b.width) }, 0.3, {
                    ease: FlxEase.quadOut
                });
            };
            buttons.add(b);
            newY += b.height + 8;
        }

        menuText = new FlxText();
        menuText.text = 'Retro\nRhythm';
        menuText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(25, 25, 25), 5);
        menuText.size = 128;
        menuText.updateHitbox();
        menuText.x = 60;
        menuText.y = 80;
        add(menuText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }
}
