package objects.ui;

import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import states.PlayState;
import backend.Controls;
import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import backend.data.Constants;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class SongBoardObject extends FlxTypedGroup<FlxSprite> {

    public var isFocusedOn:Bool = true;
    public var difficulty:Int;

    public var bg:ClickableSprite;
    public var id:String;  // The ID of the song
    private var _songNameText:FlxText;
    private var _songBPMText:FlxText;
    private var _songSpeedText:FlxText;
    private var _songDifficultyText:FlxText;

    public function new(y:Float, id:String, name:String, bpm:Int, speed:Float, difficulty:Int, bannerColor:Array<Int>) {
        super();

        this.difficulty = difficulty; 
        this.id = id;

        _songNameText = new FlxText();
        _songNameText.text = name;
        _songNameText.size = Math.floor(Constants.SONG_BANNER_TEXT_SIZE * 1.45);
        _songNameText.updateHitbox();
        _songNameText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 5);
        add(_songNameText);

        _songDifficultyText = new FlxText();
        _songDifficultyText.text = 'Difficulty: ${Std.string(difficulty)}';
        _songDifficultyText.size = Constants.SONG_BANNER_TEXT_SIZE;
        _songDifficultyText.color = GeneralUtil.getDifficultyColor(difficulty);
        _songDifficultyText.setBorderStyle(FlxTextBorderStyle.SHADOW, GeneralUtil.darkenFlxColor(GeneralUtil.getDifficultyColor(difficulty), 70), 3);
        _songDifficultyText.updateHitbox();
        add(_songDifficultyText);

        _songBPMText = new FlxText();
        _songBPMText.text = 'BPM: ${Std.string(bpm)}';
        _songBPMText.size = Constants.SONG_BANNER_TEXT_SIZE;
        _songBPMText.updateHitbox();
        _songBPMText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
        add(_songBPMText);

        _songSpeedText = new FlxText();
        _songSpeedText.text = 'Speed: ${Std.string(speed)}';
        _songSpeedText.size = Constants.SONG_BANNER_TEXT_SIZE;
        _songSpeedText.updateHitbox();
        _songSpeedText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 3);
        add(_songSpeedText);

        var bgWidthAdd:Int = Std.int((_songBPMText.width + _songSpeedText.width) - _songNameText.width);
        if (bgWidthAdd < 0) bgWidthAdd = 0;

        bg = new ClickableSprite();
        bg.makeGraphic(
            Std.int((_songNameText.width + (bgWidthAdd)) + 12),
            Std.int(_songNameText.height + _songDifficultyText.height + _songBPMText.height) + 2,
            FlxColor.fromRGB(Std.int(bannerColor[0]), Std.int(bannerColor[1]), Std.int(bannerColor[2]))
        );
        bg.alpha = 0.65;
        bg.updateHitbox();
        bg.setPosition((FlxG.width - bg.width) - 40, y);
        bg.onClick = () -> {
            if (isFocusedOn) {
                GeneralUtil.fadeIntoState(new PlayState(id), Constants.TRANSITION_DURATION, false);
            }
        }
        insert(0, bg);  // Make sure the banner is in the back!
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        setTextPositions();

        if (isFocusedOn) {
            if (Controls.getBinds().UI_SELECT_JUST_PRESSED) {
                GeneralUtil.fadeIntoState(new PlayState(id), Constants.TRANSITION_DURATION, false);
            }
        }
    }

    public function getBannerHeight():Int {
        return Std.int(_songNameText.height + _songDifficultyText.height + _songBPMText.height) + 2;
    }

    public function setTextPositions():Void {
        _songNameText.setPosition(bg.x + 2, bg.y + 2);
        _songDifficultyText.setPosition(bg.x + 2, (_songNameText.y + _songNameText.height) - 6);
        _songBPMText.setPosition(bg.x, (_songDifficultyText.y + _songDifficultyText.height) - 6);
        _songSpeedText.setPosition((_songBPMText.x + _songBPMText.width) + 10, (_songDifficultyText.y + _songDifficultyText.height) - 6);
    }
}
