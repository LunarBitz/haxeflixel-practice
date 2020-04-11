package entities.player;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxObject;

class Hero extends FlxSprite 
{
	// Graphics
	private var playerWidth:Int;
	private var playerHeight:Int;
	private var playerTilt:Int;

	private static var THICKNESS_NORMAL(default, never):Int = 24;
	private static var TILT_NORMAL(default, never):Int = 0;
	private static var TILT_RUNNING(default, never):Int = 3;
	private static var HEIGHT_NORMAL(default, never):Int = 32;
	private static var HEIGHT_JUMPING(default, never):Int = 36;
	private static var HEIGHT_CROUCHING(default, never):Int = 24;

	// Input
	private static var DEAD_ZONE(default, never):Float = 0.1;
	private static var MOVEMENT_INTERP(default, never):Float = 1/8;

	private var leftInput:Int = 0;
	private var rightInput:Int = 0;
	private var jumpInput:Int = 0;
	private var crouchInput:Int = 0;

	private var horizontalMovementAxis:Float = 0;
	
	// Movement
	private static var GRAVITY(default, never):Float = 981;
	private static var TERMINAL_VELOCITY(default, never):Float = 1500;
	private static var X_TARGET_SPEED(default, never):Float = 200;
	private static var JUMP_SPEED(default, never):Float = -350;

	private var xSpeed:Float = 0;
	private var ySpeed:Float = 0;
	
	// Jumping
	private var currentJumpCount:Int = 0;
	private var maxJumpCount:Int = 1;

	// Player States
	private var facingDirection:Int = 1;
	private var grounded:Bool = false;
	

	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		playerWidth = THICKNESS_NORMAL;
		playerHeight = HEIGHT_NORMAL;
		makeGraphic(playerWidth, playerHeight, FlxColor.WHITE);

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY;
		maxVelocity.y = TERMINAL_VELOCITY;
	}

	override function update(elapsed:Float) 
	{
		// Check and update the grounded state of the player
		updateGrounded();

		// Set up nicer input-handling for movement.
		gatherInputs();

		// Update facing direction
		var facingDirection:Int = getMoveDirectionCoefficient(horizontalMovementAxis);

		// Smooth out horizontal movement
		velocity.x = FlxMath.lerp(velocity.x, X_TARGET_SPEED * facingDirection, MOVEMENT_INTERP);
	   
		// Jump
		if (jumpInput == 1)
			jump(maxJumpCount);



		super.update(elapsed);
	}

	/**
		Function that simply returns an "axis" as a **Float** from two input values.
	**/
	private function inputAxis(negativeInput:Float, positiveInput:Float):Float 
	{
		return (positiveInput - negativeInput);
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
		crouchInput = (FlxG.keys.pressed.DOWN)? 1:0;
	}

	/**
		Uses player input to determine if movement should occur in a positive or negative X 
		direction. If no movement inputs are detected, 0 is returned instead.
		@param axis Float representing an axis of input.
		@return Returns 1, 0, or -1. Multiply movement speed by this to set movement direction.
	**/
	private function getMoveDirectionCoefficient(axis:Float):Int 
	{      
		return (Math.abs(axis) <= DEAD_ZONE)? 0 : FlxMath.signOf(axis);
	}

	/**
		Function to update the ***grounded*** variable via ***newBool*** or **FlxSprite.isTouching()**
		@param newBool Boolean to update the ***grounded*** variable with. Will be ignored if *False*.
	**/
	public function updateGrounded(newGround:Bool = false):Void
	{
		if (newGround)
			grounded = newGround;
		else
			grounded = this.isTouching(FlxObject.DOWN);
	}

	/**
		Returns if the player is on the ground or not
		@return Returns the ***grounded*** variable.
	**/
	public function isOnGround():Bool 
	{ 
		return grounded; 
	}

	/**
		Returns if the player is allowed to jump. Does NOT check if the player is grounded to allow for multi-jumping
		@return Returns *True* only if ***currentJumpCount*** is less than ***maxJumpCount***.
	**/
	public function canJump() 
	{
		return (currentJumpCount <= maxJumpCount);
	}

	/**
		Simple function for handling jump logic.
		At the moment, this doesn't prevent the player from jumping while in the air.
		@param jumpCount Number of jumps allowed.
	**/
	private function jump(jumpCount:Int):Void 
	{
		if (canJump()) 
		{
			velocity.y = JUMP_SPEED;
			currentJumpCount++;
			updateGrounded(false);
		}
	}

	/**
		Function that's called to resolve collision overlaps when invoked.
		@param player Object that collided with something.
		@param other Object that **player** has collided with.
	**/
	public function onCollision(player:FlxSprite, other:FlxSprite)
	{
		if (isOnGround())
		{
			currentJumpCount = 0;
		}
	}
}