Table table;
DropdownWidget dropdown;
BarChartWidget barChart; 
String selectedCarrier = "ALL"; 
float scrollOffset = 0;
float targetScrollOffset = 0;
float scrollVelocity = 0;
float scrollFriction = 0.9; // Controls how quickly scrolling stops
float scrollSensitivity = 15; // Controls how responsive the scrolling feels
int cachedMaxScroll = 0;
boolean needsRecalculation = true; // Flag to know when to recalculate
int SCREENX = 980;
int SCREENY = 980;
boolean showChart = false;
boolean showHome = true;   
boolean showFlights = false; 
boolean showCancelled = true; 
ButtonWidget chartButton;
ButtonWidget backButton;
ButtonWidget startButton; 
ButtonWidget cancelFilterButton;
PImage plane;

void settings() 
{
  size(SCREENX, SCREENY);
  plane = loadImage("plane-photo(1).jpg");
  plane.resize(SCREENX, SCREENY);
}

void setup() 
{
  table = loadTable("flights.csv", "header");
  dropdown = new DropdownWidget(140, 10, 150, 25);
  dropdown.addOption("ALL");

  for (TableRow row : table.rows()) 
  {
    String carrier = row.getString("MKT_CARRIER");
    if (!dropdown.options.contains(carrier)) 
    {
      dropdown.addOption(carrier);
    }
  }

  barChart = new BarChartWidget(100, 100, SCREENX - 200, SCREENY - 300, table);
  chartButton = new ButtonWidget(700, 10, 200, 30, "View Chart");
  backButton = new ButtonWidget(50, 10, 100, 30, "Back");
  startButton = new ButtonWidget(SCREENX/2 - 100, SCREENY/2 + 50, 200, 50, "Start FlyRadar"); 
  cancelFilterButton = new ButtonWidget(450, 10, 200, 30, "Hide Cancelled"); 
}

void draw() 
{
  background(255); 
  
  if (showHome) 
  {
    displayHomepage();
  } 
  else if (showChart) 
  {
    background(240);
    barChart.display();
    backButton.display();
  } 
  else if (showFlights) 
  {
    updateMaxScroll();
    targetScrollOffset += scrollVelocity;
    scrollVelocity *= scrollFriction;
    
    if (abs(scrollVelocity) < 0.1)
    {
      scrollVelocity = 0;
    }
 
    if (targetScrollOffset < 0) {
      targetScrollOffset *= 0.5;
      scrollVelocity = 0;
    }
    else if (targetScrollOffset > cachedMaxScroll) 
    {
      float overshoot = targetScrollOffset - cachedMaxScroll;
      targetScrollOffset = cachedMaxScroll + overshoot * 0.5;
      scrollVelocity = 0; 
    }
    
  
    float scrollDifference = targetScrollOffset - scrollOffset;
    scrollOffset += scrollDifference * 0.5; 
    
   
    if (abs(scrollDifference) < 0.1) {
      scrollOffset = targetScrollOffset;
    }
    
    fill(0);
    textSize(14);
    textAlign(LEFT); 
    text("Select Airline:", 50, 30);
    
    if (!dropdown.expanded) 
    {
      displayFlights();
    }
    
    dropdown.display();
    chartButton.display();
    cancelFilterButton.display(); 
    
    fill(100);
    textSize(12);
    textAlign(RIGHT);
    text("Showing " + (showCancelled ? "all flights" : "only non-cancelled flights"), 
         cancelFilterButton.x - 10, cancelFilterButton.y + 20);
  }
}

void displayHomepage() 
{
  background(25, 25, 112); 
  image(plane, 0, 0);
  
  fill(0, 0, 50, 100);
  rect(0, 0, SCREENX, SCREENY);
  
  fill(255);
  textSize(80);
  textAlign(CENTER, CENTER);
  text("FlyRadar", SCREENX/2, SCREENY/2 - 100);
  
  textSize(24);
  text("Flight Data Visualization Tool", SCREENX/2, SCREENY/2 - 40);
  
  startButton.display();
  
  float pulseValue = 128 + 127 * sin(frameCount * 0.05);
  fill(pulseValue);
  textSize(18);
  text("Click Start to Explore Flight Data", SCREENX/2, SCREENY/2 + 150);
}

