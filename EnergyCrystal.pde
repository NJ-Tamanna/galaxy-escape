/**
 * Represents the beneficial blue stars that grant points and health.
 * Extends the SpaceItem base class.
 */
class EnergyCrystal extends SpaceItem {
  
  /**
   * Constructor initializing the dynamic Box2D body for the crystal.
   * @param x The horizontal spawn position.
   * @param y The vertical spawn position.
   */
  EnergyCrystal(float x, float y) {
    r = 15; 
    col = color(0, 255, 255); 
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    body = box2d.createBody(bd);
    
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = crystalDensity;
    fd.friction = 0.1;
    fd.restitution = 0.8; 
    
    body.createFixture(fd);
    body.setLinearVelocity(new Vec2(random(-2, 2), 0));
    body.setUserData(this);
  }
  
  /**
   * Renders the crystal as a geometric 5-pointed star.
   */
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(col);
    stroke(255);
    strokeWeight(2);
    
    float angle = TWO_PI / 5;
    float halfAngle = angle / 2.0;
    beginShape();
    for (float i = 0; i < TWO_PI; i += angle) {
      float sx = cos(i) * r;
      float sy = sin(i) * r;
      vertex(sx, sy);
      sx = cos(i + halfAngle) * (r * 0.4);
      sy = sin(i + halfAngle) * (r * 0.4);
      vertex(sx, sy);
    }
    endShape(CLOSE);
    
    popMatrix();
  }
}
