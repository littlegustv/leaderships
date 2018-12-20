package;

import flixel.FlxObject;
import flixel.FlxSprite;

typedef SyncData = {
  x: Int,
  y: Int,
  velocity: {
    x: Int,
    y: Int
  },
  id: String,
  client_id: String
//  angle: Float
};

class Station extends FlxObject {
  public var name:String;
  public var operator:Crew;
}

class Crew extends Synced {
  public var controls:String = "Interior";
  public var station:Station;
}

class Synced extends FlxSprite {
  public var data:SyncData;

  public function new (data:SyncData) {
    this.data = data;
    super(data.x, data.y);
    velocity.x = data.velocity.x;
    velocity.y = data.velocity.y;
  }

  public override function update(elapsed:Float) {
    data.x = Math.floor(x);
    data.y = Math.floor(y);
    data.velocity.x = Math.floor(velocity.x);
    data.velocity.y = Math.floor(velocity.y);
    super.update(elapsed);
  }

  public function receiveUpdate (data:SyncData) {
    this.data = data;
    setPosition(data.x, data.y);
    velocity.x = data.velocity.x;
    velocity.y = data.velocity.y;
    super.update(0);
  }

}