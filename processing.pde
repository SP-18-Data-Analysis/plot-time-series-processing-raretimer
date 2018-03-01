// This function is required, this is called once, and used to setup your 
// visualization environment
int mode = 0;
int modeCount = 0;
float dataMin;
float dataMax;
int columnCount = 0;
int[] years;
int yearMin;
int yearMax;
FloatTable data;
float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;
boolean volumeOn;
boolean barGraphOn;
Integrator[] interpolators;
// Small tick line
int volumeIntervalMinor = 1;
// Big tick line
int volumeInterval = 10;
int currentColumn;
int yearInterval = 5;
int rowCount;
// Tab variables for the menus
float[] tabLeft, tabRight; // Add above setup() 
float tabTop, tabBottom;
float tabPad = 10;
void setup() {
    // This is your screen resolution, width, height
    //  upper left starts at 0, bottom right is max width,height
   size(720,405);
   barGraphOn = true;
   volumeOn = false;
  
    // This calls the class FloatTable - java class 
  data = new FloatTable("baseballsalaries.csv");
  rowCount = data.getRowCount();
  // Retrieve number of columns in the dataset
  columnCount = data.getColumnCount();
  dataMin = 0;
  dataMax = data.getTableMax();
  years = int(data.getRowNames());  
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  
    // Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
  
 
  
  // Print out the columns in this dataset 
  int numColumns = data.getColumnCount();
  int numRows = data.getRowCount();
  
  
    rowCount = data.getRowCount();
    interpolators = new Integrator[rowCount];
    for (int row = 0; row < rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = 0.02; // Set lower than the default
    }  
  
  
  
  for ( int i = 0; i < numColumns; i++ ) {
     // print out the first column
     if ( i == 1 ) {
        for (int j = 0; j < numRows; j++ ) {
           float cellValue = data.getFloat( j,i);
//           print("Column " + i + " Row " + j + " " + cellValue + " ");
        }
//        println();
       
       
       
     }
   
    
  }
  
  
}
//Require function that outputs the visualization specified in this function
// for every frame. 
void draw() {
  
  
  // Filling the screen white (FFFF) -- all ones, black (0000)
  background(255);
  drawVisualizationWindow();
  drawGraphLabels();
 
   // These functions contain the labels along with the tick marks
  drawYTickMarks();
  drawXTickMarks();
  if (barGraphOn == true) {
    //  b key
     drawDataBars(currentColumn);
     // drawDataLine(currentColumn);
  }else if (volumeOn == true) {
    // v key
    drawVolumeData(currentColumn);
  }
  drawTitleTabs();
  
  for (int row = 0; row < rowCount; row++) { 
    interpolators[row].update( );
  }
  
}
void drawTitleTabs() { 
  rectMode(CORNERS); 
  noStroke( ); 
  textSize(20); 
  textAlign(LEFT);
  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs.
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15; 
  tabBottom = plotY1;
  for (int col = 0; col < columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    // If the current tab, set its background white; otherwise use pale gray.
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    // If the current tab, use black for the text; otherwise use dark gray.
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    runningX = tabRight[col];
  }
}
void mousePressed() {
  
  // This is modulating from 1 to 3
  //  currentColumn = columnCount % 3;
  //  columnCount += 1;
   if (mouseY > tabTop && mouseY < tabBottom) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]) {
        setColumn(col);
      }
    }
  }
  
  
}
void keyPressed() {
   if (key == 'v') {
     // Show visualization as a volume
     volumeOn = true;
     barGraphOn = false;
   }else if ( key == 'b') {
      // Show bar graph
      barGraphOn = true;
      volumeOn = false;
   }
  
}
void setColumn(int col) {
       if (col != currentColumn) {
         currentColumn = col;
          for (int row = 0; row < rowCount; row++) {
            interpolators[row].target(data.getFloat(row, col));
          }
       }
  
     
     
}
void drawVolumeData(int col) {
  beginShape( );
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
     // float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  // Draw the lower-right and lower-left corners.
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
  
}
void drawDataLine(int col) {
  beginShape( );
  rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2); 
      float y = map(value, dataMin, dataMax, plotY2, plotY1); 
      vertex(x, y);
    }
    
    
  }
  endShape( );
}
float barWidth = 2; // Add to the end of setup()
void drawDataBars(int col) {
  noStroke( );
  rectMode(CORNERS);
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      // float value = data.getFloat(row, col);
      float value = interpolators[row].value;
     // float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2); 
      float y = map(value, dataMin, dataMax, plotY2, plotY1); 
      rect(x-barWidth/2, y, x+barWidth/2, plotY2);
    }
  }
  
}
void drawYTickMarks() {
  fill(0);
  textSize(10);
  stroke(128);
  strokeWeight(1);
  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor) { 
    if (v % volumeIntervalMinor == 0) { // If a tick mark
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v % volumeInterval == 0) { // If a major tick mark
        if (v == dataMin) {
          textAlign(RIGHT); // Align by the bottom
        } else if (v == dataMax) {
          textAlign(RIGHT, TOP); // Align by the top
        } else {
          textAlign(RIGHT, CENTER); // Center vertically
        }
        text(floor(v), plotX1 - 10, y);
        line(plotX1 - 4, y, plotX1, y); // Draw major tick
      } else {
        line(plotX1 - 2, y, plotX1, y); // Draw minor tick
      }
    }
  }  
  
}
void drawXTickMarks() {
  
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);
  // Use thin, gray lines to draw the grid.
  stroke(224);
  strokeWeight(5);
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + 10);
      
      // Long verticle line over each year interval
      line(x, plotY1, x, plotY2);
    }
  } 
  
}
void drawVisualizationWindow() {
    fill(255);
  rectMode(CORNERS);
  // noStroke( );
  rect(plotX1, plotY1, plotX2, plotY2);
  
}
void drawGraphLabels() {
  fill(0);
  textSize(15);
  textAlign(CENTER, CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);  
  text("Dollars\nearned\nper annually", labelX, (plotY1+plotY2)/2);
  
}
