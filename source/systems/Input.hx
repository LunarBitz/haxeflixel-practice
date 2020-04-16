package systems;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class InputSystem
{
    private var inputs:Map<String, Int>;
    private var axis:Map<String, Float>;

    public function new(defaultEntries:Bool = true)
    {
        inputs = new Map<String, Int>();
        axis = new Map<String, Float>();

        if (defaultEntries)
        {
            createInput("left");
            createInput("right");
            createInput("up");
            createInput("down");
            createInput("jump");
            createInput("crouch");
            createInput("action_1");
            createInput("action_2");

            createAxis("horizontalAxis");
        }
    }

    /**
        Creates the map entries for input binding later on.
        @param name Name of entry to make.
        @param incHeld Create the key held/pressed entry?
        @param incPressed Create the key just pressed entry?
        @param incReleased Create the key just released entry?
    **/
    public function createInput(name:String, incHeld:Bool = true, incPressed:Bool = true, incReleased:Bool = true) 
    {
        if (!incHeld && !incPressed && !incReleased)
        {
            throw "No entry has been created within InputSystem.createInput(). Please set at least one of the booleans to true";
            return;
        }

        if (incHeld) { inputs[name] = -1; }
        if (incPressed) { inputs[name + "_just_pressed"] = -1; }
        if (incReleased) { inputs[name + "_released"] = -1; }
    }

    /**
        Creates the map entries for axis binding later on.
        @param name Name of entry to make.
    **/
    public function createAxis(name:String) 
    {
        axis[name] = 0;
    }

    /**
        Binds a list of keys to the specified entry.
        Also binds the "_just_pressed" and "_released" entries if previously created so there's no need to bind them directly.
        ```haxe
        bindInput("jump", [FlxKey.Z, FlxKey.SPACE]);
        bindInput("up", [FlxKey.UP]);
        ```
        @param name Name of axis to bind.
        @param keys List of keys that will be used to bind.
    **/
    public function bindInput(name:String, keys:Array<FlxKey>):Void 
    {
        inputs[name] = FlxG.keys.anyPressed(keys)? 1:0;

        if (inputs.exists(name + "_just_pressed"))
            inputs[name + "_just_pressed"] = FlxG.keys.anyJustPressed(keys)? 1:0;

        if (inputs.exists(name + "_released"))
            inputs[name + "_released"] = FlxG.keys.anyJustReleased(keys)? 1:0;
    }

    /**
        Binds two given input values to the specified entry.
        Concatenate "_just_pressed" or "_released" if you want to access inputs 
        respective to the names. For example:
        ```haxe
        bindAxis("horizontalAxis", getInput("left"), getInput("right"));
        ```
        @param name Name of axis to bind.
        @param negativeInput Input that would normally lead to a negative input (such as moving left / up).
        @param positiveInput Input that would normally lead to a positive input (such as moving right / down).
    **/
    public function bindAxis(name:String, negativeInput:Int, positiveInput:Int):Void
    {
        axis[name] = (positiveInput - negativeInput);
    }

    /**
        Gets the value from the `inputs` map with the specified `name` as the key.
        Concatenate "_just_pressed" or "_released" if you want to access inputs 
        respective to the names. For example:
        ```haxe
        getInput("left"); // Similar to (FlxG.keys.pressed.Left)? 1 : 0;
        getInput("left_just_pressed"); // Similar to (FlxG.keys.justPressed.Left)? 1 : 0;
        getInput("left_released"); // Similar to (FlxG.keys.justReleased.Left)? 1 : 0;
        ```
        @param name Name of input key to get.
        @return Int value from `inputs` map.
    **/
    public function getInput(name:String):Int
    {
        return inputs[name];
    }

    /**
        Gets the value from the `axis` map with the specified `name` as the key.
        @param name Name of axis key to get.
        @return Float value from `axis` map.
    **/
    public function getAxis(name:String):Float
    {
        return axis[name];
    }
}
