package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.effects.FlxGlitchSprite;
import flixel.system.FlxSound;

class PlayState extends FlxState
{
  var rooms:Dynamic = {};
  var glitchSprite:GlitchSprite;
  var player:Player;
  var activeRoom:Room;

  var iterationMusic:FlxSound;

  override public function create():Void {
    super.create();
    for(fileName in Reg.rooms) {
      Reflect.setField(rooms,
                       fileName,
                       new Room("assets/tilemaps/iteration/" + Reg.level + "/" + fileName + ".tmx"));
    }

    player = new Player();
    player.init();
    add(player);

    switchRoom("quarters");

    //FX
    add(new EffectSprite());
    glitchSprite = new GlitchSprite();
    add(glitchSprite);

    FlxG.debugger.drawDebug = true;
    //FlxG.sound.playMusic("assets/sounds/spacestation.mp3", 1, true);
    iterationMusic = FlxG.sound.load("assets/music/uhoh.mp3", 1, true);
  }
  
  override public function destroy():Void {
    super.destroy();
  }

  override public function update():Void {
    if (FlxG.keys.justPressed.RIGHT) {
      Reg.palette = 1;
    }
    if (FlxG.keys.justPressed.SPACE) {
      FlxG.sound.muted = true;
      glitchSprite.glitchOut();
    }
    super.update();
    
    player.resetFlags();

    checkExits();
    touchWalls();
  }

  private function touchWalls():Void {
    FlxG.collide(activeRoom.foregroundTiles, player, function(tile:FlxObject, player:Player):Void {
      if((player.touching & FlxObject.FLOOR) > 0) {
        player.setCollidesWith(Player.WALL_UP);
      }
    });
  }

  private function checkExits():Void {
    FlxG.overlap(activeRoom.exits, player, function(exit:ExitObject, player:Player):Void {
      if(player.x < 0) {
        player.x = FlxG.camera.width - player.width;
        switchRoom(exit.roomName);
      } else if(player.x + player.width > FlxG.camera.width) {
        iterationMusic.play();
        player.x = 0;
        switchRoom(exit.roomName);
      }
    });
  }

  public function switchRoom(roomName:String):Void {
    if (activeRoom != null) {
      remove(activeRoom.foregroundTiles);
      remove(activeRoom.exits);
    }
    activeRoom = Reflect.field(rooms, roomName);
    activeRoom.loadObjects(this);
    add(activeRoom.foregroundTiles);
    add(activeRoom.exits);

    Reg.palette = Std.parseInt(activeRoom.properties.palette);
  }
}
