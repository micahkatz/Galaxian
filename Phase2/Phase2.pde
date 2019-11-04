/*
*/
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

// The dimensions of the monster grid.
int monsterCols = 6;
int monsterRows = 5; 

long mmCounter = 0;
int mmStep = 1; 

//Missiles variables
int missileSpeed = 500;
double upRadians = 4.71238898;

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
  
  // The Missles
  missile = buildMissile();
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

Sprite buildMissile()
{
  // The Missile
  Sprite sprite  = new Sprite(this, "rocket.png", 10);
  sprite.setScale(.5);
  sprite.setDead(true); // Initially hide the missile
  return sprite;
}

void stopMissile() 
{
  missile.setSpeed(0, upRadians);
  missile.setDead(true);
}

// Pick the first monster on the grid that is not dead.
// Return null if they are all dead.
Sprite pickNonDeadMonster() 
{
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!monster.isDead()) {
      return monster;
    }
  }
  return null;
}

// Executed before draw() is called 
public void pre() 
{    
  checkKeys();
  processCollisions();
  moveMonsters();

  // If missile flies off screen
  if (!missile.isDead() && ! missile.isOnScreem()) {
    stopMissile();
  }
  if (pickNonDeadMonster() == null) {
    resetMonsters();
  }


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
      fireMissile();
    }
  }
}

void fireMissile() 
{
  if (missile.isDead() && !ship.isDead()) {
    missile.setPos(ship.getPos());
    missile.setSpeed(missileSpeed, upRadians);
    missile.setDead(false);
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
  // Detect collisions between Grid Monsters and Missile
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!missile.isDead() && !monster.isDead() 
      && monster != fallingMonster 
      && missile.bb_collision(monster)) {
      //score += gridMonsterPts;
      monsterHit(monster);
      missile.setDead(true);
    }
  }
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
