
import org.gamecontrolplus.*;
import net.java.games.input.*;

class KeyboardController {

  ControlIO controllIO;
  ControlDevice keyboard;
  ControlButton spaceBtn, leftArrow, rightArrow, downArrow;

  KeyboardController(PApplet applet) {
    controllIO = ControlIO.getInstance(applet);
      
    
    //keyboard = controllIO.getDevice("Keyboard"); // FOR WINDOWS
    keyboard = controllIO.getDevice("Apple Internal Keyboard / Trackpad"); // FOR MAC
    
    //spaceBtn = keyboard.getButton("Space"); // FOR WINDOWS
    spaceBtn = keyboard.getButton(" "); // FOR MAC
    
    leftArrow = keyboard.getButton("Left");   
    rightArrow = keyboard.getButton("Right");
    downArrow = keyboard.getButton("Down");
  }

  boolean isDown() {
    return downArrow.pressed();
  }

  boolean isLeft() {
    return leftArrow.pressed();
  }

  boolean isRight() {
    return rightArrow.pressed();
  }

  boolean isSpace() {
    return spaceBtn.pressed();
  }
}
