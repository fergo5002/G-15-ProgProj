Table table;
BarChartWidget barChart;
PImage plane;
PImage usaMap;
Screen currentScreen;
HomeScreen homeScreen;
FlightScreen flightScreen;
ChartScreen chartScreen;
mapScreen mapScreen;
boolean showCancelled = true;
int SCREENX = 1200;
int SCREENY = 780;


PFont sitkaFont;


void settings() 
{
  size(SCREENX, SCREENY);
  plane = loadImage("plane-photo(1).jpg");
  plane.resize(SCREENX, SCREENY);
  size(SCREENX, SCREENY);
  usaMap = loadImage("usaMap.png");
  usaMap.resize(SCREENX, SCREENY);
}

void setup() 
{
  
  sitkaFont = loadFont("Consolas.vlw");
  
  table = loadTable("flights.csv", "header");
  barChart = new BarChartWidget(100, 100, SCREENX - 200, SCREENY - 300, table);
  
 
  homeScreen = new HomeScreen();
  flightScreen = new FlightScreen();
  chartScreen = new ChartScreen();
  mapScreen = new mapScreen();
  currentScreen = homeScreen;
}

void draw() 
{
  currentScreen.display();
}

void mousePressed() 
{
  currentScreen.mousePressed();
}

void mouseDragged() 
{
  currentScreen.mouseDragged();
}

void mouseWheel(MouseEvent event) 
{
  currentScreen.mouseWheel(event);
}


abstract class Screen 
{
  void display() {}
  void mousePressed() {}
  void mouseDragged() {}
  void mouseWheel(MouseEvent event) {}
}


class HomeScreen extends Screen
{
  ButtonWidget startButton;
  
  HomeScreen() 
  {
    startButton = new ButtonWidget(SCREENX/2 - 100, SCREENY/2 + 50, 200, 50, "Start FlyRadar");
  }
  
  void display() 
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
  
  void mousePressed() 
  {
    if (startButton.isClicked(mouseX, mouseY)) 
    {
      currentScreen = flightScreen;
    }
  }
}


class FlightScreen extends Screen 
{
  DropdownWidget dropdown;
  DropdownWidget dateDropdown; 
  ButtonWidget chartButton;
  ButtonWidget cancelFilterButton;
  ButtonWidget mapButton;
  ButtonWidget clearStateButton;
  String selectedState = "";
  
  float scrollOffset = 0;
  float targetScrollOffset = 0;
  float scrollVelocity = 0;
  float scrollFriction = 0.5;       
  float scrollSensitivity = 15;     
  
  FlightScreen() 
  {
    dropdown = new DropdownWidget(150, 10, 150, 25); 
    dropdown.addOption("ALL");
    for (TableRow row : table.rows()) 
    {
        String carrier = row.getString("MKT_CARRIER");
        if (!dropdown.options.contains(carrier)) 
        {
            dropdown.addOption(carrier);
        }
    }
    
    dateDropdown = new DropdownWidget(150, 50, 150, 25); 
    dateDropdown.addOption("ALL");
    for (TableRow row : table.rows()) 
    {
        String date = row.getString("FL_DATE").split(" ")[0];
        if (!dateDropdown.options.contains(date)) 
        {
            dateDropdown.addOption(date);
        }
    }
    
    chartButton = new ButtonWidget(970, 10, 200, 30, "View Chart"); 
    cancelFilterButton = new ButtonWidget(750, 10, 200, 30, "Hide Cancelled"); 
    mapButton = new ButtonWidget(970, 50, 200, 30, "View Map");
    clearStateButton = new ButtonWidget(750, 50, 200, 30, "Clear State Filter");
  }
  
