package states.menus;

import backend.util.CacheUtil;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import objects.states.MusicBeatState;
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

class MainMenuState extends MusicBeatState {

    var bgCamera:FlxCamera;
    var uiCamera:FlxCamera;

    var menuText:FlxText;
    var bgSprite:FlxSprite;
    var buttonBgSprite:FlxSprite;

    var buttons:FlxTypedGroup<ClickableText>;
    var buttonIds:Array<String> = ['Play', 'Options', #if CREDITS_BUTTON_ALLOWED 'Credits', #end 'Exit'];
    
    override function create() {
        super.create();

        FlxG.mouse.visible = true;

        GeneralUtil.playMenuMusic();
        FlxG.sound.music.resume();

        bgCamera = new FlxCamera();
        FlxG.cameras.add(bgCamera);

        uiCamera = new FlxCamera();
        uiCamera.bgColor.alpha = 0;
        FlxG.cameras.add(uiCamera);

        songBPM = 190;
        songCamZoomIntensity = 1.5;
        beatDuration = 60 / songBPM;
        beatDurationMS = 60000 / songBPM;
        beatsBeforeHit = 1;

        var bgFiles = AssetUtil.loadBackgrounds();

        bgSprite = new FlxSprite();
        bgSprite.loadGraphic(bgFiles[FlxG.random.int(0, bgFiles.length - 1)], false);
        bgSprite.setGraphicSize(FlxG.width, FlxG.height);
        bgSprite.updateHitbox();
        bgSprite.setPosition(0, 0);
        bgSprite.cameras = [bgCamera];
        add(bgSprite);

        buttonBgSprite = new FlxSprite();
        buttonBgSprite.makeGraphic(400, FlxG.height, FlxColor.BLACK);
        buttonBgSprite.updateHitbox();
        buttonBgSprite.setPosition(FlxG.width - 400, 0);
        buttonBgSprite.alpha = 0.65;
        buttonBgSprite.cameras = [uiCamera];
        add(buttonBgSprite);

        buttons = new FlxTypedGroup<ClickableText>();
        add(buttons);

        var buttonClickFunctions:Map<String, Void->Void> = [
            'Play' => () -> {
                FlxG.sound.play(PathUtil.ofSound('select'));
                GeneralUtil.fadeIntoState(new SongSelectionState(), Constants.TRANSITION_DURATION, false);
            },
            'Options' => () -> {
                FlxG.sound.play(PathUtil.ofSound('select'));
                FlxG.sound.music.stop();
                GeneralUtil.fadeIntoState(new OptionsMenuState(), Constants.TRANSITION_DURATION, false);
            },
            #if CREDITS_BUTTON_ALLOWED
            'Credits' => () -> {
                FlxG.sound.play(PathUtil.ofSound('select'));
                FlxG.sound.music.stop();
                GeneralUtil.fadeIntoState(new CreditsMenuState(), Constants.TRANSITION_DURATION, false);
            },
            #end
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
            b.x = buttonBgSprite.x + (buttonBgSprite.width - b.width) - 20;
            b.y = newY;
            b.updateHoverBounds();
            b.onClick = buttonClickFunctions.get(btn);
            b.onHover = () -> {
                FlxG.sound.play(PathUtil.ofSound('blip'), false);
                FlxTween.cancelTweensOf(b);
                FlxTween.tween(b, { x: buttonBgSprite.x + (buttonBgSprite.width / 2) - (b.width / 2) }, 0.3, {
                    ease: FlxEase.quadOut
                });
            };
            b.onHoverLost = () -> {
                FlxTween.cancelTweensOf(b);
                FlxTween.tween(b, { x: buttonBgSprite.x + (buttonBgSprite.width - b.width) - 20 }, 0.3, {
                    ease: FlxEase.quadOut
                });
            };
            b.cameras = [uiCamera];
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
        menuText.cameras = [bgCamera];
        add(menuText);

        if (CacheUtil.hasSeenIntro) {
            FlxG.sound.music.time = 31000;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        bgCamera.zoom = FlxMath.lerp(Constants.DEFAULT_CAM_ZOOM, bgCamera.zoom, Math.exp(-elapsed * 3.125 * Constants.CAMERA_ZOOM_DECAY));

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }

    public function beatHit() {
        bgCamera.zoom += 0.020 * songCamZoomIntensity;
    }
}
