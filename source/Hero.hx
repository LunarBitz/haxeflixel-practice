import flixel.math.FlxRandom;
import lime.math.ColorMatrix;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Hero extends FlxSprite
{ 
    var randomGen:FlxRandom = new FlxRandom();

	override public function new(x:Float = 0.0, y:Float = 0.0)
    {
        super(x, y);
        makeGraphic(64, 64, 0xff00ff00);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var randomColor:FlxColor = randomGen.color(0x00000000, 0xFFFFFFFF);
        this.color = randomColor;
    }
}