  void display() 
  {
    textFont(sitkaFont);
    background(240);
    
    fill(0);
    textSize(15);
    textAlign(LEFT);
    text("Select Airline:", 10, 30); 
    text("Select Date:", 10, 70);   
    
    targetScrollOffset += scrollVelocity;
    scrollVelocity *= scrollFriction;
    if (abs(scrollVelocity) < 0.1) 
    {
      scrollVelocity = 0;
    }
    
    int dataRowCount = 0;
    for (int i = 0; i < table.getRowCount(); i++)
    {
      TableRow row = table.getRow(i);
      String carrier = row.getString("MKT_CARRIER");
      int cancelled = row.getInt("CANCELLED");
      if ((dropdown.selected.equals("ALL") || carrier.equals(dropdown.selected)) &&
          (showCancelled || cancelled == 0)) 
      {
        dataRowCount++;
      }
    }
    
    int maxScroll = dataRowCount * 25 - (SCREENY - 130);
    if (maxScroll < 0) maxScroll = 0;
    
    if (targetScrollOffset < 0) 
    {
      targetScrollOffset *= 0.5;
      scrollVelocity *= 0.5;
    } 
    else if (targetScrollOffset > maxScroll) 
    {
      float overshoot = targetScrollOffset - maxScroll;
      targetScrollOffset = maxScroll + overshoot * 0.5;
      scrollVelocity *= 0.5;
    }
    
    float scrollDifference = targetScrollOffset - scrollOffset;
    scrollOffset += scrollDifference * 0.3;
    if (abs(scrollDifference) < 0.1 && abs(scrollVelocity) < 0.1) 
    {
      scrollOffset = targetScrollOffset;
    }
    
    displayFlights();
    dateDropdown.display();
    dropdown.display();
    clearStateButton.display();
    chartButton.display();
    cancelFilterButton.display();
    mapButton.display();
    
    fill(100);
    textSize(18);
    textAlign(RIGHT);
    text("Showing " + (showCancelled ? "all flights" : "only non-cancelled flights"), 
         cancelFilterButton.x - 10, cancelFilterButton.y + 20);
  }
  
  
  void displayFlights() {
   
    
    // Column headers
    drawColumnHeaders();
    
    // Flight data
    int yOffset = 160 - (int)scrollOffset;
    int maxY = SCREENY - 20;
    int rowHeight = 30; // Increased row height
    int startIndex = max(0, (int)(scrollOffset / rowHeight));
    int visibleRows = (SCREENY - 160) / rowHeight + 2;
    int processedRows = 0;
    int totalFilteredRows = 0;

    // Table-like background
    
        for (int i = 0; i < table.getRowCount(); i++) {
            TableRow row = table.getRow(i);
            if (!passesFilters(row)) continue;

            totalFilteredRows++;

            if (totalFilteredRows >= startIndex && processedRows < visibleRows) {
                if (yOffset > 160 && yOffset < maxY) {
                    // Draw single flight row without background shading
                    drawFlightRow(row, yOffset, rowHeight);
                    processedRows++;
                }
            }
            yOffset += rowHeight;
        }
    drawScrollIndicator(totalFilteredRows, rowHeight);
    drawFooter();
  }

  boolean passesFilters(TableRow row) {
    String carrier = row.getString("MKT_CARRIER");
    int cancelled = row.getInt("CANCELLED");
    String date = row.getString("FL_DATE").split(" ")[0]; 
    String originState = row.getString("ORIGIN_STATE_ABR");

    return (dropdown.selected.equals("ALL") || carrier.equals(dropdown.selected)) &&
           (dateDropdown.selected.equals("ALL") || date.equals(dateDropdown.selected)) &&
           (showCancelled || cancelled == 0) &&
           (selectedState.equals("") || originState.equals(selectedState));
  }

  int getFilteredCount() {
    int count = 0;
    for (int i = 0; i < table.getRowCount(); i++) {
      if (passesFilters(table.getRow(i))) count++;
    }
    return count;
  }
  void drawHeaderArea() {
    // Fixed header that won't scroll
    fill(240);
    rect(0, 0, SCREENX, 160);
    
    // Title and filter info
    fill(50, 50, 100);
    textSize(18);
    textAlign(LEFT);
    text("Filtered Flights (" + getFilteredCount() + ")", 50, 110);
    
    // Draw your dropdowns and buttons here
    dateDropdown.display();
    dropdown.display();
    clearStateButton.display();
    chartButton.display();
    cancelFilterButton.display();
    mapButton.display();
    
    // Filter status text
    fill(100);
    textSize(14);
    textAlign(RIGHT);
    text("Showing " + (showCancelled ? "all flights" : "only non-cancelled flights"), 
         cancelFilterButton.x - 10, cancelFilterButton.y + 20);
}

