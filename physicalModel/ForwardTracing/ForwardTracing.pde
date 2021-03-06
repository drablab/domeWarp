//initialize
float R = 150.0; //dome radius
float r = 33.0;  // spherical mirror radius

float dx = 0.0;// dome coordinate
float dy = 0.0;
float dz = R;

float mx = 0.0; // mirror coordinate
float my = -18*cos( 70*PI/180 - atan(8.3/13.8) );
float mz = -18*sin( 70*PI/180 - atan(8.3/13.8) );

float px = 0.0; // projector coordinate
float py = -20.0; 
float pz = 75.0;

// projection center
float cx = 0.0; // a coordinate that the projector light ray shoots on
float cy = 0.0;
float cz = 0.0;

Sphere dome, mirror, p, c; 
Plane projPlane;
PVector mirVect;
PVector projector;
PVector projCenter;
PVector projectingVect;

float projectorThrow = 2.2;
float aspect = 4.0/3.0;
float projectionDepth;

PVector imgCenter;
PImage img, imgWarped;
int ix = 499;
int iy = 499;
PVector x0, x1,x2,x3,x4,x5, distorted; 

float leftRight ;
float upDown ;
float zoom = 6;

int maxX = -1;
int maxY = -1;
int minX = 10000;
int minY = 10000;
int[] mapX ;
int[] mapY ;

PVector onDome, onMirror;
void setup() {
  img = loadImage("CircularMesh.jpg");
  img.loadPixels();
  dome = new Sphere(dx, dy, dz, R);
  mirror = new Sphere(mx, my, mz, r);
  mirVect = new PVector(mx,my,mz);
  imgWarped = createImage(img.width,img.height,RGB);
  imgWarped.loadPixels();
  
  projCenter = new PVector(cx, cy, cz);
  projector = new PVector(px, py, pz);
  projectingVect = PVector.sub(projCenter, projector);
  projectionDepth = img.width * projectorThrow;
  
  mapX = new int[img.width*img.height];
  mapY = new int[img.width*img.height];
  
  imgCenter = correctToDistorted(249,249);
  float scale = 0.7;
  for (int i = 0; i < img.width; i++) for(int j = 0; j < img.height; j++){
    onMirror = imagePlaneToMirror(pixelToImagePlane(i,j));
    if(onMirror.z < mirVect.z) println("mirror method failed");
    onDome = mirrorToDome(onMirror);
    if(onDome.y > 0) {
      distorted = circleToPixel(domeToCircle(onDome));
      
      distorted.sub(imgCenter);
      distorted.mult(scale);
    
      mapX[j*img.width+i] = i;
      mapY[j*img.width+i] = j;
    
    int disx = int(distorted.x + img.width/2);
    int disy = int(distorted.z + img.height/2);
    
    if(disy >= 0 && disy < img.height && disx >= 0 && disx < img.width) imgWarped.pixels[j*img.width+i] = img.pixels[disy*img.width+disx]; 

    //if(disy*img.width+disx < img.width*img.height &&disy*img.width+disx>=0) imgWarped.pixels[j*img.width+i] = img.pixels[disy*img.width+disx]; 
    else println("outside at " + disx + "," + disy);
    }
  } 
  
  imgWarped.updatePixels();
  imgWarped.save("outputImage.jpg");
  size(640, 640, P3D);
}

