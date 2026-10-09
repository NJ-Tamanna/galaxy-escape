class SpaceItem {
  Body body;
  color col;
  float w, h, r; 
  boolean deleteMe = false; 
  
  boolean isOffScreen() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    return (pos.y > height + 50);
  }
  
  void killBody() {
    box2d.destroyBody(body);
  }
  
  void display() {
  }
}
