package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class Hero extends FlxSprite
{ 
    public var xSpeed:Float = 0.0;
    public var ySpeed:Float = 0.0;
    public var targetSpeed:Float = 75.0;

    private var keyLeft:Int = 0;
    private var keyRight:Int = 0;
    private var keyUp:Int = 0;
    private var keyDown:Int = 0;

    private var overStimulationProtection:Bool = true;

	override public function new(x:Float = 0.0, y:Float = 0.0)
    {
        super(x, y);

        makeGraphic(32, 32);

        if (overStimulationProtection)
        {
            new FlxTimer().start(0.5, overStimulationCallback, 0);
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        updateMovement();

        if (!overStimulationProtection)
        {
            // Call visual methods that may trigger epilepsy
            randomizeColor();
        }
    }

    public function updateMovement():Void
    {
        // Set keyboard booleans to integers
        keyLeft = (FlxG.keys.pressed.A)? 1:0;
        keyRight = (FlxG.keys.pressed.D)? 1:0;
        keyUp = (FlxG.keys.pressed.W)? 1:0;
        keyDown = (FlxG.keys.pressed.S)? 1:0;

        // Set keyboard integers as scaled axis
        this.xSpeed = (keyRight - keyLeft) * targetSpeed;   // Same as setting using if statements while letting "keyLeft" return -1
        this.ySpeed = (keyDown - keyUp) * targetSpeed;  // Same as setting using if statements while letting "keyUp" return -1

        // Update velocity
        this.velocity.set(xSpeed, ySpeed);  

        // Wrap hero's position horizontally
        if (this.x > FlxG.camera.width)
        {
            this.x = 0;
        }
        else if (this.x < 0)
        {
            this.x = FlxG.camera.width;
        }

        // Wrap hero's position vertically
        if (this.y > FlxG.camera.height)
        {
            this.y = 0;
        }
        else if (this.y < 0)
        {
            this.y = FlxG.camera.height;
        }  
    }

    function overStimulationCallback(timer:FlxTimer):Void
    {
        // Call visual methods that may trigger epilepsy
        randomizeColor();
    }

    public function randomizeColor():Void
    {
        var randomColor:FlxColor = FlxG.random.color(0xFF000000, 0xFFFFFFFF);
        this.color = randomColor;
    }
}