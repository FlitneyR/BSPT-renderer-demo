class Wall {
  PVector start, end, normal;
  float high, low;
  color col;
  
  Wall(float x1, float y1, float x2, float y2, float h, float l, color c) {
    start = new PVector(x1, y1);
    end = new PVector(x2, y2);
    normal = cross(sub(end, start), new PVector(0, 0, 1));
    normal.normalize();
    
    high = h;
    low = l;
    
    col = c;
  }
  
  Wall[] split(Wall w){
    Wall[] out = new Wall[2];
    
    float s = dot(normal, sub(w.start, start));
    float e = dot(normal, sub(  w.end,   end));
    
    if(s * e < 0){
      PVector i = add(w.start, scale(sub(w.end, w.start), abs(s) / (abs(s) + abs(e))));
      
      Wall wallStart = new Wall(w.start.x, w.start.y, i.x, i.y, w.high, w.low, randCol());
      Wall wallEnd = new Wall(w.end.x, w.end.y, i.x, i.y, w.high, w.low, randCol());
      
      if(s > 0){
        out[0] = wallStart;
        out[1] = wallEnd;
      } else {
        out[0] = wallEnd;
        out[1] = wallStart;
      }
    } else {
      if(s >= 0){
        out[0] = w;
      } else {
        out[1] = w;
      }
    }
    
    return out;
  }
  
  boolean isInFront(PVector v){
    return dot(normal, sub(v, start)) < 0;
  }
}

class BSPTree {
  BSPNode root;
  
  BSPTree(Wall[] walls){
    root = new BSPNode(walls);
  }
  
  Wall[] getDrawOrder(PVector v){
    return root.getDrawOrder(v);
  }
  
  void show(float x, float y, float scale, float spacing, float ratio){
    root.show(x, y, scale, spacing, ratio);
  }
}

class BSPNode {
  Wall w;
  BSPNode f, b;
  Wall[] frontA;
  Wall[] backA;
  
  BSPNode(Wall[] walls){
    w = walls[0];
    
    ArrayList<Wall> frontAL = new ArrayList<Wall>();
    ArrayList<Wall> backAL = new ArrayList<Wall>();
    
    for(int i = 1; i < walls.length; i++){
      Wall o = walls[i];
      
      Wall[] wallOrder = w.split(o);
      
      Wall front = wallOrder[0];
      Wall behind = wallOrder[1];
      
      if(front != null){
        frontAL.add(front);
      }
      
      if(behind != null){
        backAL.add(behind);
      }
    }
    
    frontA = frontAL.toArray(new Wall[frontAL.size()]);
    backA  =  backAL.toArray(new Wall[ backAL.size()]);
    
    if(frontA.length > 0){
      f = new BSPNode(frontA);
    }
    
    if(backA.length > 0){
      b = new BSPNode(backA);
    }
  }
  
  Wall[] getDrawOrder(PVector v){
    boolean frontFacing = w.isInFront(v);
    
    Wall[] out = new Wall[]{};
    
    if(frontFacing){
      if(b != null){
        out = (Wall[])concat(b.getDrawOrder(v), out);
      }
      
      out = (Wall[])concat(new Wall[]{w}, out);
      
      if(f != null){
        out = (Wall[])concat(f.getDrawOrder(v), out);
      }
    } else {
      if(f != null){
        out = (Wall[])concat(f.getDrawOrder(v), out);
      }
      
      out = (Wall[])concat(new Wall[]{w}, out);
      
      if(b != null){
        out = (Wall[])concat(b.getDrawOrder(v), out);
      } 
    }
    
    return out;
  }
  
  void show(float x, float y, float scale, float spacing, float ratio){
    stroke(255);
    
    if(f != null){
      float nx = x - spacing;
      float ny = y + spacing;
      line(x, y, nx, ny);
      f.show(nx, ny, scale * ratio, spacing * ratio, ratio);
    }
    
    if(b != null){
      float nx = x + spacing;
      float ny = y + spacing;
      line(x, y, nx, ny);
      b.show(nx, ny, scale * ratio, spacing * ratio, ratio);
    }
    
    fill(w.col);
    ellipse(x, y, scale, scale);
  }
}

class Camera {
  PVector pos, forward, right, up;
  
  float camTop, camRight;
  
  Camera(PVector p, float fov){
    pos = p;
    up = new PVector(0, 0, 1);
    forward = new PVector(0, 1);
    right = new PVector(1, 0);
    
    if(height < width){
      camRight = tan(radians(fov));
      camTop = camRight / width * height;
    } else {
      camTop = tan(radians(fov));
      camRight = camTop / height * width;
    }
  }
  
  void rotate(float theta){
    forward.rotate(-theta);
    right.rotate(-theta);
  }
  
  void draw(Wall w){
    PVector relStart = sub(w.start, pos);
    PVector relEnd = sub(w.end, pos);
    
    float startDist = dot(relStart, forward);
    float endDist = dot(relEnd, forward);
    
    if(startDist > 0 || endDist > 0){
      
      float startRight = dot(relStart, right);
      float endRight = dot(relEnd, right);
      
      if(startDist <= 0){
        startRight = endRight + (startRight - endRight) * endDist / (endDist - startDist);
        startDist = 0.000001;
      } else if(endDist <= 0){
        endRight = startRight + (endRight - startRight) * startDist / (startDist - endDist);
        endDist = 0.000001;
      }
      
      float startCamRight = startRight / startDist;
      float endCamRight = endRight / endDist;
      
      float startCamHigh = w.high / startDist;
      float startCamLow = w.low / startDist;
      
      float endCamHigh = w.high / endDist;
      float endCamLow = w.low / endDist;
      
      fill(w.col);
      noStroke();
      
      beginShape();
      
      vertex(map(startCamRight, camRight, -camRight, 0, width),
             map(startCamHigh, -camTop, camTop, 0, height));
      
      vertex(map(endCamRight, camRight, -camRight, 0, width),
             map(endCamHigh, -camTop, camTop, 0, height));
      
      vertex(map(endCamRight, camRight, -camRight, 0, width),
             map(endCamLow, -camTop, camTop, 0, height));
      
      vertex(map(startCamRight, camRight, -camRight, 0, width),
             map(startCamLow, -camTop, camTop, 0, height));
      
      endShape();
      
    }
  }
}
