// Fabián Alfonso Beirutti Pérez
// 2021 - CIU

class Circle {
  
  Circle() {}
  
  void show() {
    colorMode(HSB, 360, 100, 100);
    pushMatrix();
    translate(width/2 -600, height/2 -400, -200);
    int r = 215;
    float r2;
    for (int i = 0; i < 360; ++i) {
      int j = round(map(i, 0, 360, 50, fft.specSize()/3));
      r2 = min(226 + fft.getBand(j)*2, 275);
      float xbar = r * cos(radians(i));
      float xbar2 = r2 * cos(radians(i));
      float ybar = r * sin(radians(i));
      float ybar2 = r2 * sin(radians(i));
      stroke(i, 100, 100);
      line(ybar+10, -xbar-10, ybar2+10, -xbar2-10);
    }
    popMatrix();
  }
}
