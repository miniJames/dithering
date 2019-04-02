PImage img;
int thresh = 0;
int thresholds[];
char mode;
ArrayList<float[][]> rules;

ArrayList<float[][]> errorRules;

void settings() {
  img = loadImage("landscape.jpg");  
  size(img.width, img.height);
}

void setup() {
  background(img);
  rules = new ArrayList<float[][]>();
  rules = createRules();
  errorRules = createErrorRules();
}

void draw() {

  if (mode=='d') {
    background(dither(img));
  } else if (mode=='n') {
    background(img);
  } else {
    int tc = floor(map(mouseX, 0, width, 0, 20));
    thresholds = new int[tc+2];
    thresholds[0]=0;
    for (int c=0; c<tc; c++) {
      int ad = (int)(c+1)*256/(tc+1);
      thresholds[c+1]=ad;
    }
    thresholds[thresholds.length-1]=255;
    if (mode=='e') {
      background(errorDif(img));
    } else if (mode=='f') {

      background(errorDif2D(img));
    } else if (mode=='c') {
      background(colErrorDif2D(img));
    }
  }
}
void keyPressed() {
  mode=key;
}


PImage dither(PImage img) {

  PImage rtrn = new PImage(img.width, img.height);
  int counter = 0;
  float rule[][] = getRules();

  for (int row = 0; row<img.height; row++) {
    for (int col = 0; col<img.width; col++) {
      int r = row% rule.length;
      int c = col% rule[0].length;
      int re, g, b;
      if (red(img.pixels[counter]) > rule[r][c]) {
        re=255;//(int)red(img.pixels[counter]);
      } else {
        re = 0;
      }
      if (green(img.pixels[counter]) > rule[r][c]) {
        g=255;//(int)green(img.pixels[counter]);
      } else {
        g = 0;
      }
      if (blue(img.pixels[counter]) > rule[r][c]) {
        b=255;//(int)blue(img.pixels[counter]);
      } else {
        b = 0;
      }
      rtrn.pixels[counter] = color(re, g, b);

      counter++;
    }
  }
  return rtrn;
}

