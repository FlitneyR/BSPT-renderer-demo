Wall[] walls;
BSPTree t;
Camera c;

boolean turnRight, turnLeft, goForward, goBack, goRight, goLeft;

float turnSpeed = 0.04;
float moveSpeed = 0.2;

void setup(){
  size(1280, 720);
  
  walls = new Wall[]{
    //new Wall(-5, 4,  5,  8, -1, -3, randCol()),
    new Wall(-5, 7,  5,  7, -1, -3, randCol()),
    new Wall(-5, 4, -5,  8, -1, -3, randCol()),
    new Wall(-5, 5,  5,  5, -1, -3, randCol()),
    new Wall(-2, 4, -2,  8, -1, -3, randCol()),
    new Wall( 2, 4,  2,  8, -1, -3, randCol()),
    new Wall(-5, 6,  5,  6, -1, -3, randCol()),
    new Wall( 5, 4,  5,  8, -1, -3, randCol()),
  };
  
  t = new BSPTree(walls);
  
  c = new Camera(new PVector(0, 0), 110);
}

void draw(){
  background(0);
  
  Wall[] drawOrder = t.getDrawOrder(c.pos);
  
  int wallDraws = (int)(1 + (frameCount / 30) % drawOrder.length); 
  
  for(int i = 0; i < wallDraws; i++){
    Wall w = drawOrder[i];
  //for(Wall w : drawOrder){
    c.draw(w);
  }
  
  enactInput();
  
  t.show(width / 2, 30, 50, 50, 0.6);
  
  float x = 20;
  float y = 20;
  float scale = 20;
  
  stroke(255);
  
  for(int i = 0; i < wallDraws; i++){
    Wall w = drawOrder[i];
  //for(Wall w : drawOrder){
    fill(w.col);
    ellipse(x, y, scale, scale);
    y += scale * 2;
    if(y >= height - scale){
      y = 20;
      x += scale * 2;
    }
  }
  
  fill(255);
  noStroke();
  rect(width - 40, 0, 40, 20);
  //stroke(0);
  //noFill();
  fill(0);
  text(frameRate, width - 38, 18);
}

void keyPressed(){
  logInput(true);
}

void keyReleased(){
  logInput(false);
}

void logInput(boolean state){
  if(keyCode == RIGHT){
    turnRight = state;
  } else if(keyCode == LEFT){
    turnLeft = state;
  } else if(key == 'w'){
    goForward = state;
  } else if(key == 's'){
    goBack = state;
  } else if(key == 'd'){
    goRight = state;
  } else if(key == 'a'){
    goLeft = state;
  }
}

void enactInput(){
  if(turnRight){
    c.rotate(turnSpeed);
  }
  if(turnLeft){
    c.rotate(-turnSpeed);
  }
  if(goForward){
    c.pos.add(scale(c.forward, moveSpeed));
  }
  if(goBack){
    c.pos.sub(scale(c.forward, moveSpeed));
  }
  if(goRight){
    c.pos.add(scale(c.right, moveSpeed));
  }
  if(goLeft){
    c.pos.sub(scale(c.right, moveSpeed));
  }
}

color randCol(){
  return color(random(255), random(255), random(255));
}
