// Fabián Alfonso Beirutti Pérez
// 2021 - CIU

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import javax.swing.JOptionPane;

Minim minim;
AudioPlayer song;
AudioMetaData data;
BeatDetect beat;
FFT fft;

Circle circle;

boolean example, paused, ended, muted, menu;

PImage bg, image;
PFont font;

void setup () {
  size(1200, 800, P3D);
  bg = loadImage("background.jpg");
  image = loadImage("Captura.JPG");
  font = loadFont("Consolas-Italic-48.vlw");
  textFont(font);
  circle = new Circle();
  example = true;
  ended = false;
  muted = false;
  menu = true;
}

void draw () {
  if (menu) menu();
  else {
    background(bg);
    translate(width/2, height/2);
    minim = new Minim(this);
    showHelp();
    if (example) exampleSong();
    infoStatus();
    if (song != null && song.isPlaying()) {
      fft.forward(song.mix);
      beat.detect(song.mix);
      circle.show();
      showTimeLine();
      ended = false;
      if (song.position() == song.length()) ended = true;
    }
  }
}

void infoStatus() {
  if (paused) {
    textSize(50);
    textAlign(CENTER);
    text("PAUSED", width/2 - 600, height/2 - 400);
    textSize(25);
    text("Press SPACEBAR to continue.", width/2 - 600, height/2 - 350);
  }
  if (ended) {
    textSize(50);
    textAlign(CENTER);
    text("END OF SONG", width/2 - 600, height/2 - 400);
    textSize(25);
    text("Please select another song or press R to reset", width/2 - 600, height/2 - 350);
    text("and then SPACEBAR to start over the current song.", width/2 - 600, height/2 - 300);
  }
  if (muted) {
    textSize(50);
    textAlign(CENTER);
    text("MUTED", width/2 - 600, height/2 - 400);
  }
}

void menu() {
  background(0);
  textSize(50);
  textAlign(CENTER);
  fill(255);
  text("Music Visualizer", width/2, height/2-240);
  textSize(25);
  text("by Fabián B.", width/2, height/2-190);
  image(image, width/2-300, height/2-150, 600, 400);
  text("Press ENTER to continue", width/2, height/2+300);
}

void exampleSong() {
  example = false;
  this.song = minim.loadFile("music/groove.mp3");
  this.data = song.getMetaData();
  this.fft = new FFT(song.bufferSize(),song.sampleRate());
  this.beat = new BeatDetect(song.bufferSize(),song.sampleRate());
  beat.setSensitivity(100);
  song.play();
  circle.show();
}

String TimeToString(int milisecond) {
  String second = nf(milisecond/1000%60,2);
  String minutes = nf(milisecond/1000/60,2);
  return (minutes + ":" + second);
}

void showTimeLine() {
  colorMode(RGB,255,255,255);
  stroke(120);
  strokeWeight(10);
  line(-400, height/2 - 100, width/2 - 200, height/2 - 100);
  float position = map(song.position(), 0, song.length(), width/2 - 1200, width/2 - 400);
  stroke(45, 110, 165);
  line(-400, height/2 - 100, 200 + position, height/2 - 100);
  textSize(18);
  fill(255, 255, 255);
  text(TimeToString(song.length()), width/2 - 170, height/2 - 94.5);
  text(TimeToString(song.position()), width/2 - 1030, height/2 - 94.5);
  strokeWeight(1);
}

void selectSong(File selection) {
  if (selection != null) {
    try {
      this.song = minim.loadFile(selection.getAbsolutePath());
      this.data = song.getMetaData();
      this.fft = new FFT(song.bufferSize(),song.sampleRate());
      this.beat = new BeatDetect(song.bufferSize(),song.sampleRate());
      beat.setSensitivity(100);
      song.play();
      circle.show();
    } catch(Exception e) {
      JOptionPane.showMessageDialog(null, "Error al cargar la canción", "Error", JOptionPane.ERROR_MESSAGE);
      noLoop();
      selectInput("Select a song", "selectSong");
    }
   } else if (song != null){
     song.play();
   }
  loop();
}

void showHelp() {
  textAlign(LEFT);
  textSize(20);
  text("> Press ENTER to select a song.", -580, -350);
  text("> Press P to pause the song.", -580, -300);
  text("> Press M to mute / unmute the song.", -580, -250);
  text("> Press F to fast forward through the song.", -580, -200);
  text("> Press B to rewind through the song.", -580, -150);
  text("> Press R to start over the song.", -580, -100);
  text("> Press ESC to exit.", -580, -50);
  textAlign(CENTER);
}

void keyPressed() {
  if (keyCode == ENTER && menu == false) {
    song.pause();
    selectInput("Select a song", "selectSong");
  }
  if (keyCode == ENTER && menu == true) menu = false;
  if (key == 'F' || key == 'f') song.skip(1000);
  if (key == 'B' || key == 'b') song.skip(-1000);
  if (key == 'R' || key == 'r') song.rewind();
  if (key == 'M' || key == 'm') {
    if (song.isMuted()) {
      song.unmute();
      muted = false;
    }
    else {
      song.mute();
      muted = true;
    }
  }
  if (key == 'P' || key == 'p') {
    song.pause();
    paused = true;
  }
  if (key == ' ' || key == ' ') {
    song.play();
    paused = false;
  }
}
