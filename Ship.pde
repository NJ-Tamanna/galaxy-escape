/**
 * Represents the player-controlled rocket ship.
 */
class Ship {
  
  // The Box2D physics body
  Body body;
  
  // The visual width of the ship
  float w = 50;
  
  // The visual height of the ship
  float h = 60;
  
  /**
   * Constructor that initializes the physics body of the ship.
   * @param x The starting horizontal pixel coordinate.
   * @param y The starting vertical pixel coordinate.
   */
  Ship(float x, float y) {
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    bd.fixedRotation = true; 
    
    body = box2d.createBody(bd);
    
    PolygonShape ps = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    ps.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = 10.0; 
    fd.friction = 0.5;
    fd.restitution = 0.2;
    
    body.createFixture(fd);
    body.setLinearDamping(5.0);
    body.setGravityScale(0.0); // Ship isn't affected by falling gravity
    body.setUserData(this); 
  }
  
  /**
   * Applies horizontal velocity to move the ship left or right.
   * @param speedX The velocity to apply on the X axis.
   */
  void move(float speedX) {
    body.setAwake(true); 
    body.setLinearVelocity(new Vec2(speedX, 0));
  }
  
  /**
   * Renders the complex retro rocket shape using Processing geometry.
   */
  void display() {
    Vec2 vel = body.getLinearVelocity();
    vel.y = 0; // Lock vertical movement
    body.setLinearVelocity(vel);
    
    Vec2 pixelPos = box2d.getBodyPixelCoord(body);
    
    pushMatrix();
    translate(pixelPos.x, pixelPos.y);
    rectMode(CENTER);
    
    // Animated Thruster Flame
    if (random(1) > 0.3) {
      fill(255, 150, 0);
      triangle(-8, 25, 8, 25, 0, random(35, 45));
      fill(255, 255, 0);
      triangle(-4, 25, 4, 25, 0, random(28, 34));
    }
    
    // Side Fins
    fill(255, 60, 60);
    stroke(255);
    strokeWeight(1);
    triangle(-10, 5, -10, 25, -22, 25);
    triangle(10, 5, 10, 25, 22, 25);
    
    // Main Body
    fill(230);
    rect(0, 5, 20, 40, 3);
    
    // Nose Cone
    fill(255, 60, 60);
    triangle(-10, -15, 10, -15, 0, -35);
    
    // Cockpit Window
    fill(100, 200, 255);
    stroke(150);
    ellipse(0, -5, 10, 10);
    
    popMatrix();
  }
}
