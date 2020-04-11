package entities.player;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxObject;

class Hero extends FlxSprite {
	public static var WIDTH(default, never):Int = 32;
	public static var HEIGHT(default, never):Int = 32;

	public static var DEAD_ZONE(default, never):Float = 0.1;

	public static var GRAVITY(default, never):Float = 300;
	public static var TERMINAL_VELOCITY(default, never):Float = 600;
	public static var X_TARGET_SPEED(default, never):Float = 200;
	
	public static var JUMP_SPEED(default, never):Float = -200;

	private var leftInput:Int = 0;
	private var rightInput:Int = 0;
	private var horizontalMovementAxis:Int = 0;

	private var jumpInput:Int = 0;
	
	private var facingDirection:Int = 1;
	private var grounded:Bool = false;
	private var xSpeed:Float = 0;
	private var ySpeed:Float = 0;

	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);
		makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY;
		maxVelocity.y = TERMINAL_VELOCITY;
	}

	override function update(elapsed:Float) 
	{
		updateGrounded();
		
		// Set up nicer input-handling for movement.
		gatherInputs();

		// Horizontal movement
		var facingDirection:Int = getMoveDirectionCoefficient(horizontalMovementAxis);
		velocity.x = X_TARGET_SPEED * facingDirection;
	   
		// Jump
		jump(jumpInput);

		super.update(elapsed);
	}

	/**
		Helper function responsible for interacting with HaxeFlixel systems to gather inputs 
		relevant to the Hero. Helps keep code clean by restricting FlxG.keys input to a single spot,
		which makes it much easier to change inputs, implement rebinding, etc. in the future.
	**/
	private function gatherInputs():Void 
	{
		leftInput = (FlxG.keys.pressed.LEFT)? 1:0;
		rightInput = (FlxG.keys.pressed.RIGHT)? 1:0;
		horizontalMovementAxis = inputAxis(leftInput, rightInput);
		
		jumpInput = (FlxG.keys.justPressed.Z)? 1:0;
	}

	private function inputAxis(negativeInput:Int, positiveInput:Int):Int 
	{
		return (positiveInput - negativeInput);
	}

	/**
		Uses player input to determine if movement should occur in a positive or negative X 
		direction. If no movement inputs are detected, 0 is returned instead.
		@param leftPressed Boolean indicating if the "left" movement button is pressed.
		@param rightPressed Boolean indicating if the "right" movement button is pressed.
		@return Returns 1, 0, or -1. Multiply movement speed by this to set movement direction.
	**/
	private function getMoveDirectionCoefficient(axis:Int):Int 
	{      
		if (Math.abs(axis) < DEAD_ZONE)
			return 0;
		else
			return FlxMath.signOf(axis);
	}

	public function updateGrounded(newGround:Bool = false)
	{
		if (newGround)
			grounded = newGround;
		else
			grounded = this.isTouching(FlxObject.DOWN);
	}

	public function onCollision(obj1:FlxSprite, obj2:FlxSprite)
	{
		
	}

	public function isOnGround() 
	{
		return grounded;
	}

	/**
		Simple function for handling jump logic.
		At the moment, this doesn't prevent the player from jumping while in the air.
		@param jumpJustPressed Boolean indicating if the jump button was pressed this frame.
	**/
	private function jump(jumpCount:Int):Void 
	{
		if (jumpInput == 1) 
		{
			velocity.y = JUMP_SPEED;
			updateGrounded(false);
		}
	}
}