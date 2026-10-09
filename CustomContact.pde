class CustomContactListener implements ContactListener {
  
  public void beginContact(Contact cp) {
    Fixture f1 = cp.getFixtureA();
    Fixture f2 = cp.getFixtureB();
    
    Body b1 = f1.getBody();
    Body b2 = f2.getBody();
    Object o1 = b1.getUserData();
    Object o2 = b2.getUserData();
    
    if (o1 == null || o2 == null) return;
    
    if (o1.getClass() == Ship.class && o2 instanceof SpaceItem) {
      handleCollision((SpaceItem) o2);
    } else if (o2.getClass() == Ship.class && o1 instanceof SpaceItem) {
      handleCollision((SpaceItem) o1);
    }
  }

  void handleCollision(SpaceItem item) {
    if (item instanceof EnergyCrystal) {
      item.deleteMe = true; 
      score = min(score + 10, maxScore);
      timeLeft += 2.0; 
      health = min(100.0, health + 1.0); 
    } else if (item instanceof SpaceScrap) {
      item.deleteMe = true; 
      score -= 5;
      health = max(0.0, health - 10.0); 
    } else if (item instanceof Portal) {
      if (health >= 50 && score >= requiredScore) {
        gameState = "VICTORY";
        item.deleteMe = true; 
      } else {
        if (health < 50 && score < requiredScore) portalWarning = "Not enough Health AND Score!";
        else if (health < 50) portalWarning = "Portal Rejected: Not enough Health!";
        else if (score < requiredScore) portalWarning = "Portal Rejected: Not enough Score!";
        
        warningTimer = 120; 
      }
    }
  }

  public void endContact(Contact cp) {}
  public void preSolve(Contact cp, Manifold m) {}
  public void postSolve(Contact cp, ContactImpulse ci) {}
}
