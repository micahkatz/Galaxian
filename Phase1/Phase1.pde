/*
*/
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

// The dimensions of the monster grid.
int monsterCols = 10;
int monsterRows = 5; 

long mmCounter = 0;
int mmStep = 1; 

Sprite ship, missile, fallingMonster, explosion, gameOverSprite;
Sprite monsters[] = new Sprite[monsterCols * monsterRows];

KeyboardController kbController;
SoundPlayer soundPlayer;
StopWatch stopWatch = new StopWatch();

void setup() 
{
  kbController = new KeyboardController(this);
  soundPlayer = new SoundPlayer(this);  

  // register the function (pre) that will be called
  // by Processing before the draw() function. 
  registerMethod("pre", this);

  size(700, 500);
  S4P.messagesEnabled(true);
  buildSprites();
  resetMonsters();
}

void buildSprites()
{
  // The Ship
  ship = buildShip();

  // The Grid Monsters 
  buildMonsterGrid();
}

Sprite buildShip()
{
  Sprite ship = new Sprite(this, "ship.png", 50);
  ship.setXY(width/2, height - 30);
  ship.setVelXY(0.0f, 0);
  ship.setScale(.75);
  ship.setRot(3.14159);
  // Domain keeps the moving sprite withing specific screen area 
  ship.setDomain(0, height-ship.getHeight(), width, height, Sprite.HALT);


  return ship;
}

// Populate the monsters grid 
void buildMonsterGrid() 
{
  for (int idx = 0; idx < monsters.length; idx++ ) {
    monsters[idx] = buildMonster();
  }
}

// Arrange Monsters into a grid
void resetMonsters() 
{
  for (int idx = 0; idx < monsters.length; idx++ ) {
    Sprite monster = monsters[idx];
    monster.setSpeed(0, 0);

    double mwidth = monster.getWidth() + 20;
    double totalWidth = mwidth * monsterCols;
    double start = (width - totalWidth)/2 - 25;
    double mheight = monster.getHeight();
    int xpos = (int)((((idx % monsterCols)*mwidth)+start));
    int ypos = (int)(((int)(idx / monsterCols)*mheight)+50);
    monster.setXY(xpos, ypos);

    monster.setDead(false);
  }
}

// Build individual monster
Sprite buildMonster() 
{
  Sprite monster = new Sprite(this, "monster.png", 30);
  monster.setScale(.5);
  monster.setDead(false);

  return monster;
}

// Executed before draw() is called 
public void pre() 
{    
  checkKeys();
  processCollisions();
  moveMonsters();

  S4P.updateSprites(stopWatch.getElapsedTime());
} 

void checkKeys() 
{
  if (focused) {
    if (kbController.isLeft()) {
      ship.setX(ship.getX()-10);
    }
    if (kbController.isRight()) {
      ship.setX(ship.getX()+10);
    }
    if (kbController.isSpace()) {
      //fire missile added in following phases
    }
  }
}

void moveMonsters() 
{  
  // Move Grid Monsters
  mmCounter++;
  if ((mmCounter % 100) == 0) mmStep *= -1;

  for (int idx = 0; idx < monsters.length; idx++ ) {
    Sprite monster = monsters[idx];
    if (!monster.isDead()&& monster != fallingMonster) {
      monster.setXY(monster.getX()+mmStep, monster.getY());
    }
  }
}

// Detect collisions between sprites
void processCollisions() 
{
  // Implemented in later phases
}

void monsterHit(Sprite monster) 
{
  //soundPlayer.playPop();
  monster.setDead(true);
}

public void draw() 
{
  background(0);
  S4P.drawSprites();
}