  void drawColumnHeaders() {
    fill(70, 70, 120);
    rect(50, 130, SCREENX-100, 30, 5);
    fill(255);
    textSize(18);
    textAlign(LEFT, CENTER);
    
    float dateCol = 60;         // Date
    float flightCol = dateCol + 150; // Flight # (wider)
    float routeCol = flightCol + 200; // Route (widest)
    float distanceCol = routeCol + 200; // Distance
    float statusCol = distanceCol + 150; // Status
    text("Date", dateCol, 145);
    text("Flight #", flightCol, 145);
    text("Route", routeCol, 145); 
    text("Distance", distanceCol, 145); 
    text("Status", statusCol, 145); 
  }


void drawScrollIndicator() {
    // Adjust scroll indicator calculations to account for clipped area
    int visibleHeight = SCREENY - 180;
    int totalHeight = getTotalContentHeight();
    
    if (totalHeight <= visibleHeight) return;
    
    float scrollRatio = visibleHeight / (float)totalHeight;
    int scrollbarHeight = max(30, (int)(visibleHeight * scrollRatio));
    int scrollbarY = 160 + (int)(scrollOffset * (visibleHeight - scrollbarHeight) / (totalHeight - visibleHeight));
    
    fill(200, 200, 200, 150);
    rect(SCREENX - 20, 160, 10, visibleHeight);
    
    fill(100, 100, 100, 200);
    rect(SCREENX - 20, scrollbarY, 10, scrollbarHeight, 5);
}

int getTotalContentHeight() {
    int rowCount = 0;
    for (int i = 0; i < table.getRowCount(); i++) {
        if (passesFilters(table.getRow(i))) rowCount++;
    }
    return 30 + (rowCount * 30); // Header + rows
}

  void drawTableBackground(int startY, int rows, int rowHeight) {
    noStroke();
    for (int i = 0; i < rows; i++) {
      if (i % 2 == 0) {
        fill(245);
      } else {
        fill(235);
      }
      rect(50, startY + i*rowHeight, SCREENX-100, rowHeight);
    }
    stroke(0);
  }

  void drawFlightRow(TableRow row, int y, int rowHeight) {
    String date = row.getString("FL_DATE").split(" ")[0];
    String carrier = row.getString("MKT_CARRIER");
    int flightNum = row.getInt("MKT_CARRIER_FL_NUM");
    String origin = row.getString("ORIGIN");
    String dest = row.getString("DEST");
    float distance = row.getFloat("DISTANCE");
    int cancelled = row.getInt("CANCELLED");
    int diverted = row.getInt("DIVERTED");

    fill(0);
    textSize(18);
    textAlign(LEFT, CENTER);
    
    float dateCol = 60;         // Date
    float flightCol = dateCol + 150; // Flight # (wider)
    float routeCol = flightCol + 200; // Route (widest)
    float distanceCol = routeCol + 200; // Distance
    float statusCol = distanceCol + 150; // Status
    
    text(date, dateCol, y + rowHeight/2); ;
    
    // Flight number with airline color coding
    fill(128, 0, 128);
    text(carrier + flightNum, flightCol, y + rowHeight/2); 
    
    // Route with arrow
    fill(0, 0, 150);
    text(origin + " → " + dest, routeCol, y + rowHeight/2); 
    
    // Distance with unit
    fill(0, 100, 0);
    text(nf(distance, 0, 1) + " mi", distanceCol, y + rowHeight/2); 
    
    // Status indicators
    if (cancelled == 1) {
      fill(200, 0, 0);
      text("CANCELLED", statusCol, y + rowHeight/2);
    } else if (diverted == 1) {
      fill(255, 165, 0);
      text("DIVERTED", statusCol, y + rowHeight/2);
    } else {
      fill(0, 150, 0);
      text("ON TIME", statusCol, y + rowHeight/2);
    }
    
    // Add subtle row separator
    stroke(220);
    line(50, y + rowHeight, SCREENX-50, y + rowHeight);
    stroke(0);
  }

