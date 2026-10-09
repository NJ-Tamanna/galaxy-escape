/**
 * Represents the hazardous red space cacti that damage the player.
 * Extends the SpaceItem base class.
 */
class SpaceScrap extends SpaceItem {
  
  /**
   * Constructor initializing the dynamic Box2D body for the scrap.
   * @param x The horizontal spawn position.
   * @param y The vertical spawn position.
   */
  SpaceScrap(float x, float y) {
    w = 30;
    h = 40;
    col = color(255, 60, 60); 
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    body = box2d.createBody(bd);
    
    PolygonShape ps = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w / 2);
    float box2dH = box2d.scalarPixelsToWorld(h / 2);
    ps.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = scrapDensity; 
    fd.friction = 0.8;
    fd.restitution = 0.1;
    
    body.createFixture(fd);
    body.setAngularVelocity(random(-3, 3));
    body.setUserData(this);
  }
  
  /**
   * Renders the scrap as a cactus-shaped object.
   */
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    rectMode(CENTER);
    fill(col);
    stroke(0);
    strokeWeight(2);
    
    // Main trunk
    rect(0, 0, 10, 36, 4); 
    
    // Left Arm
    rect(-8, -2, 8, 6, 2);
    rect(-11, -8, 6, 14, 2);
    
    // Right Arm
    rect(8, 4, 8, 6, 2);
    rect(11, -2, 6, 14, 2);
    
    popMatrix();
  }
}