void displayFlights() 
{
  text("Filtered Flights:", 50, 80);
  int yOffset = 110 - (int)scrollOffset;
  int maxY = SCREENY - 20; 
  int rowHeight = 25;
  
 
  int startIndex = max(0, (int)(scrollOffset / rowHeight));
  int visibleRows = SCREENY / rowHeight + 2; 
  int processedRows = 0;
  int totalFilteredRows = 0;

  for (int i = 0; i < table.getRowCount(); i++) 
  {
    TableRow row = table.getRow(i);
    String carrier = row.getString("MKT_CARRIER");
    int cancelled = row.getInt("CANCELLED");
    
    // Apply filters
    if (!selectedCarrier.equals("ALL") && !carrier.equals(selectedCarrier)) continue;
    if (!showCancelled && cancelled == 1) continue;
    
    totalFilteredRows++;
    
    // Only process rows that might be visible (optimization)
    if (totalFilteredRows >= startIndex && processedRows < visibleRows) {
      if (yOffset > 90 && yOffset < maxY) { 
        String date = row.getString("FL_DATE");
        int flightNum = row.getInt("MKT_CARRIER_FL_NUM");
        String origin = row.getString("ORIGIN");
        String dest = row.getString("DEST");
        float distance = row.getFloat("DISTANCE");

        String flightInfo = date + " | " + carrier + flightNum + " | " + origin + " → " + dest + " | " + distance + " miles";
        
        if (cancelled == 1) {
          fill(255, 0, 0); 
          flightInfo += " [CANCELLED]";
        } else {
          fill(0); 
        }

        text(flightInfo, 50, yOffset);
       
      }
      processedRows++;
    }
    
    yOffset += rowHeight;
  }
  
  fill(100);
  textSize(12);
  text("Use mouse wheel to scroll", SCREENX - 200, SCREENY - 20);
}

void mousePressed() 
{
  if (showHome) 
  {
    if (startButton.isClicked(mouseX, mouseY)) 
    {
      showHome = false;
      showFlights = true;
    }
  } else if (showChart) 
  {
    if (backButton.isClicked(mouseX, mouseY)) 
    {
      showChart = false;
      showFlights = true;
    }
  } else if (showFlights) 
  {
    dropdown.checkClick(mouseX, mouseY);
    if (chartButton.isClicked(mouseX, mouseY)) 
    {
      showChart = true;
      showFlights = false;
    }
    
    if (cancelFilterButton.isClicked(mouseX, mouseY)) 
    {
      showCancelled = !showCancelled;
      cancelFilterButton.label = showCancelled ? "Hide Cancelled" : "Show All Flights";
      scrollOffset = 0;
      targetScrollOffset = 0;
      scrollVelocity = 0; // Reset velocity when changing filters
      needsRecalculation = true; // Mark for recalculation
    }
  }
}

void mouseWheel(MouseEvent event) 
{
  if (showFlights && !dropdown.expanded)
  {
    float e = event.getCount();
  
    scrollVelocity += e * scrollSensitivity;
    scrollVelocity = constrain(scrollVelocity, -100, 100);
  }
}

void updateMaxScroll()
{
  if (!needsRecalculation) return;
  
  int dataRowCount = 0;
  for (int i = 0; i < table.getRowCount(); i++) 
  {
    TableRow row = table.getRow(i);
    String carrier = row.getString("MKT_CARRIER");
    int cancelled = row.getInt("CANCELLED");
    
    if ((selectedCarrier.equals("ALL") || carrier.equals(selectedCarrier)) &&
        (showCancelled || cancelled == 0)) 
    {
      dataRowCount++;
    }
  }
  
  cachedMaxScroll = dataRowCount * 25 - (SCREENY - 130);
  if (cachedMaxScroll < 0) cachedMaxScroll = 0;
  
  needsRecalculation = false;
}

// Custom color blending function for button hover effect
color lerpColor(color c1, color c2, float amt) {
  float r1 = red(c1);
  float g1 = green(c1);
  float b1 = blue(c1);
  float r2 = red(c2);
  float g2 = green(c2);
  float b2 = blue(c2);
  
  return color(
    r1 + (r2 - r1) * amt,
    g1 + (g2 - g1) * amt,
    b1 + (b2 - b1) * amt
  );
}

class BarChartWidget 
{
  int x, y, w, h;
  HashMap<String, Integer> flightCounts;
  HashMap<String, Integer> cancelledCounts;
  int maxFlights;

  BarChartWidget(int x, int y, int w, int h, Table table) 
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.flightCounts = new HashMap<>();
    this.cancelledCounts = new HashMap<>();

    for (TableRow row : table.rows()) 
    {
      String carrier = row.getString("MKT_CARRIER");
      int cancelled = row.getInt("CANCELLED");
      
      flightCounts.put(carrier, flightCounts.getOrDefault(carrier, 0) + 1);
      
      if (cancelled == 1) {
        cancelledCounts.put(carrier, cancelledCounts.getOrDefault(carrier, 0) + 1);
      }
    }