void draw() {
  pushMatrix(); background(0); strokeWeight(1);
  camera(R*zoom, dy, R, 0.0, 0.0, R, 0, -1, 0);
  perspective(PI/2.0, 1.0, -1.0, 150.0);// face the mirror
  translate(0,0,150);
  rotateY(PI/180*leftRight);
  rotateZ(PI/180*upDown);
  rotateX(PI/6);
  if (keyPressed && key == 's') upDown++;
  if (keyPressed && key == 'w') upDown--;
  if (keyPressed && key == 'a') leftRight++;
  if (keyPressed && key == 'd') leftRight--;
  if (keyPressed && key == 'z') upDown=0;
  if (keyPressed && key == 'y') leftRight=90;
  if (keyPressed && key == '=') zoom -=0.1;
  if (keyPressed && key == '-') zoom +=0.1;
  translate(0,0,-150);
  mirror.display();
  dome.display();
   
  //  image projection plane
  textureMode(IMAGE);
  translate(px,py,pz);
  PVector nZ = new PVector(0,0,-1);
  rotateX(+(PVector.angleBetween(nZ,projectingVect)));
  
  beginShape();
  texture(img);
  vertex( img.width/2, img.height/2, -projectionDepth,0,0 );
  vertex( -img.width/2, img.height/2, -projectionDepth,500,0);
  vertex( -img.width/2,  -img.height/2, -projectionDepth,500,500);
  vertex( img.width/2,  -img.height/2, -projectionDepth,0,500);
  endShape(CLOSE);
  // projection Center Cross
  stroke(0, 0, 255);
  strokeWeight(4);
  line(img.width/2, 0.0, -projectionDepth, -img.width/2, 0.0, -projectionDepth);
  line(0.0, img.height/2,   -projectionDepth,0.0 , -img.height/2,  -projectionDepth);
  
  // projection Vector
  stroke(0, 255, 0);
  strokeWeight(4);
  line(0, 0, 0, 0,0, -projectionDepth);
  
  line(0.0, 0.0, 0.0, -img.width/2, img.height/2, -projectionDepth);
  line(0.0, 0.0, 0.0, -img.width/2, -img.height/2,  -projectionDepth);
  line(img.width/2, img.height/2, -projectionDepth,0.0, 0.0,0.0);
  line(img.width/2, -img.height/2,   -projectionDepth,0.0 , 0.0,  0.0);
  
  rotateX( -(PVector.angleBetween(nZ,projectingVect)));
  translate(-px,-py,-pz);
  
  // upside line
  line(0, 0, R, 0, R, R);
  
  beginShape();
  stroke(0,255,255);
  imgWarped.updatePixels();
  texture(imgWarped);
  fill(255,200);
  vertex(-img.width/2, 0, -img.height/2, 0, 0);
  vertex( -img.width/2, 0, img.height/2,500,0);
  vertex( img.width/2,  0, img.height/2,500,500);
  vertex(img.width/2, 0 , -img.height/2 ,0, 500);
  endShape(CLOSE);
 
 
 
  int[] bounds = { img.width/4, img.width/4, img.width/4*3, img.width/4, img.width/4,  img.width/4*3,  img.width/4*3,  img.width/4*3};
  for (int i = 0 ; i < bounds.length-1; i = i+2 ){
    
    x1 = pixelToImagePlane(bounds[i],bounds[i+1]);
    
    //stroke(255, 0, 0);
    //strokeWeight(3);
    //line(px, py, pz, x1.x, x1.y, x1.z); //  projector to Imageplane
    //strokeWeight(5);
    //point(x1.x, x1.y, x1.z);
    
    x2 = imagePlaneToMirror(x1);
    strokeWeight(15);
    point(x2.x, x2.y, x2.z); // imagePlaneToMirror
  
    x3 = mirrorToDome(x2);
    stroke(255, 0, 0);
    strokeWeight(3);  
    line(x2.x, x2.y, x2.z, x3.x, x3.y, x3.z);
    strokeWeight(13);
    point(x3.x, x3.y, x3.z);
  
    x4 = domeToCircle(x3);
    stroke(255, 0, 255);
    strokeWeight(3);
    line(x4.x, x4.y, x4.z, x3.x, x3.y, x3.z);
    strokeWeight(13);
    point(x4.x, x4.y, x4.z); // Mirror To Dome
  
  x5 = circleToPixel(x4);
    
  //stroke(255, 255, 0);
  //strokeWeight(13);
  //point(x5.x, 0, x5.y);
  }

  
  //noLoop();
  popMatrix();
}

PVector pixelToImagePlane(int i, int j){
  // map to Image on centered on x - axis
  PVector u = new PVector(img.width/2-i, img.height/2-j, -projectionDepth);
  //tilt to projection plane into projection direction
  PVector negZ = new PVector(0,0,-1);
  float theta = -(PVector.angleBetween(negZ,projectingVect));
  u.z = u.z*cos(theta) - u.y*sin(theta);
  u.y = u.z*sin(theta) + u.y*cos(theta);
  u.add(projector);
  return u;
}

PVector imagePlaneToMirror(PVector u){
  PVector i = PVector.sub(u,projector);
  float a = sq(i.x) + sq(i.y) + sq(i.z);
  float b = 2*PVector.dot(i,projector) - 2*PVector.dot(mirVect,i);
  float c = sq(projector.mag()) + sq(mirVect.mag()) - 2*PVector.dot(projector,mirVect) - sq(r); 
  float d = (-1*b - sqrt(sq(b)- 4*a*c))/(2*a);
  PVector v = PVector.add(projector, i.mult(d));
  return v;
}

PVector mirrorToDome(PVector u){
  u.sub(mirVect); 
  projector.sub(mirVect);
  
  float theta = PVector.angleBetween(u,projector);
  if (theta < 0) print("negative angle");
  PVector n = u.copy();
  n.setMag(2*projector.mag()*cos(theta));
  PVector k = PVector.sub(n,projector);
  PVector f = PVector.sub(k,u);
  float a = PVector.dot(f,f);
  float b = 2*PVector.dot(u,f) - 2*R*f.z;
  float c = PVector.dot(u,u) - 2*R*u.z;
  float d = (-1*b+sqrt(sq(b)-4*a*c))/(2*a);
  PVector v = PVector.add(u,f.mult(d)).add(mirVect);
  u.add(mirVect); 
  projector.add(mirVect);
  return v;
}

PVector domeToCircle(PVector u){
  // shift to origin
  PVector v = u.copy();
  v.z = v.z - R;
  PVector posY = new PVector(0,1,0);
  float phi = PVector.angleBetween(v, posY);
  v.y = 0;
  v.setMag(2*R*phi/PI);
  v.z = v.z + R;
  return v;
}

PVector circleToPixel(PVector u){
  // shift to origin
  PVector v = u.copy();
  v.z = v.z - R;
  // rotate about y-axis
  PVector l = v.copy();
  // x y coords are now becoming pixel i, v 
  v.x = l.x*cos(-PI/2) - l.z*sin(-PI/2);
  v.z = l.x*sin(-PI/2) + l.z*cos(-PI/2);
  //v.y = v.x;
  //v.x = v.z;
  //v.z = 0; 
  v.mult(img.height/(2*R));
  return v;
}

PVector correctToDistorted(int i, int j){
  return circleToPixel(domeToCircle(mirrorToDome(imagePlaneToMirror(pixelToImagePlane(i,j)))));
}
