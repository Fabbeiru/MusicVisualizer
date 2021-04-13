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

float songPosition;
boolean example;

PImage bg;
PFont font;

void setup () {
  size(1200, 800, P3D);
  bg = loadImage("background.jpg");
  font = loadFont("Consolas-Italic-48.vlw");
  textFont(font);
  circle = new Circle();
  songPosition = 0.0;
  example = true;
}

void draw () {
  background(bg);
  translate(width/2, height/2);
  minim = new Minim(this);
  showHelp();
  if (example) exampleSong();
  if (song != null && song.isPlaying()) {
    fft.forward(song.mix);
    beat.detect(song.mix);
    circle.show();
    showTimeLine();
  }
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
  textAlign(CENTER);
}

void keyPressed() {
  if (keyCode == ENTER) {
    song.pause();
    selectInput("Select a song", "selectSong");
  }
}
