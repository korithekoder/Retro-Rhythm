package objects.ui;

import backend.util.PathUtil;
import flixel.FlxG;
import states.PlayState;
import backend.Controls;
import backend.util.GeneralUtil;
import flixel.util.FlxColor;
import backend.data.Constants;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class SongBoardObject extends FlxTypedGroup<FlxSprite> {

    public var isFocusedOn:Bool = false;
    public var difficulty:Int;

    public var bg:ClickableSprite;
    public var id:String;  // The ID of the song
    public var name:String;
    public var bpm:Int;
    public var speed:Float;
    private var _songNameText:FlxText;
    private var _songDifficultyText:FlxText;

    public function new(y:Float, id:String, name:String, bpm:Int, speed:Float, difficulty:Int, bannerColor:Array<Int>) {
        super();

        this.difficulty = difficulty; 
        this.id = id;
        this.name = name;
        this.bpm = bpm;
        this.speed = speed;

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

        bg = new ClickableSprite();
        bg.makeGraphic(
            Std.int((_songNameText.width + _songDifficultyText.width) + 4),
            Std.int(_songNameText.height + _songDifficultyText.height) + 4,
            FlxColor.fromRGB(Std.int(bannerColor[0]), Std.int(bannerColor[1]), Std.int(bannerColor[2]))
        );
        bg.alpha = 0.4;
        bg.updateHitbox();
        bg.y = y;
        bg.onHover = () -> {
            if (isFocusedOn) {
                bg.alpha = 0.8;
                FlxG.sound.play(PathUtil.ofSound('blip'), false);
            }
        }
        bg.onHoverLost = () -> {
            bg.alpha = 0.4;
        }
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

    public function setTextPositions():Void {
        _songNameText.setPosition(bg.x + 2, bg.y + 2);
        _songDifficultyText.setPosition(bg.x + 2, (_songNameText.y + _songNameText.height) - 6);
    }
}
