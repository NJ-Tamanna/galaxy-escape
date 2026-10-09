/**
 * Represents the escape portal required to win the game.
 * Extends the SpaceItem base class.
 */
class Portal extends SpaceItem {
  
  /**
   * Constructor initializing the kinematic Box2D body for the portal.
   * @param x The horizontal spawn position.
   * @param y The vertical spawn position.
   */
  Portal(float x, float y) {
    r = 40; 
    col = color(150, 0, 255); 
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.KINEMATIC; // Moves smoothly, ignores physical collisions
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    body = box2d.createBody(bd);
    
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.isSensor = true; // Still triggers contact listener without a physical bump
    
    body.createFixture(fd);
    body.setLinearVelocity(new Vec2(0, -5)); 
    body.setUserData(this);
  }
  
  /**
   * Renders the portal as a glowing purple circle.
   */
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    
    pushMatrix();
    translate(pos.x, pos.y);
    fill(col);
    stroke(255);
    strokeWeight(4);
    ellipse(0, 0, r * 2, r * 2);
    
    fill(50, 0, 100);
    noStroke();
    ellipse(0, 0, r, r);
    popMatrix();
  }
}
