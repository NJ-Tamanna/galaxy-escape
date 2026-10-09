/*
 * GALAXY ESCAPE
 * * Concept: A survival evasion game where the player controls a rocket ship.
 * The goal is to catch Energy Crystals (Stars) to gain points/time and avoid 
 * Space Scrap (Cacti) to preserve health. Upon reaching 300 points, an escape 
 * portal unlocks.
 *
 * Credits/References:
 * The integration of the Box2D physics engine (Box2DProcessing, BodyDef, 
 * FixtureDef, PolygonShape, etc.) is based on the Box2D examples and 
 * tutorials provided by Daniel Shiffman in "The Nature of Code".
 */

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.callbacks.ContactImpulse;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.collision.Manifold;
import org.jbox2d.dynamics.contacts.Contact;

// =========================================
// --- GAMEPLAY TWEAKS & GLOBAL VARIABLES ---
// =========================================

// The score required to trigger the portal spawn
int requiredScore = 300;     

// The maximum score the player can achieve
int maxScore = 300;          

// The initial amount of time (in seconds) the player has to survive
float startingTime = 60.0;   

// The vertical gravity vector applied to the Box2D world
float gravityPull = -15.0;   

// The probability (0.0 to 1.0) of a new item spawning each frame
float spawnChance = 0.06;    

// The horizontal velocity applied to the player's ship
float shipSpeed = 40.0;      

// The physical density (mass) of the Energy Crystals
float crystalDensity = 1.0;  

// The physical density (mass) of the Space Scrap
float scrapDensity = 10.0;   

// The main Box2D physics world object
Box2DProcessing box2d;

// Polymorphic list storing all falling physics items
ArrayList<SpaceItem> items;

// List storing the background star animation objects
ArrayList<StarBackground> stars; 

// The main player controlled ship
Ship player;

// The portal object required for winning
Portal escapePortal;

// Tracks if the left arrow key is currently held down
boolean leftPressed = false;

// Tracks if the right arrow key is currently held down
boolean rightPressed = false;

// The player's current score
int score = 0;

// The player's current health (0 to 100)
float health = 100.0;

// The amount of time remaining before Game Over
float timeLeft = startingTime; 

// The total real-time seconds the player has survived this round
float timePlayed = 0.0; 

// Warning message displayed if the player touches the portal without requirements
String portalWarning = ""; 

// Timer controlling how long the portal warning stays on screen
int warningTimer = 0;      

// The current state of the game loop ("START_SCREEN", "PLAYING", etc.)
String gameState = "START_SCREEN"; 

// A specific message explaining why the player lost the game
String failReason = ""; 

/**
 * Initializes the Processing sketch, builds the Box2D world, 
 * sets up the boundaries, and spawns the initial game objects.
 */
void setup() {
  size(600, 600);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, gravityPull); 
  box2d.world.setContactListener(new CustomContactListener());
  pixelDensity(1);
  items = new ArrayList<SpaceItem>();
  player = new Ship(width / 2, height - 100);
  
  stars = new ArrayList<StarBackground>();
  for(int i = 0; i < 100; i++) {
    stars.add(new StarBackground());
  }
  
  // Creates invisible static boundaries on the left and right sides
  BodyDef bd = new BodyDef();
  bd.type = BodyType.STATIC;
  PolygonShape ps = new PolygonShape();
  
  bd.position.set(box2d.coordPixelsToWorld(0, height/2));
  Body leftWall = box2d.createBody(bd);
  ps.setAsBox(box2d.scalarPixelsToWorld(1), box2d.scalarPixelsToWorld(height/2));
  leftWall.createFixture(ps, 0);
  
  bd.position.set(box2d.coordPixelsToWorld(width, height/2));
  Body rightWall = box2d.createBody(bd);
  ps.setAsBox(box2d.scalarPixelsToWorld(1), box2d.scalarPixelsToWorld(height/2));
  rightWall.createFixture(ps, 0);
}

/**
 * The main 60 FPS loop handling physics steps, rendering, 
 * user input, and game state transitions.
 */
