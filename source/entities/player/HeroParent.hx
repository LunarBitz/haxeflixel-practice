package entities.player;

import flixel.system.debug.watch.Watch;
import flixel.system.FlxSplash;
import haxe.macro.Expr.Case;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxObject;

enum ActionState 
{
	Null;
	Normal;
	Jumping;
	Crouching;
	Sliding;
}

class Hero extends FlxSprite 
{
	// Graphics
	private var playerGraphic:FlxSprite;
	private var playerWidth:Float = 0;
	private var playerHeight:Float = 0;
	private var targetWidth:Float = 0;
	private var targetHeight:Float = 0;

	private static var THICKNESS_NORMAL(default, never):Float = 16;
	private static var HEIGHT_NORMAL(default, never):Float = 32;
	private static var HEIGHT_JUMPING(default, never):Float = 36;
	private static var HEIGHT_CROUCHING(default, never):Float = 16;

	// Input
	private static var DEAD_ZONE(default, never):Float = 0.1;
	private static var MOVEMENT_INTERP(default, never):Float = 1/16;

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
	private var playerState:ActionState;
	private var facingDirection:Int = 1;
	private var grounded:Bool = false;
	

	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		actionState(ActionState.Normal);
		//

		targetWidth = THICKNESS_NORMAL;
		targetHeight = HEIGHT_NORMAL;
		playerGraphic = makeGraphic(Std.int(targetWidth), Std.int(targetHeight), FlxColor.WHITE);

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY;
		maxVelocity.y = TERMINAL_VELOCITY;

		FlxG.watch.add(this, "targetHeight", "Target Height");
		FlxG.watch.add(this, "playerHeight", "Player Height");
		FlxG.watch.add(this, "origin", "Origin");
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
		{
			jump(maxJumpCount);
		}

		// Crouch
		if (crouchInput == 1)
		{
			crouch();
		}

		handleActionStates();

		updateHeight();

		super.update(elapsed);
	}

	private function actionState(newState:ActionState = ActionState.Null):ActionState
	{
		if (newState != ActionState.Null)
		{
			playerState = newState;
			return newState;
		}
		else
		{
			return playerState;
		}
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
		@return Returns *True* only if *`currentJumpCount` < `maxJumpCount`*.
	**/
	public function canJump() 
	{
		return  (isOnGround() || (currentJumpCount <= maxJumpCount));
	}

	/**
		Simple function for handling jump logic.
		@param jumpCount Number of jumps allowed.
	**/
	private function jump(jumpCount:Int):Void 
	{
		if (canJump()) 
		{
			velocity.y = JUMP_SPEED;
			currentJumpCount++;
			updateGrounded(false);
			actionState(ActionState.Jumping);
		}
	}

	private function crouch():Void 
	{
		actionState(ActionState.Crouching);
	}

	/**
		Function that's called to resolve collision overlaps when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function onCollision(player:FlxSprite, other:FlxSprite)
	{
		unstick(player, other);
		if (isOnGround())
		{
			currentJumpCount = 0;
			actionState(ActionState.Normal);
		}
	}

	private function unstick(player:FlxSprite, other:FlxSprite) 
	{

		//Horizontal Collision
		if (overlapsAt(x + velocity.x, y, other))
		{
			while(!overlapsAt(x + FlxMath.signOf(velocity.x), y, other))
			{
				x += FlxMath.signOf(velocity.x);
			}
			//xSpeed = 0;
		}

		//vertical Collision
		if (overlapsAt(x, y + velocity.y, other))
		{
			while(!overlapsAt(x, y + FlxMath.signOf(velocity.y), other))
			{
				y += FlxMath.signOf(velocity.y);
			}
			//ySpeed = 0;
		}	
	}

	public function setHeight(newHeight:Float) 
	{
		targetHeight = newHeight;
	}

	public function updateHeight():Void
	{
		/*
		var prevHeight = this.height;
		var targetHeightPercentage = Math.abs(newHeight - prevHeight) / ((newHeight + prevHeight)/2);

		var newWidthScale = !preserveVolume? 1 : 1 + targetHeightPercentage;
		var newHeightScale = 1 - targetHeightPercentage;

		this.scale.set(newWidthScale, newHeightScale);
		this.updateHitbox();
		*/

		/*
		var prevHeight = this.frameHeight;
		var prevWidth = this.frameWidth;
		var heightDifference = targetHeight - prevHeight;
		var targetHeightPercentage = Math.abs(heightDifference) / ((targetHeight + prevHeight)/2);

		targetWidth = !preserveVolume? prevWidth : prevWidth + (prevWidth * targetHeightPercentage);
		targetHeight = newHeight;
		*/
		//playerWidth = FlxMath.lerp(playerWidth, targetWidth, 1/8);
		//playerHeight = FlxMath.lerp(playerHeight, targetHeight, 1/8);

		//FlxTween.tween(this, { playerWidth: targetWidth, playerHeight: targetHeight}, 0.5, { ease: FlxEase.linear, onStart: onStart, onUpdate: onUpdate, onComplete: onComplete, type: ONESHOT });
		FlxTween.tween(this, { playerWidth: targetWidth, playerHeight: targetHeight}, 0.1, { type: FlxTweenType.PINGPONG, ease: FlxEase.linear, onComplete: updateHitboxNC});

		origin.set(playerWidth/2, playerHeight);
		setGraphicSize(Math.round(playerWidth), Math.round(playerHeight));
	
		//origin.set(width/2, height);
		
		//width = playerWidth;
		//height = playerHeight;
		//offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		//updateHitboxNC();
		
	}
//tween:FlxTween
	public function updateHitboxNC(tween:FlxTween):Void
	{
		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;
		offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
	}

	public function handleActionStates():Void
	{
		switch (actionState())
		{
			case (ActionState.Normal):
				setHeight(HEIGHT_NORMAL);
			case (ActionState.Crouching):
				setHeight(HEIGHT_CROUCHING);
			case (ActionState.Jumping):
				setHeight(HEIGHT_JUMPING);
			case (ActionState.Sliding):
				setHeight(HEIGHT_CROUCHING);
			case (ActionState.Null):
		}
	}
}