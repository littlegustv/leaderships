package;

import hxbit.Serializable;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.addons.display.FlxStarField;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

import Objects;

class PlayState extends FlxState
{
  var player:FlxSprite;
  var health = 10;
  var target:FlxSprite;

  var exterior:FlxGroup;
  var enemies:FlxTypedGroup<FlxSprite>;
  var player_bullets:FlxGroup;
  
  var interior:FlxGroup;
  var stations:FlxTypedGroup<Station>;

  var crew:FlxTypedGroup<Crew>;//FlxSprite>;
  var crewmember:Crew;
  var walls:FlxTilemap;

  var PLAYERSPEED = 100;

  var CONTROLS:String = "Interior";
  var GRAVITY:Float = 300;
  var JUMPSPEED:Float = 150;
  var MOVESPEED:Float = 80;

  function change(to:String):Void {
    crewmember.controls = to;
    if (to == "Interior") {
      interior.visible = true;
      exterior.visible = false;
    } else {
      interior.visible = false;
      exterior.visible = true;
    }
  }

	override public function create():Void
	{
		super.create();

    FlxG.debugger.drawDebug = true;

    FlxG.worldBounds.set(-16, -16, FlxG.width + 16, FlxG.height + 16);

    //var stars = new FlxBackdrop(AssetPaths.stardust__png);
    //add(stars);

    var stars = new FlxStarField2D(0, 0, FlxG.width, FlxG.height);
    add(stars);

    interior = new FlxGroup();
    interior.visible = true;
    add(interior);

    stations = new FlxTypedGroup<Station>();
    interior.add(stations);

    exterior = new FlxGroup();
    exterior.visible = false;
    add(exterior);

    enemies = new FlxTypedGroup<FlxSprite>();
    player_bullets = new FlxGroup(); 
    exterior.add(player_bullets);
    exterior.add(enemies);

    target = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
    target.loadGraphic(AssetPaths.target__png, true, 16, 16);
    target.animation.add("none", [0], 1, true);
    target.animation.add("hit", [1], 1, true);
    target.animation.play("none");
    exterior.add(target);

    var map = new TiledMap('assets/data/interior.tmx');
    walls = new FlxTilemap();
    walls.useScaleHack = false;
    walls.alpha = 0.9; // this for SOME reason stops it from flickering/vanishing randomly?????
    walls.loadMapFromArray(cast(map.getLayer("Floors"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
    interior.add(walls);

    var decor = new FlxTilemap();
    decor.loadMapFromArray(cast(map.getLayer("Decor"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tileset__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
    decor.alpha = 0.5;

    interior.add(decor);

    var objects = cast(map.getLayer("Objects"), TiledObjectLayer).objects;

    for (i in 0...objects.length) {
      if (objects[i].type == "Station") {
        var station = new Station(objects[i].x, objects[i].y, 16, 16);
        station.name = objects[i].name;
        stations.add(station);

        var text = new FlxText(station.x, station.y - 16, 100, station.name, 8);
        interior.add(text);
      }
    }

    crew = new FlxTypedGroup<Crew>();
    for (i in 0...3) {    
      var c = new Crew(FlxG.random.int(10, 20) * 16, 7 * 16);
      c.loadGraphic(AssetPaths.cosmonaut__png, true, 16, 16);
      c.animation.add("red", [0, 1], 4, true);
      c.animation.add("green", [2, 3], 4, true);
      c.animation.play(FlxG.random.getObject(["red", "green"]));
      //c.acceleration.y = GRAVITY;
      //crew.maxVelocity.y = 100;
      if (i == 0) {
        crewmember = c;
        trace('here', crewmember);
      }
      crew.add(c);
    }
    interior.add(crew);

    player = new FlxSprite(100, 100);
    player.loadGraphic(AssetPaths.saucer__png, true, 18, 16);
    player.animation.add("main", [0], 1, true);
    player.animation.play("main");
    exterior.add(player);
    //FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN, 0.2);
	}

	override public function update(elapsed:Float):Void
	{
    if (crewmember.controls == "Pilot") {
      var direction = [0, 0];
      if (FlxG.keys.pressed.UP) {
        direction[1] -= 1;
      }
      if (FlxG.keys.pressed.DOWN) {
        direction[1] += 1;
      }
      if (FlxG.keys.pressed.RIGHT) {
        direction[0] += 1;
      }
      if (FlxG.keys.pressed.LEFT) {
        direction[0] -= 1;
      }
      player.velocity.x = PLAYERSPEED * direction[0];
      player.velocity.y = PLAYERSPEED * direction[1];
    } else if (crewmember.controls == "Gunner") {
      target.setPosition(FlxG.mouse.x, FlxG.mouse.y);
      if (FlxG.mouse.justPressed) {
        FlxG.sound.play(AssetPaths.shoot__wav, 0.5);
        var bullet = new FlxSprite(player.x + 4, player.y + 4);
        bullet.loadGraphic(AssetPaths.projectile__png, true, 8, 8);
        bullet.animation.add("main", [0, 1], 1, true);
        var theta = FlxAngle.angleBetween(player, target);
        bullet.velocity.x = 250 * Math.cos(theta);
        bullet.velocity.y = 250 * Math.sin(theta);
        bullet.animation.play("main");
        player_bullets.add(bullet);
      }
    }
/*
    if (FlxG.keys.justPressed.F1) {
      change("Pilot");
    }
    if (FlxG.keys.justPressed.F2) {
      change("Gunner");
    }
    if (FlxG.keys.justPressed.F3) {
      change("Interior");
    }
*/
    if (FlxG.keys.justPressed.ESCAPE && crewmember.controls != "Interior") {
      change("Interior");
      crewmember.station = null;
    }

    if (FlxG.keys.justPressed.TAB && crewmember.controls == "Interior") {
      crewmember = crew.getRandom();
    }

    FlxSpriteUtil.screenWrap(player, true, true, true, true);

    FlxG.overlap(player_bullets, enemies, function (pb, e) {
      player_bullets.remove(pb);
      enemies.remove(e);
      FlxG.sound.play(AssetPaths.hit__wav, 0.4);
    });

    FlxG.overlap(player, enemies, function (p, e) {
      enemies.remove(e);
      FlxG.sound.play(AssetPaths.hurt__wav);
      FlxG.camera.shake(0.025);
      health -= 1;
      if (health <= 0) {
        FlxG.switchState(new PlayState());
      }
    });

    // remove enemies that are too far away
    for (enemy in enemies)
    {
      if (FlxMath.distanceBetween(enemy, player) > 2 * FlxG.width) {
        enemies.remove(enemy);
      }
    }

    if (FlxG.random.bool(10) == true) {
      var theta = FlxG.random.float() * 2 * 3.14159265;
      var enemy = new FlxSprite(FlxG.width / 2 + Math.cos(theta) * FlxG.width, FlxG.height / 2 + Math.sin(theta) * FlxG.width);
      enemy.loadGraphic(AssetPaths.ghost__png, true, 16, 16);
      enemy.animation.add("main", [0, 1], 4, true);
      enemy.velocity.x = -Math.cos(theta) * 100;
      enemy.velocity.y = -Math.sin(theta) * 100;
      enemy.animation.play("main");
      enemies.add(enemy);
    }

    if (crewmember.controls == "Interior") {
      FlxG.overlap(crewmember, stations, function (crewmember, station) {
        if (FlxG.keys.pressed.SPACE) {
          change(station.name);
          
          if (station.operator == null) {
            station.operator = crewmember;
            //crewmember.station = station;
          } else if (station.operator == crewmember) {
            trace('already there');
          } else {
            trace('busy');
          }
          
        }
      });
    }

    // 1. replace 'crew' with FlxGroup
    // 2. add single var 'crewmember' or something (current crewmember)
    // 3. CONTROLS, collisions are specific to crewmember
    // 4. TAB to toggle control of crewmembers

    FlxG.collide(crew, walls);
    // needs to be AFTER .collide for .isTouching to work
    for (c in crew) {
      if (c.isTouching(FlxObject.DOWN)) {
        c.acceleration.y = 0;
      } else {
        c.acceleration.y = GRAVITY;
      }      
    }

    if (crewmember.controls == "Interior") {
      crewmember.velocity.x = 0;
      //crew.velocity.y = 0;
      if (FlxG.keys.pressed.UP && crewmember.isTouching(FlxObject.DOWN)) {          
        crewmember.velocity.y = -JUMPSPEED;
      }
      if (FlxG.keys.pressed.RIGHT) {
        crewmember.velocity.x = MOVESPEED;
      } else if (FlxG.keys.pressed.LEFT) {
        crewmember.velocity.x = -MOVESPEED;
      }
    }

		super.update(elapsed);
	}
}