  void drawFooter() {
    fill(100);
    textSize(20);
    textAlign(RIGHT);
    text("Use mouse wheel to scroll", SCREENX - 60, 115);
    
    // Show current filters
    textAlign(LEFT);
    String filters = "Filters: ";
    if (!dropdown.selected.equals("ALL")) filters += "Airline: " + dropdown.selected + " ";
    if (!dateDropdown.selected.equals("ALL")) filters += "Date: " + dateDropdown.selected + " ";
    if (!selectedState.equals("")) filters += "State: " + selectedState + " ";
    if (!showCancelled) filters += "(No cancelled flights)";
    
    if (!filters.equals("Filters: ")) {
      text(filters, 50, 115);
    }
  }
  
  void mousePressed() 
  {
    dropdown.checkClick(mouseX, mouseY);
    dateDropdown.checkClick(mouseX, mouseY);  
    if (chartButton.isClicked(mouseX, mouseY)) 
    {
      currentScreen = chartScreen;
    }
    if (cancelFilterButton.isClicked(mouseX, mouseY)) 
    {
      showCancelled = !showCancelled;
      cancelFilterButton.label = showCancelled ? "Hide Cancelled" : "Show All Flights";
      scrollOffset = 0;
      targetScrollOffset = 0;
      scrollVelocity = 0;
    }
    if (mapButton.isClicked(mouseX, mouseY)) 
    {
      currentScreen = mapScreen; 
    }
    if (clearStateButton.isClicked(mouseX, mouseY)) 
    {
      selectedState = "";
    }
    if (mouseX > SCREENX - 25 && mouseX < SCREENX - 10 && mouseY > 110 && mouseY < SCREENY - 20) 
    {
      handleScrollbarDrag();
    }
  }
  
  void mouseDragged() 
  {
    if (mouseX > SCREENX - 25 && mouseX < SCREENX - 10 && mouseY > 110 && mouseY < SCREENY - 20) 
    {
      handleScrollbarDrag();
      scrollVelocity = 0;
    }
  }
  
  void mouseWheel(MouseEvent event) 
  {
  if (dropdown.expanded) 
  {
    dropdown.mouseWheel(event);
  } 
  else if (dateDropdown.expanded) 
  {
    dateDropdown.mouseWheel(event);
  } 
  else 
  {
    float e = event.getCount();
    scrollVelocity += e * scrollSensitivity;
    scrollVelocity = constrain(scrollVelocity, -100, 100);
  }
  }
  
  void handleScrollbarDrag() 
  {
    int totalFilteredRows = 0;
    for (int i = 0; i < table.getRowCount(); i++) 
    {
      TableRow row = table.getRow(i);
      String carrier = row.getString("MKT_CARRIER");
      int cancelled = row.getInt("CANCELLED");
      if ((dropdown.selected.equals("ALL") || carrier.equals(dropdown.selected)) &&
          (showCancelled || cancelled == 0)) 
      {
        totalFilteredRows++;
      }
    }
    int totalHeight = totalFilteredRows * 25;
    int maxScroll = totalHeight - (SCREENY - 130);
    if (maxScroll < 0) maxScroll = 0;
    float scrollRatio = constrain((mouseY - 110) / (float)(SCREENY - 130 - 30), 0, 1);
    targetScrollOffset = scrollRatio * maxScroll;
  }
  
  void drawScrollIndicator(int totalRows, int rowHeight) 
    {
  int totalHeight = totalRows * rowHeight;
  if (totalHeight <= SCREENY - 130) return;
  
  int scrollbarHeight = (SCREENY - 130) * (SCREENY - 130) / totalHeight;
  scrollbarHeight = max(30, scrollbarHeight);
  int scrollbarY = 110 + (int)(scrollOffset * (SCREENY - 130 - scrollbarHeight) / (totalHeight - (SCREENY - 130)));
  scrollbarY = constrain(scrollbarY, 110, SCREENY - scrollbarHeight - 20);
  
  fill(200, 200, 200, 150);
  rect(SCREENX - 20, 110, 10, SCREENY - 130);
  
  fill(100, 100, 100, 200);
  rect(SCREENX - 20, scrollbarY, 10, scrollbarHeight, 5);
    }
}


