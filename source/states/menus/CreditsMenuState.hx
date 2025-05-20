package states.menus;

import backend.util.CacheUtil;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import backend.data.Constants;
import flixel.text.FlxText;
import backend.Controls;
import flixel.util.FlxSpriteUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.math.FlxMath;
import flixel.FlxG;
import objects.ui.ClickableSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class CreditsMenuState extends FlxTransitionableState {

    var ppl:FlxTypedGroup<FlxSprite>;

    var koriText:FlxText;
    var chaplinText:FlxText;
    var socials:FlxTypedGroup<ClickableSprite>;

    override function create() {
        super.create();

        CacheUtil.canPlayMenuMusic = true;
        FlxG.sound.playMusic(PathUtil.ofMusic('Best Memories'));

        var bg:FlxSprite = new FlxSprite();
        bg.loadGraphic(PathUtil.ofImage('credits/credits-bg'));
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.setPosition(0, 0);
        add(bg);

        ppl = new FlxTypedGroup<FlxSprite>();
        add(ppl);

        socials = new FlxTypedGroup<ClickableSprite>();
        add(socials);

        var kori:FlxSprite = new FlxSprite();
        kori.loadGraphic(PathUtil.ofImage('credits/korithekoder'));
        kori.updateHitbox();
        kori.setPosition(40, FlxG.height - kori.height);
        ppl.add(kori);

        var chaplin:FlxSprite = new FlxSprite();
        chaplin.loadGraphic(PathUtil.ofImage('credits/basket'));
        chaplin.updateHitbox();
        chaplin.setPosition(FlxG.width - chaplin.width - 40, FlxG.height - chaplin.height);
        ppl.add(chaplin);

        koriText = new FlxText();
        koriText.text = 'Kori (@korithekoder)\nPROGRAMMING';
        koriText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        koriText.size = 50;
        koriText.alignment = 'center';
        koriText.updateHitbox();
        koriText.x = kori.x + (kori.width / 2) - (koriText.width / 2);
        koriText.y = 30;
        add(koriText);

        chaplinText = new FlxText();
        chaplinText.text = 'Chaplin (@Basket)\nMUSIC';
        chaplinText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
        chaplinText.size = 50;
        chaplinText.alignment = 'center';
        chaplinText.updateHitbox();
        chaplinText.x = chaplin.x + (chaplin.width / 2) - (chaplinText.width / 2);
        chaplinText.y = 50;
        add(chaplinText);

        var githubSocial:ClickableSprite = new ClickableSprite();
        githubSocial.loadGraphic(PathUtil.ofImage('socials/github'));
        githubSocial.scale.set(5, 5);
        githubSocial.updateHitbox();
        githubSocial.setPosition(40, FlxG.height - githubSocial.height - 40);
        githubSocial.onClick = () -> {
            GeneralUtil.openURL('https://github.com/korithekoder/');
        };
        githubSocial.onHover = () -> {
            FlxG.sound.play(PathUtil.ofSound('blip'));
            FlxSpriteUtil.setBrightness(githubSocial, 0.5);
        };
        githubSocial.onHoverLost = () -> {
            FlxSpriteUtil.setBrightness(githubSocial, 0);
        };
        socials.add(githubSocial);

        var twitterSocial:ClickableSprite = new ClickableSprite();
        twitterSocial.loadGraphic(PathUtil.ofImage('socials/twitter'));
        twitterSocial.scale.set(5, 5);
        twitterSocial.updateHitbox();
        twitterSocial.setPosition((githubSocial.x + githubSocial.width) + 10, FlxG.height - twitterSocial.height - 40);
        twitterSocial.onClick = () -> {
            GeneralUtil.openURL('https://x.com/korithekoder/');
        };
        twitterSocial.onHover = () -> {
            FlxG.sound.play(PathUtil.ofSound('blip'));
            FlxSpriteUtil.setBrightness(twitterSocial, 0.5);
        };
        twitterSocial.onHoverLost = () -> {
            FlxSpriteUtil.setBrightness(twitterSocial, 0);
        };
        socials.add(twitterSocial);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.viewX - (FlxG.width / 2)) * 0.050, (1 / 30) * 240 * elapsed);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.viewY - 6 - (FlxG.height / 2)) * 0.050, (1 / 30) * 240 * elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.sound.play(PathUtil.ofSound('menu-back'));
            GeneralUtil.fadeIntoState(new MainMenuState(), Constants.TRANSITION_DURATION, false);
        }
    }
}
