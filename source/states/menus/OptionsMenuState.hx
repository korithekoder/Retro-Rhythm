package states.menus;

import substates.options.MiscOptionsSubState;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import substates.options.GameplayOptionsSubState;
import flixel.FlxSubState;
import objects.ui.ClickableText;
import flixel.group.FlxGroup.FlxTypedGroup;
import backend.data.Constants;
import backend.util.GeneralUtil;
import backend.Controls;
import backend.util.CacheUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class OptionsMenuState extends FlxTransitionableState {
    
    var bgSprite:FlxSprite;

    var buttonsGroup:FlxTypedGroup<ClickableText>;
    var buttonClickFunctions:Map<String, Void -> Void>;
    var buttonIds:Array<String> = ['Gameplay', 'Misc.'];

    override function create() {
        super.create();

        CacheUtil.canPlayMenuMusic = true;
        GeneralUtil.playMenuMusic('Ennui');

        bgSprite = new FlxSprite();
        bgSprite.loadGraphic(PathUtil.ofImage('options-bg'), false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);
        add(bgSprite);

        buttonClickFunctions = [
            'Gameplay' => () -> {
                openOptionsMenu(new GameplayOptionsSubState());
            },
            'Misc.' => () -> {
                openOptionsMenu(new MiscOptionsSubState());
            }
        ];

        buttonsGroup = new FlxTypedGroup<ClickableText>();
        add(buttonsGroup);

        var newY:Float = 150;
        var newTweenTime:Float = 0.25;
        for (btn in buttonIds) {
            var b = new ClickableText();
            b.text = btn;
            b.size = 115;
            b.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 3);
            b.updateHitbox();
            b.x = -b.width;
            b.y = newY;
            b.onClick = buttonClickFunctions.get(btn);
            b.onHover = () -> {
                FlxG.sound.play(PathUtil.ofSound('blip'), false);
                b.text = '> $btn <';
                b.updateHitbox();
                b.x = (FlxG.width / 2) - (b.width / 2);
            };
            b.onHoverLost = () -> {
                b.text = btn;
                b.updateHitbox();
                b.x = (FlxG.width / 2) - (b.width / 2);
            };
            
            new FlxTimer().start(newTweenTime, (_) -> {
                FlxTween.tween(b, { x: (FlxG.width / 2) - (b.width / 2) }, newTweenTime, { ease: FlxEase.quadOut, onComplete: (_) -> b.updateHoverBounds() });
            });

            buttonsGroup.add(b);

            newY += b.height + 40;
            newTweenTime += 0.15;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.play(PathUtil.ofSound('menu-back'), false);
            FlxG.sound.music.stop();
            GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
        }
    }

    override function closeSubState() {
        super.closeSubState();
        FlxG.sound.play(PathUtil.ofSound('menu-back'), false);
        buttonsGroup.visible = true;
    }

    override function destroy() {
        FlxG.sound.music.stop();
        CacheUtil.canPlayMenuMusic = true;
        super.destroy();
    }

    function openOptionsMenu(menu:FlxSubState):Void {
        if (menu == null) {
            return;
        }
        buttonsGroup.visible = false;
        openSubState(menu);
    } 
}
