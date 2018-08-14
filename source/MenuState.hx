package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import Sys;

class MenuState extends FlxUIState
{
  override public function create():Void
  {
    _xml_id = "menustate";
    super.create();
  }

  override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
  {
    switch (name)
    {
      case "click_button":
        if (params != null && params.length > 0)
        {
          //FlxG.sound.play(AssetPaths.select__wav);
          switch (Std.string(params[0]))
          {
            case "join": FlxG.switchState(new PlayState());
          }
        }
    }
  }
}