float[][] getRules() {

  int index =(int) map(mouseY, 0, height, 0, rules.size());
  return rules.get(index);
}
float[][] getErrorRules() {

  int index =(int) map(mouseY, 0, height, 0, errorRules.size());
  println(index);
  return errorRules.get(index);
}
PImage errorDif(PImage img) {
  int counter = 0;
  PImage rtrn = new PImage(img.width, img.height);
  for (int row = 0; row<img.height; row++) {
    float error = 0;
    for (int col = 0; col<img.width; col++) {
      float b = brightness(img.pixels[counter]);
      b+=error;
      if (b>thresh) {
        rtrn.pixels[counter]=color(255);
      } else {
        rtrn.pixels[counter]=color(0);
      }
      error = thresh-b;
      counter++;
    }
  }
  return rtrn;
}
PImage errorDif2D(PImage img) {
  PImage rtrn = new PImage(img.width, img.height);
  int counter=0;
  float rule[][]=getErrorRules();
  for (int row = 0; row<img.height; row++) {
    float error = 0;
    for (int col = 0; col<img.width; col++) {
      float b = brightness(img.pixels[counter])+brightness(rtrn.pixels[counter]);
      int maxThresh=0;
      //loop through thresholds, set color accordingly.
      for (int i=0; i<thresholds.length; i++) {
        if (b>=thresholds[i]) {
          maxThresh = i;
        }
      }
      rtrn.pixels[counter] = color((thresholds[maxThresh]));
      error = (b-thresholds[maxThresh]);
      //apply error based on rules.
      //for (int c = 0; c<errorRules.size(); c++) {
      
      
      for (int r = 0; r<rule.length; r++) {


        float currentRule[] = rule[r]; 

        //calculate target x and y.
        int target = 0; 
        target = floor(counter + currentRule[0] + (img.width * currentRule[1]));
        if (target<rtrn.pixels.length) {
          rtrn.pixels[target] = color(brightness(img.pixels[target] + (int)(currentRule[2] * error)));
        }
      }
      //}


      //if (counter+1<img.pixels.length) {
      //  rtrn.pixels[counter+1] =color( brightness(img.pixels[counter+1] + (int)(error)));
      //  if (counter+img.width+1<img.pixels.length) {
      //    rtrn.pixels[counter+img.width+1] = color( brightness(img.pixels[counter+img.width+1] + (int)(error)));
      //  }
      //}

      counter++;
    }
  }
  return rtrn;
}
PImage colErrorDif2D(PImage img) {
  PImage rtrn = new PImage(img.width, img.height); 
  int counter=0; 
  int cr= floor(map(mouseY, 0, img.height, 0, errorRules.size()));
  float rule[][] = errorRules.get(cr);
  
  for (int row = 0; row<img.height; row++) {
    float rerror = 0; 
    float gerror = 0; 
    float berror = 0; 
    for (int col = 0; col<img.width; col++) {
      float r = red(img.pixels[counter])+red(rtrn.pixels[counter]); 
      float g = green(img.pixels[counter])+green(rtrn.pixels[counter]); 
      float b = blue(img.pixels[counter])+blue(rtrn.pixels[counter]); 

      int maxThreshR=0; 
      //loop through thresholds, set color accordingly.
      for (int i=0; i<thresholds.length; i++) {
        if (r>=thresholds[i]) {
          maxThreshR = i;
        }
      }
      int maxThreshG=0; 
      //loop through thresholds, set color accordingly.
      for (int i=0; i<thresholds.length; i++) {
        //println(thresholds[i]);
        if (g>=thresholds[i]) {
          maxThreshG = i;
        }
      }
      int maxThreshB=0; 
      //loop through thresholds, set color accordingly.
      for (int i=0; i<thresholds.length; i++) {
        //println(thresholds[i]);
        if (b>=thresholds[i]) {
          maxThreshB = i;
        }
      }
      rtrn.pixels[counter] = color(thresholds[maxThreshR], thresholds[maxThreshG], thresholds[maxThreshB]); 

      //color c; 

      //apply error to the next pixel and the pixel below.
      if (counter+1<img.pixels.length) {


        //println(cr);
        for (int ru = 0; ru<rule.length; ru++) {


          float currentRule[] = rule[ru]; 
      rerror = (maxThreshR-r)* currentRule[2]; 
      gerror = (maxThreshG-g)* currentRule[2]; 
      berror = (maxThreshB-b)* currentRule[2]; 
          //calculate target x and y.
          int target = 0; 
          target = floor(counter + currentRule[0] + (img.width * currentRule[1])+1);

          if (target<rtrn.pixels.length) {
            color c=color(img.pixels[target]); 
            float rn = red(c) + rerror; 
            float gn = green(c) + gerror; 
            float bn = blue(c) + berror; 
            c=color(img.pixels[target]); 
            rn = red(c) + rerror; 
            gn = green(c) + gerror; 
            bn = blue(c) + berror; 
            rtrn.pixels[target] =color(rn, gn, bn);
            //rtrn.pixels[target] = color(brightness(img.pixels[target] + (int)(error)));
          }
        }
        //c=color(img.pixels[counter+1]); 
        //float rn = red(c) + rerror; 
        //float gn = green(c) + gerror; 
        //float bn = blue(c) + berror; 
        //rtrn.pixels[counter+1] =color(rn, gn, bn); 
        //if (counter+img.width+1<img.pixels.length) {
        //  c=color(img.pixels[counter+img.width+1]); 
        //  rn = red(c) + rerror; 
        //  gn = green(c) + gerror; 
        //  bn = blue(c) + berror; 
        //  rtrn.pixels[counter+img.width+1] =color(rn, gn, bn);
        //}
      }

      counter++;
    }
  }
  return rtrn;
}

