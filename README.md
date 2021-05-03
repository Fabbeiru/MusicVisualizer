# MusicVisualizer by Fabián Alfonso Beirutti Pérez
Music visualizer 2D and 3D model using processing.

## Introducción
El objetivo de esta práctica de la asignatura de 4to, Creación de Interfaces de Usuario (CIU), es empezar a tratar los conceptos y las primitivas del tratamiento de señales de audio (audios, música y/o voz). Para ello, se ha pedido el desarrollo de una aplicación que a partir de una señal de entrada de audio, bien sea indicando y cargando un archivo de audio, o bien utilizando el micrófono del ordenador; el usuario pueda interactuar de alguna manera con el proyecto. Todo ello, usando el lenguaje de programación y el IDE llamado Processing. Este permite desarrollar código en diferentes lenguajes y/o modos, como puede ser processing (basado en Java), p5.js (librería de JavaScript), Python, entre otros.
<p align="center"><img src="/musicVisualizerGif.gif" alt="Music visualizer 2D and 3D model using processing"></img></p>

La música empleada en la demostración del funcionamiento de la aplicación es sencilla y no permite apreciar correctamente el efecto visual. Lo ideal sería emplear una canción con mucho contraste de bajos, para obtener así un resultado como el siguiente:

<p align="center"><img width="50%" src="/Captura.JPG" alt="Music visualizer 2D and 3D model using processing"></img></p>

## Controles
Los controles de la aplicación se mostrarán en todo momento por pantalla para facilitar su uso al usuario:
- **Tecla ENTER:** Permite seleccionar una canción o fichero de música localmente.
- **Tecla P:** Pausa la canción actual.
- **Tecla M:** Activa o desactiva el sonido de la canción actual.
- **Tecla F:** Adelanta 1 segundo en la canción actual.
- **Tecla B:** Retrocede 1 segundo en la canción actual.
- **Tecla R:** Reinicia la canción actual.
- **Tecla ESC:** Cierre de la aplicación.

## Descripción
Aprovechando que el lenguaje de programación que utiliza el IDE Processing por defecto está basado en Java, podemos desarrollar nuestro código utilizando el paradigma de programación de "Programación Orientada a Objetos". Así pues, hemos descrito tres clases de Java:
- **MusicVisualizer:** clase principal.
- **Circle:** clase que representa al objeto de crear el círculo en pantalla que se afectado por parámetros correspondientes a la canción que se esté reproduciendo en el momento.

## Explicación
### Clase MusicVisualizer
Esta es la clase principal de la aplicación, la cual gestiona la información mostrada por pantalla al usuario (interfaz gráfica), esto es, el desarrollo de los métodos *setup()* y *draw()*.
```java
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
```
Como se puede ver, en la función *setup()*, cargamos e inicializamos todas las variables y objetos que vamos utilizar a lo largo del programa. Además, en la función *draw()*, controlamos, según los valores de variables booleanas que se manejan según la interacción del usuario con la aplicación, qué se muestra por pantalla como puede ser, el menú, la información sobre el estado de la canción o la ventana para la selección de un nuevo fichero de audio.

Por otra parte, esta misma clase es la que maneja la interacción entre el usuario y la interfaz mediante la implementación del método *keyPressed()*:
```java
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
```
Para proporcionar al usuario más información relativa al funcionamiento de la aplicación, se ha implementado una barra de progreso que nos indica la duración total de la canción actual y el instante de tiempo que se está reproduciendo en ese momento.
```java
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
```
La primera canción que se reproduce es un ejemplo simple para que el usuario conozca y entienda los controles de la interfaz. Si el usuario quiere probar el efecto visual que tiene lugar al utilizar otro audio, solo tiene que seleccionar y abrir el archivo correspondiente que tenga en su dispositivo. Para ello, se utilizaría la funcionalidad que, como se puede ver a continuación, si existe el fichero de audio se intentará obtener la información relativa a los parámetros de la canción, en caso contrario, nos saltará un mensaje de error y podremos probar la selección nuevamente.
```java
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
```

### Clase Circle
La estructura y funcionamiento de la clase *Circle* es muy sencilla, es un objeto que tiene un único método llamado *show()*, el cual, al ser llamado muestra por pantalla el círculo de colores al que se le van aplicando ciertos efectos (incrementa el tamaño de cada una de las barritas que lo conforma) en función de los parámetros de la canción que se esté reproduciendo en ese momento. Como se puede apreciar, se hace uso de unas operaciones y métodos relacionados con la *Transformada Rápida de Fourier* para lograr el efecto resultante.
```java
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
```

## Descarga y prueba
Para poder probar correctamente el código, descargar los ficheros (el .zip del repositorio) y en la carpeta llamada MusicVisualizer se encuentran los archivos de la aplicación listos para probar y ejecutar. El archivo "README.md" y aquellos fuera de la carpeta del proyecto (MusicVisualizer), son opcionales, si se descargan no deberían influir en el funcionamiento del código ya que, son usados para darle formato a la presentación y explicación del repositorio en la plataforma GitHub.

Adicionalmente, dado que se ha usado una librería adicional en esta práctica, para probarla será necesario:
* Añadir e importar las librerías Minim y Sound en Processing.

## Recursos empleados
Para la realización de este sistema planetario en 3D, se han consultado y/o utilizado los siguientes recursos:
* Guión de prácticas de la asignatura CIU
* <a href="https://processing.org">Página de oficial de Processing y sus referencias y ayudas</a>
* Processing IDE
* Micrófono o archivos de música.

Por otro lado, las librerías empleadas fueron:
* <a href="https://github.com/extrapixel/gif-animation">GifAnimation</a> de Patrick Meister</a>.
* <a href="http://code.compartmental.net/minim/">Minim de Damien Di fede & Anderson Mills</a>.
* <a href="https://processing.org/reference/libraries/sound/">Sound de The Processing Foundation</a>.