class ChartScreen extends Screen 
{
  ButtonWidget backButton;
  
  ChartScreen() 
  {
    backButton = new ButtonWidget(50, 10, 100, 30, "Back");
  }
  
  void display() 
  {
    background(240);
    barChart.display();
    backButton.display();
  }
  
  void mousePressed() 
  {
    if (backButton.isClicked(mouseX, mouseY)) 
    {
      currentScreen = flightScreen;
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
    else 
    {
      fill(50, 150, 50);
    }
    
    if (isHovered()) 
    {
      if (label.equals("Back")) 
      {
        fill(210, 60, 60);
      } 
      else if (label.contains("Cancelled") || label.contains("Show All")) 
      {
        fill(60, 110, 210);
      } 
      else 
      {
        fill(60, 160, 60);
      }
    }
    
    rect(x, y, w, h, 5);
    fill(255);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
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

class DropdownWidget 
{
  int x, y, w, h;
  ArrayList<String> options;
  boolean expanded = false;
  String selected;
  float scrollOffset = 0; // Scroll offset for the dropdown
  float scrollSensitivity = 10; // Sensitivity for scrolling

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
      int maxDropdownHeight = SCREENY - y - h - 20; 
      int visibleOptions = max(1, maxDropdownHeight / h); 
      int totalHeight = options.size() * h;

      fill(255, 255, 255, 230);
      rect(x, y + h, w, min(totalHeight, maxDropdownHeight), 5);

      // Display visible options
      for (int i = 0; i < options.size(); i++) 
      {
        float optionY = y + h + i * h - scrollOffset;
        if (optionY >= y + h && optionY < y + h + maxDropdownHeight) 
        {
          fill(240);
          rect(x, optionY, w, h, 5);
          fill(0);
          text(options.get(i), x + 10, optionY + h - 5);
        }
      }

      if (totalHeight > maxDropdownHeight) 
      {
        float scrollbarHeight = max(30, (float)maxDropdownHeight / totalHeight * maxDropdownHeight);
        float scrollbarY = y + h + scrollOffset / totalHeight * maxDropdownHeight;
        fill(200, 200, 200, 150);
        rect(x + w - 10, y + h, 10, maxDropdownHeight);
        fill(100, 100, 100, 200);
        rect(x + w - 10, scrollbarY, 10, scrollbarHeight, 5);
      }
    }
  }

  void checkClick(int mx, int my) 
  {
    if (mx > x && mx < x + w && my > y && my < y + h) 
    {
      expanded = !expanded;
    } 
    else if (expanded) 
    {
      for (int i = 0; i < options.size(); i++) 
      {
        float optionY = y + h + i * h - scrollOffset;
        if (mx > x && mx < x + w && my > optionY && my < optionY + h) 
        {
          selected = options.get(i);
          expanded = false;

          flightScreen.scrollOffset = 0;
          flightScreen.targetScrollOffset = 0;
          flightScreen.scrollVelocity = 0;
        }
      }
    }
  }

  void mouseWheel(MouseEvent event) 
  {
    if (expanded) 
    {
      float e = event.getCount();
      scrollOffset += e * scrollSensitivity;
      scrollOffset = constrain(scrollOffset, 0, max(0, options.size() * h - (SCREENY - y - h - 20)));
    }
  }
}

class BarChartWidget 
{
  int x, y, w, h;
  HashMap<String, Integer> flightCounts;
  HashMap<String, Integer> cancelledCounts;
  HashMap<String, Integer> divertedCounts;
  int maxFlights;
  
  BarChartWidget(int x, int y, int w, int h, Table table) 
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.flightCounts = new HashMap<>();
    this.cancelledCounts = new HashMap<>();
    this.divertedCounts = new HashMap<>();
    