ArrayList<float[][]> createRules() {

  ArrayList<float[][]> rtrn = new ArrayList<float[][]>(); 

  float r1[][] = new float[2][2]; 
  r1[0][0]=64; 
  r1[0][1]=128; 
  r1[1][0]=192; 
  r1[1][1]=0; 
  float r2[][] = new float[3][3]; 
  r2[0][0]=0; 
  r2[0][1]=(7.0/9.0)*256; 
  r2[0][2]=(3.0/9.0)*256; 
  r2[1][0]=(6.0/9.0)*256; 
  r2[1][1]=(5.0/9.0)*256; 
  r2[1][2]=(2.0/9.0)*256; 
  r2[2][0]=(4.0/9.0)*256; 
  r2[2][1]=(1.0/9.0)*256; 
  r2[2][2]=(8.0/9.0)*256; 
  float r3[][] = new float[4][4]; 
  r3[0][0]=0; 
  r3[0][1]=(08.0/16.0)*256; 
  r3[0][2]=(02.0/16.0)*256; 
  r3[0][3]=(10.0/16.0)*256; 
  r3[1][0]=(12.0/16.0)*256; 
  r3[1][1]=(04.0/16.0)*256; 
  r3[1][2]=(14.0/16.0)*256; 
  r3[1][3]=(06.0/16.0)*256; 
  r3[2][0]=(03.0/16.0)*256; 
  r3[2][1]=(11.0/16.0)*256; 
  r3[2][2]=(01.0/16.0)*256; 
  r3[2][3]=(09.0/16.0)*256; 
  r3[3][0]=(15.0/16.0)*256; 
  r3[3][1]=(07.0/16.0)*256; 
  r3[3][2]=(13.0/16.0)*256; 
  r3[3][3]=(05.0/16.0)*256; 

  float r4[][] = new float[8][8]; 
  r4[0][0]=0; 
  r4[0][1]=(48.0/64.0)*256; 
  r4[0][2]=(12.0/64.0)*256; 
  r4[0][3]=(60.0/64.0)*256; 
  r4[0][4]=(03.0/64.0)*256; 
  r4[0][5]=(51.0/64.0)*256; 
  r4[0][6]=(15.0/64.0)*256; 
  r4[0][7]=(63.0/64.0)*256; 
  r4[1][0]=(32.0/64.0)*256; 
  r4[1][1]=(16.0/64.0)*256; 
  r4[1][2]=(44.0/64.0)*256; 
  r4[1][3]=(28.0/64.0)*256; 
  r4[1][4]=(35.0/64.0)*256; 
  r4[1][5]=(19.0/64.0)*256; 
  r4[1][6]=(47.0/64.0)*256; 
  r4[1][7]=(31.0/64.0)*256; 
  r4[2][0]=(08.0/64.0)*256; 
  r4[2][1]=(56.0/64.0)*256; 
  r4[2][2]=(04.0/64.0)*256; 
  r4[2][3]=(52.0/64.0)*256; 
  r4[2][4]=(11.0/64.0)*256; 
  r4[2][5]=(59.0/64.0)*256; 
  r4[2][6]=(07.0/64.0)*256; 
  r4[2][7]=(55.0/64.0)*256; 
  r4[3][0]=(40.0/64.0)*256; 
  r4[3][1]=(24.0/64.0)*256; 
  r4[3][2]=(36.0/64.0)*256; 
  r4[3][3]=(20.0/64.0)*256; 
  r4[3][4]=(43.0/64.0)*256; 
  r4[3][5]=(27.0/64.0)*256; 
  r4[3][6]=(39.0/64.0)*256; 
  r4[3][7]=(23.0/64.0)*256; 

  r4[4][0]=(02.0/64.0)*256; 
  r4[4][1]=(50.0/64.0)*256; 
  r4[4][2]=(14.0/64.0)*256; 
  r4[4][3]=(62.0/64.0)*256; 
  r4[4][4]=(01.0/64.0)*256; 
  r4[4][5]=(49.0/64.0)*256; 
  r4[4][6]=(13.0/64.0)*256; 
  r4[4][7]=(61.0/64.0)*256; 
  r4[5][0]=(34.0/64.0)*256; 
  r4[5][1]=(18.0/64.0)*256; 
  r4[5][2]=(46.0/64.0)*256; 
  r4[5][3]=(30.0/64.0)*256; 
  r4[5][4]=(33.0/64.0)*256; 
  r4[5][5]=(17.0/64.0)*256; 
  r4[5][6]=(45.0/64.0)*256; 
  r4[5][7]=(29.0/64.0)*256; 

  r4[6][0]=(10.0/64.0)*256; 
  r4[6][1]=(58.0/64.0)*256; 
  r4[6][2]=(06.0/64.0)*256; 
  r4[6][3]=(54.0/64.0)*256; 
  r4[6][4]=(09.0/64.0)*256; 
  r4[6][5]=(57.0/64.0)*256; 
  r4[6][6]=(05.0/64.0)*256; 
  r4[6][7]=(53.0/64.0)*256; 
  r4[7][0]=(42.0/64.0)*256; 
  r4[7][1]=(26.0/64.0)*256; 
  r4[7][2]=(38.0/64.0)*256; 
  r4[7][3]=(22.0/64.0)*256; 
  r4[7][4]=(41.0/64.0)*256; 
  r4[7][5]=(25.0/64.0)*256; 
  r4[7][6]=(37.0/64.0)*256; 
  r4[7][7]=(21.0/64.0)*256; 

  rtrn.add(r1); 
  rtrn.add(r2); 
  rtrn.add(r3); 
  rtrn.add(r4); 
  return rtrn;
}

ArrayList<float[][]> createErrorRules() {
  ArrayList<float[][]> rtrn = new ArrayList<float[][]>(); 

  float[][] r1 = new float[2][3]; 
  r1[0][0] = 1; 
  r1[0][1] = 0; 
  r1[0][2] = .5; 
  r1[1][0] = 0; 
  r1[1][1] = 1; 
  r1[1][2] = .5; 

  float r2[][] = new float[4][3]; 
  r2[0][0] = 1; 
  r2[0][1] = 0; 
  r2[0][2] = 7.0/16.0; 

  r2[1][0] = 1; 
  r2[1][1] = 1; 
  r2[1][2] = 1.0/16.0; 

  r2[2][0] = 0; 
  r2[2][1] = 1; 
  r2[2][2] = 5.0/16.0; 

  r2[3][0] = -1; 
  r2[3][1] = 1; 
  r2[3][2] = 3.0/16.0; 



  rtrn.add(r1); 
  rtrn.add(r2); 

  return rtrn;
}
