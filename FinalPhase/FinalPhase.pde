/*
*/
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

//Wave System
int wave = 0;
boolean displayWave = false;
int timer;
int interval = 3;

//Background setup
PImage img;
int y = 1;
int y2 = 1;

// The dimensions of the monster grid.
int monsterCols = 8;
int monsterRows = 5; 

long mmCounter = 0;
int mmStep = 1; 

//Missiles variables
int missileSpeed = 500 - 2*wave;
double upRadians = 4.71238898;

// Lower difficulty values introduce a more 
// random falling monster descent. 
int difficulty = 100 - wave;
double fmRightAngle = 0.3490; // 20 degrees
double fmLeftAngle = 2.79253; // 160 degrees
double fmSpeed = 150 + int(random(2))*wave;

boolean gameOver = false;
boolean bonusGiven = false;
int score = 0;
int lives = 3;
int bossHealth = 10 + wave;
int fallingMonsterPts = 200;
int gridMonsterPts = 100;

Sprite ship, missile1, missile2, fallingMonster, explosion, gameOverSprite;
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

  img = loadImage("Background.png");
  size(700, 500);
  smooth();
  S4P.messagesEnabled(true);
  buildSprites();
  resetMonsters();

  // Ship Explosion Sprite
  explosion = new Sprite(this, "explosion_strip16.png", 17, 1, 90);
  explosion.setScale(1);

  // Game Over Sprite
  gameOverSprite = new Sprite(this, "gameOver.png", 100);
  gameOverSprite.setDead(true);
}

void buildSprites()
{
  // The Ship
  ship = buildShip();

  // The Grid Monsters 
  buildMonsterGrid();

  // The Missles
  missile1 = buildMissile();
  missile2 = buildMissile();
}

Sprite buildShip()
{
  Sprite ship = new Sprite(this, "ship.png", 50);
  ship.setXY(width/2, height - 30);
  ship.setVelXY(0.0f, 0);
  ship.setScale(1);
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

void replaceFallingMonster() 
{
  if (fallingMonster != null) {
    fallingMonster.setDead(true);
    fallingMonster = null;
  }

  // select new falling monster 
  fallingMonster = pickNonDeadMonster();
  if (fallingMonster == null) {
    return;
  }

  fallingMonster.setSpeed(fmSpeed, fmRightAngle);
  // Domain keeps the moving sprite within specific screen area 
  fallingMonster.setDomain(0, 0, width, height+100, Sprite.REBOUND);
}

// Build individual monster
Sprite buildMonster() 
{
  Sprite monster = new Sprite(this, "monster.png", 30);
  monster.setScale(1.25);
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
  missile1.setSpeed(0, upRadians);
  missile1.setDead(true);
  missile2.setSpeed(0, upRadians);
  missile2.setDead(true);
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
  if (!missile1.isDead() && ! missile1.isOnScreem() || !missile2.isDead() && ! missile2.isOnScreem()) {
    stopMissile();
  }

  if (pickNonDeadMonster() == null) {
    wave++;
    resetMonsters();
  }

  // if falling monster is off screen
  if (fallingMonster == null || !fallingMonster.isOnScreem()) {
    replaceFallingMonster();
  }

  // if score reaches 10000, a bonus lives is given.
  if (score == 10000 && bonusGiven == false)
  {
    lives++;
    bonusGiven = true;
  }

  S4P.updateSprites(stopWatch.getElapsedTime());
} 

void checkKeys() 
{
  if (focused) {
    ship.setX(mouseX);

    if (mousePressed && mouseButton == LEFT) {
      fireMissile();
    }
  }
}

void fireMissile() 
{
  if (missile1.isDead() && missile2.isDead() && !ship.isDead()) {
    missile1.setXY(ship.getX()-10, ship.getY());
    missile2.setXY(ship.getX()+10, ship.getY());
    missile1.setSpeed(missileSpeed, upRadians);
    missile2.setSpeed(missileSpeed, upRadians);
    missile1.setDead(false);
    missile2.setDead(false);
    soundPlayer.playPop();
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

  // Move Falling Monster
  if (fallingMonster != null) {
    if (int(random(difficulty)) == 1) {
      // Change FM Speed
      fallingMonster.setSpeed(fallingMonster.getSpeed() 
        + random(-40, 40));
      // Reverse FM direction.
      if (fallingMonster.getDirection() == fmRightAngle) 
        fallingMonster.setDirection(fmLeftAngle);
      else
        fallingMonster.setDirection(fmRightAngle);
    }
  }
}

void explodeShip() 
{
  soundPlayer.playExplosion();
  explosion.setPos(ship.getPos());
  explosion.setFrameSequence(0, 16, 0.1, 1);
  ship.setDead(true);
}

// Detect collisions between sprites
void processCollisions() 
{
  // Detect collisions between Grid Monsters and Missile
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!missile1.isDead() && !monster.isDead() 
      && monster != fallingMonster 
      && missile1.bb_collision(monster)) {
      score += gridMonsterPts;
      monsterHit(monster);
      missile1.setDead(true);
    }
    if (!missile2.isDead() && !monster.isDead() 
      && monster != fallingMonster 
      && missile2.bb_collision(monster)) {
      score += gridMonsterPts;
      monsterHit(monster);
      missile2.setDead(true);
    }
  }

  // Between Falling Monster and Missile
  if (!missile1.isDead() && fallingMonster != null 
    && missile1.cc_collision(fallingMonster)) {
    score += fallingMonsterPts;
    monsterHit(fallingMonster); 
    missile1.setDead(true);
    fallingMonster = null;
  }
  if (!missile2.isDead() && fallingMonster != null 
    && missile2.cc_collision(fallingMonster)) {
    score += fallingMonsterPts;
    monsterHit(fallingMonster); 
    missile2.setDead(true);
    fallingMonster = null;
  }

  // Between Falling Monster and Ship
  if (fallingMonster!= null && !ship.isDead() 
    && fallingMonster.bb_collision(ship)) {
    monsterHit(fallingMonster);
    fallingMonster = null;
    lives--;
    if (lives == 0)
    {
      explodeShip();
      gameOver = true;
    }
  }
}

void monsterHit(Sprite monster) 
{
  //soundPlayer.playPop();
  monster.setDead(true);
}

void drawScore() 
{
  textSize(20);
  String msg = " Score: " + score;
  text(msg, 10, 30);
}

void drawLives()
{
  textSize(20);
  String msg = " Lives: " + lives;
  text(msg, 10, 55);
}

void drawGameOver() 
{
  soundPlayer.playGameOver();
  gameOverSprite.setXY(width/2, height/2);
  gameOverSprite.setDead(false);
}

int gameOverCount = 0;

public void draw() 
{

  y = -frameCount % img.height;
  copy(img, 0, y, width, img.height, 0, 0, width, img.height);
  y2 = -img.height - y;
  if (y2 < height)
  {
    copy(img, 0, 0, width, img.height, 0, y2, width, img.height);
  }

  drawScore();
  drawLives();
  S4P.drawSprites();

  if (gameOver) {
    if (gameOverCount == 0) {

      soundPlayer.stopBgMusic();
      drawGameOver();
      gameOverCount ++;
    }
  } else {

    soundPlayer.playBgMusic();
  }
}
