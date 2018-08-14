package;

import flixel.FlxObject;
import flixel.FlxSprite;

typedef CrewData = {
  x: Int,
  y: Int,
  velocity: {
    x: Int,
    y: Int
  },
  id: String
};

class Station extends FlxObject {
  public var name:String;
  public var operator:Crew;
}

class Crew extends FlxSprite {
  public var controls:String = "Interior";
  public var station:Station;

  public var data:CrewData;

  public function new (data:CrewData) {
    this.data = data;
    super(data.x, data.y);
  }

  public override function update(elapsed:Float) {
    data.x = Math.ceil(x);
    data.y = Math.ceil(y);
    data.velocity.x = Math.ceil(velocity.x);
    data.velocity.y = Math.ceil(velocity.y);
    super.update(elapsed);
  }

  public function receiveUpdate (data:CrewData) {
    this.data = data;
    setPosition(data.x, data.y);
    velocity.x = data.velocity.x;
    velocity.y = data.velocity.y;
  }

}