void draw() {
  background(10, 10, 30); 
  
  // Update and draw the animated starfield
  for (StarBackground s : stars) {
    if (gameState.equals("PLAYING") || gameState.equals("PORTAL_INBOUND")) {
      s.update(); 
    }
    s.display();
  }
  
  if (gameState.equals("START_SCREEN")) {
    drawStartScreen();
    return; 
  }
  
  box2d.step();
  
  if (gameState.equals("PLAYING") || gameState.equals("PORTAL_INBOUND")) {
    timeLeft = max(0, timeLeft - 1.0 / frameRate); 
    timePlayed += 1.0 / frameRate; 
    
    // Random item spawning
    if (random(1) < spawnChance) {
      float spawnX = random(50, width - 50);
      if (random(1) > 0.5) items.add(new EnergyCrystal(spawnX, -50));
      else items.add(new SpaceScrap(spawnX, -50));
    }
    
    // Portal unlock condition
    if (gameState.equals("PLAYING") && score >= requiredScore) {
      gameState = "PORTAL_INBOUND";
      escapePortal = new Portal(random(50, width - 50), -50); 
      items.add(escapePortal); 
    }
    
    // Game over conditions
    if (timeLeft <= 0) {
      gameState = "GAME_OVER"; 
      failReason = "You ran out of time!";
    } else if (health <= 0) {
      gameState = "GAME_OVER";
      failReason = "Your ship was destroyed!";
    }
  }
  
  // Ship movement handler
  if (gameState.equals("PLAYING") || gameState.equals("PORTAL_INBOUND")) {
    if (leftPressed) player.move(-shipSpeed); 
    else if (rightPressed) player.move(shipSpeed);
    else player.move(0); 
  } else {
    player.move(0); 
  }
  
  player.display();
  
  // Render items and clean up physics bodies if off-screen or destroyed
  for (int i = items.size() - 1; i >= 0; i--) {
    SpaceItem item = items.get(i);
    item.display();
    
    if (item.isOffScreen() || item.deleteMe) {
      if (item instanceof Portal && item.isOffScreen()) {
        gameState = "PLAYING"; // Respawn portal if missed
      }
      item.killBody(); 
      items.remove(i); 
    }
  }
  
  drawHUD();
  drawEndScreens();
}

/**
 * Safely destroys all physics bodies and resets game variables 
 * to allow the player to restart without restarting the sketch.
 */
void resetGame() {
  for (int i = items.size() - 1; i >= 0; i--) {
    items.get(i).killBody();
  }
  items.clear();
  
  box2d.destroyBody(player.body);
  player = new Ship(width / 2, height - 100);
  
  score = 0;
  health = 100.0;
  timeLeft = startingTime;
  timePlayed = 0.0;
  leftPressed = false;
  rightPressed = false;
  portalWarning = "";
  warningTimer = 0;
  failReason = "";
  
  gameState = "START_SCREEN";
}

/**
 * Draws the title screen and instructions.
 */
void drawStartScreen() {
  textAlign(CENTER, CENTER);
  fill(0, 255, 255);
  textSize(40);
  text("GALAXY ESCAPE", width/2, height/2 - 150);
  
  fill(255);
  textSize(20);
  text("HOW TO PLAY:", width/2, height/2 - 60);
  
  textSize(16);
  fill(0, 255, 255);
  text("Catch Blue Stars to gain points, time, and +1% health.", width/2, height/2 - 20);
  fill(255, 60, 60);
  text("Dodge Red Cacti! They remove points and 10% health.", width/2, height/2 + 10);
  
  fill(255);
  text("Reach " + requiredScore + " points to unlock the Escape Portal.", width/2, height/2 + 50);
  fill(255, 0, 0);
  text("WARNING: You need >50% Health to enter the portal!", width/2, height/2 + 80);
  
  fill(0, 255, 0);
  textSize(24);
  text("PRESS 'P' TO START", width/2, height/2 + 150);
}

/**
 * Draws the Heads Up Display including health bars, score bars, and timers.
 */
