import processing.serial.*;

Serial myPort;
int m = 10; 
int n = 10; 
float[][] values; 
int cellW, cellH; 
int currentX = 0, currentY = 0; 
boolean collecting = true; 
float minValue = Float.MAX_VALUE, maxValue = Float.MIN_VALUE;

void setup() {

  //delay that allows the positioning of the obstacle
  delay(5000); 
  size(1425, 830); 
  values = new float[m][n]; 
  cellW = width / n; 
  cellH = height / m; 

  // Inizializing the comunication
  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);
  
  if (collecting) {
    // read the grid
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        if (i == currentY && j == currentX) {
          fill(255, 255, 255); 
        } else {
          fill(0);
        }
        rect(j * cellW, i * cellH, cellW, cellH);
      }
    }
  } else {
   
    drawImage();
  }
}

void serialEvent(Serial p) {
  String data = p.readStringUntil('\n'); // Read the serial port
  if (data != null) {
    data = trim(data);
    float value = float(data); 

    // Save 
    values[currentY][currentX] = value;
    minValue = min(minValue, value);
    maxValue = max(maxValue, value);

    //Next cell
    if (++currentX >= n) {
      currentX = 0;
      if (++currentY >= m) {
        collecting = false; //End of collection
      }
    }
  }
}

void drawImage() {
  loadPixels();
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
      float normValue = (map(values[i][j], minValue, maxValue, 255,0)); // Normalizing
      color c = color(normValue);
      for (int x = 0; x < cellW; x++) {
        for (int y = 0; y < cellH; y++) {
          pixels[(i * cellH + y) * width + (j * cellW + x)] = c;
        }
      }
    }
  }
  updatePixels();
}
