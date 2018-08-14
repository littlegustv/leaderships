package;

import flixel.FlxObject;
import flixel.FlxSprite;

class Station extends FlxObject {
  public var name:String;
  public var operator:Crew;
}

class Crew extends FlxSprite {
  public var controls:String = "Interior";
  public var station:Station;
}