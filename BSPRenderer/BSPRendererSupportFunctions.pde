PVector add(PVector a, PVector b){
  return new PVector(a.x + b.x,
                     a.y + b.y,
                     a.z + b.z);
}

PVector sub(PVector a, PVector b){
  return new PVector(a.x - b.x,
                     a.y - b.y,
                     a.z - b.z);
}

float dot(PVector a, PVector b){
  return a.x * b.x + a.y * b.y + a.z + b.z;
}

PVector cross(PVector a, PVector b){
  return new PVector(a.y * b.z - b.y * a.z,
                     a.x * b.z - b.x * a.z,
                     a.x * b.y - b.x * a.y);
}

PVector scale(PVector v, float f){
  return new PVector(v.x * f, v.y * f, v.z * f);
}