    maxFlights = 0;
    for (int count : flightCounts.values()) 
    {
      if (count > maxFlights) 
      {
        maxFlights = count;
      }
    }
  }

  void display() 
  {
    fill(240);
    rect(0, 0, SCREENX, SCREENY); 
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text("Flights by Airline", SCREENX / 2, 60);

    int barWidth = (w - 100) / flightCounts.size(); 
    int index = 0;
    int startX = x + 50; 

    for (String carrier : flightCounts.keySet()) 
    {
      int flights = flightCounts.get(carrier);
      int cancelled = cancelledCounts.getOrDefault(carrier, 0);
      int barHeight = int(map(flights, 0, maxFlights, 0, h - 100));
      int cancelledHeight = int(map(cancelled, 0, maxFlights, 0, h - 100));

      fill(100, 100, 255);
      rect(startX + index * barWidth, y + h - barHeight, barWidth - 5, barHeight);

      fill(255, 100, 100);
      rect(startX + index * barWidth, y + h - barHeight, barWidth - 5, cancelledHeight);

      fill(0);
      textSize(12);
      textAlign(CENTER);
      text(carrier, startX + index * barWidth + barWidth / 2, y + h + 20);
      text(flights, startX + index * barWidth + barWidth / 2, y + h - barHeight - 5);
      
      if (cancelled > 0) {
        fill(255, 0, 0);
        text("(" + cancelled + " canc.)", startX + index * barWidth + barWidth / 2, y + h - barHeight - 20);
      }

      index++;
    }
    
   
    fill(0);
    textSize(12);
    textAlign(LEFT);
    text("Legend:", SCREENX - 150, 100);
    
    fill(100, 100, 255);
    rect(SCREENX - 150, 110, 15, 15);
    fill(0);
    text("All Flights", SCREENX - 130, 123);
    
    fill(255, 100, 100);
    rect(SCREENX - 150, 135, 15, 15);
    fill(0);
    text("Cancelled", SCREENX - 130, 148);
  }
}

class DropdownWidget 
{
  int x, y, w, h;
  ArrayList<String> options;
  boolean expanded = false;
  String selected;

  DropdownWidget(int x, int y, int w, int h) 
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.options = new ArrayList<String>();
    this.selected = "";
  }

  void addOption(String option) 
  {
    options.add(option);
    if (selected.equals("")) selected = option;
  }

  void display() 
  {
    fill(220);
    rect(x, y, w, h, 5);
    fill(0);
    text(selected, x + 10, y + h - 5);

    if (expanded) 
    {
      fill(255, 255, 255, 230);
      int maxDropdownHeight = min(options.size() * h, SCREENY - y - h);
      rect(x, y + h, w, maxDropdownHeight, 5);

      for (int i = 0; i < options.size(); i++) 
      {
        fill(240);
        rect(x, y + (i + 1) * h, w, h, 5);
        fill(0);
        text(options.get(i), x + 10, y + (i + 2) * h - 5);
      }
    }
  }

  void checkClick(int mx, int my) 
  {
    if (mx > x && mx < x + w && my > y && my < y + h) 
    {
      expanded = !expanded;
    } else if (expanded) 
    {
      for (int i = 0; i < options.size(); i++) 
      {
        if (mx > x && mx < x + w && my > y + (i + 1) * h && my < y + (i + 2) * h) 
        {
          selected = options.get(i);
          expanded = false;
          selectedCarrier = selected;
          // Reset scroll position when changing filters
          scrollOffset = 0;
          targetScrollOffset = 0;
          scrollVelocity = 0; // Also reset velocity
          needsRecalculation = true; // Mark for recalculation
        }
      }
    }
  }
}

class ButtonWidget 
{
  int x, y, w, h;
  String label;

  ButtonWidget(int x, int y, int w, int h, String label) 
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  void display() 
  {
    if (label.equals("Back")) 
    {
        fill(200, 50, 50); 
    } 
    else if (label.contains("Cancelled") || label.contains("Show All")) 
    {
        fill(50, 100, 200); 
    }
    else {
        fill(50, 150, 50); 
    }
    
    
    if (isHovered()) 
    {
   
      fill(60, 160, 60);
      if (label.equals("Back")) 
      {
        fill(210, 60, 60);
      } else if (label.contains("Cancelled") || label.contains("Show All")) 
      {
        fill(60, 110, 210);
      }
    }
    
    rect(x, y, w, h, 5);
    fill(255);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }
  
  boolean isHovered() 
  {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }

  boolean isClicked(int mx, int my) 
  {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}