package ;

typedef PlayerData = {
  x: Int,
  y: Int,
  dir: Float,
  speed: Float,
  id: String
};


class Main {
  var server:mphx.server.impl.Server;
  public function new ()
  {
    server = new mphx.server.impl.Server("127.0.0.1",8000);

    server.onConnectionAccepted = function (reason:String, sender:mphx.connection.IConnection) {
      trace("Connection Accepted: ", reason);
    };

    server.onConnectionClose =function (reason:String, sender:mphx.connection.IConnection) {
      trace("Connection Closed: ", reason);
    };

    server.events.on("Join", function(data:Dynamic,sender:mphx.connection.IConnection)
    {
      trace("Player: "+data.id+" has joined!");

      sender.data = {
        x: data.x,
        y: data.y,
        dir: data.dir,
        id: data.id,
        speed: data.speed
      };
      server.broadcast("Join",data);
    });
    server.events.on("UpdateCrew",function(data:Dynamic,sender:mphx.connection.IConnection)
    {
      server.broadcast("UpdateCrew",data);
    });
    server.events.on("UpdateShip",function(data:Dynamic,sender:mphx.connection.IConnection)
    {
      server.broadcast("UpdateShip",data);
    });
    server.events.on("SpawnBullet",function(data:Dynamic,sender:mphx.connection.IConnection)
    {
      server.broadcast("SpawnBullet",data);
    });
    server.events.on("SpawnEnemy",function(data:Dynamic,sender:mphx.connection.IConnection)
    {
      server.broadcast("SpawnEnemy",data);
    });
    server.start();
  }
  public static function main ()
  {
    new Main();
  }
}