    for (TableRow row : table.rows()) 
    {
      String carrier = row.getString("MKT_CARRIER");
      int cancelled = row.getInt("CANCELLED");
      int diverted = row.getInt("DIVERTED");  

      flightCounts.put(carrier, flightCounts.getOrDefault(carrier, 0) + 1);
  
      if (cancelled == 1) 
      {
         cancelledCounts.put(carrier, cancelledCounts.getOrDefault(carrier, 0) + 1);
      }

      if (diverted == 1) 
      {
        divertedCounts.put(carrier, divertedCounts.getOrDefault(carrier, 0) + 1);
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
    fill(0, 0, 255);
    textSize(40);
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
      
      if (cancelled > 0) 
      {
        fill(255, 0, 0);
        text("(" + cancelled + " canc.)", startX + index * barWidth + barWidth / 2, y + h - barHeight - 20);
      }
      int diverted = divertedCounts.getOrDefault(carrier, 0);
      int divertedHeight = int(map(diverted, 0, maxFlights, 0, h - 100));

      fill(100, 255, 100); 
      rect(startX + index * barWidth, y + h - barHeight, barWidth - 5, divertedHeight);

      if (diverted > 0) 
      {
        fill(0, 128, 0);
        text("(" + diverted + " div.)", startX + index * barWidth + barWidth / 2, y + h - barHeight - 35);
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
    
    fill(100, 255, 100);
    rect(SCREENX - 150, 160, 15, 15);
    fill(0);
    text("Diverted", SCREENX - 130, 173);
  }
}

class mapScreen extends Screen {
  PImage usaMap;
  ButtonWidget backButton;
  String[] states;
  float[][] coords;

  mapScreen() {
    usaMap = loadImage("usaMap.png");
    backButton = new ButtonWidget(50, 10, 100, 30, "Back");

    states = new String[]{
      "WA", "OR", "CA", "NV", "ID", "MT", "WY", "UT", "AZ", "CO", "NM", 
      "ND", "SD", "NE", "KS", "OK", "TX", 
      "MN", "IA", "MO", "AR", "LA", 
      "WI", "IL", "MS", "AL", 
      "MI", "IN", "OH", "KY", "TN", 
      "FL", "GA", "SC", "NC", "VA", "WV", 
      "PA", "NY", "NJ", "DE", "MD", "CT", "MA", "VT", "NH", "ME",
      "AK", "HI"
    };

    coords = new float[][]  
    {
      {165, 95}, {133, 184}, {117, 380}, {191, 344}, {240, 226}, {368, 144}, {389, 258}, {286, 339}, {271, 458}, {405, 367}, {381, 460},
      {524, 152}, {521, 228}, {537, 296}, {567, 387}, {566, 455}, {567, 571},
      {632, 184}, {653, 283}, {673, 378}, {680, 480}, {682, 569},
      {725, 212}, {738, 321}, {744, 538}, {809, 530},
      {825, 238}, {807, 324}, {882, 320}, {861, 387}, {818, 448},
      {947, 619}, {891, 518}, {940, 484}, {973, 437}, {976, 380}, {918, 363},
      {973, 287}, {1013, 228}, {1043, 308}, {1027, 335}, {994, 328}, {1072, 255},  {1077, 231}, {1051, 179}, {1082, 196}, {1127, 139},
      {90, 665}, {220, 690}
    };
  }

  void display() {
    background(255);
    image(usaMap, 0, 0, SCREENX, SCREENY);
    drawStateLabels();
    backButton.display();
  }

  void drawStateLabels() {
    textAlign(CENTER, CENTER);
    textSize(12);
    fill(255);
    for (int i = 0; i < states.length; i++) {
      text(states[i], coords[i][0], coords[i][1]);
    }
  }

  void mousePressed() 
  {
    String clickedState = getClickedState(mouseX, mouseY);
    if (clickedState != null) {
      flightScreen.selectedState = clickedState;
      currentScreen = flightScreen;
    }

      if ( mouseX > 50 && mouseX < 150 && mouseY > 10 && mouseY < 30)
    {
      currentScreen = flightScreen;
      
    }
  }

  String getClickedState(int mx, int my) 
  {
  for (int i = 0; i < coords.length; i++) {
    float cx = coords[i][0];
    float cy = coords[i][1];
    float boxSize = 20; 

    if (mx > cx - boxSize/2 && mx < cx + boxSize/2 &&
        my > cy - boxSize/2 && my < cy + boxSize/2) {
      return states[i];
    }
  }
  return null;
}
}