void drawHUD() {
  textAlign(LEFT, TOP);
  
  fill(255);
  textSize(16);
  text("Health: " + int(health) + "%", 20, 20);
  
  fill(100);
  noStroke();
  rectMode(CORNER);
  rect(20, 40, 200, 15);
  
  if (health > 50) fill(0, 255, 0); 
  else if (health > 25) fill(255, 255, 0); 
  else fill(255, 0, 0); 
  
  float currentHealth = constrain(health, 0, 100);
  rect(20, 40, currentHealth * 2, 15); 
  
  stroke(255);
  noFill();
  rect(20, 40, 200, 15);

  fill(255);
  text("Score: " + score + " / " + maxScore, 20, 70);
  
  fill(100);
  noStroke();
  rect(20, 90, 200, 15);
  
  fill(0, 150, 255); 
  float mappedScore = map(constrain(score, 0, maxScore), 0, maxScore, 0, 200);
  rect(20, 90, mappedScore, 15);
  
  stroke(255);
  noFill();
  rect(20, 90, 200, 15);
  
  fill(255);
  textAlign(RIGHT, TOP);
  textSize(20);
  text("Time: " + nf(timeLeft, 0, 1) + "s", width - 20, 20);
  
  if (gameState.equals("PORTAL_INBOUND")) {
    textAlign(CENTER, TOP);
    fill(150, 0, 255); 
    textSize(24);
    text("PORTAL UNLOCKED! ESCAPE NOW!", width/2, 20);
  }
  
  if (warningTimer > 0) {
    textAlign(CENTER, CENTER);
    fill(255, 100, 100);
    textSize(22);
    text(portalWarning, width/2, 150);
    warningTimer--;
  }
}

/**
 * Draws the victory or game over screens depending on the state.
 */
void drawEndScreens() {
  if (!gameState.equals("GAME_OVER") && !gameState.equals("VICTORY")) return;
  
  textAlign(CENTER, CENTER);
  if (gameState.equals("GAME_OVER")) {
    fill(255, 0, 0);
    textSize(50);
    text("GAME OVER", width/2, height/2 - 20);
    textSize(20);
    fill(255);
    text(failReason, width/2, height/2 + 30);
    fill(0, 255, 255);
    text("Time Played: " + nf(timePlayed, 0, 1) + "s", width/2, height/2 + 70);
  } else if (gameState.equals("VICTORY")) {
    fill(0, 255, 0);
    textSize(50);
    text("YOU ESCAPED!", width/2, height/2 - 20);
    textSize(20);
    fill(0, 255, 255);
    text("Time Played: " + nf(timePlayed, 0, 1) + "s", width/2, height/2 + 30);
  }
  
  fill(255, 255, 0);
  textSize(24);
  text("PRESS 'R' TO RESTART", width/2, height/2 + 130);
}

/**
 * Built-in Processing function triggered when a key is pressed down.
 */
void keyPressed() {
  if (gameState.equals("START_SCREEN") && (key == 'p' || key == 'P')) {
    gameState = "PLAYING";
  }
  
  if ((gameState.equals("GAME_OVER") || gameState.equals("VICTORY")) && (key == 'r' || key == 'R')) {
    resetGame();
  }
  
  if (key == CODED) {
    if (keyCode == LEFT) leftPressed = true;
    if (keyCode == RIGHT) rightPressed = true;
  }
}

/**
 * Built-in Processing function triggered when a key is released.
 */
void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) leftPressed = false;
    if (keyCode == RIGHT) rightPressed = false;
  }
}

/**
 * A simple class representing the background warp-speed stars.
 */
class StarBackground {
  float x, y, speed, size;
  
  /**
   * Initializes the star at a random location with random speed.
   */
  StarBackground() {
    x = random(width);
    y = random(height);
    speed = random(5, 20); 
    size = map(speed, 5, 20, 1, 4);
  }
  
  /**
   * Moves the star downward to create the illusion of forward momentum.
   */
  void update() {
    y += speed;
    if (y > height) {
      y = 0;
      x = random(width);
      speed = random(5, 20);
    }
  }
  
  /**
   * Renders the star to the screen.
   */
  void display() {
    fill(255);
    noStroke();
    ellipse(x, y, size, size);
  }
}
