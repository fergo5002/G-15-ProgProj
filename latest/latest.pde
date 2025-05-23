import processing.video.*;
import processing.sound.*;
SoundFile easterSound;
// these are the main variables for our program
Table table;  // stores all them flight data
BarChartWidget barChart;  // makes those cool bar graphs
PImage plane;  // our sexy background image!
PImage usaMap;  // map of the USA for the flight map screen
Movie loadingVideo;
Screen currentScreen;  // keeps track of which screen were on
HomeScreen homeScreen;  // the welcome screen with the cool plane
FlightScreen flightScreen;  // where all the magic happens lol
ChartScreen chartScreen;  // shows them graphs
mapScreen mapScreen;  // screen for selecting states
loadingScreen loadingScreen;
boolean showCancelled = true;  // this bad boi controls if we show cancelled flights or not
int SCREENX = 1200;  // screen dimensions - dont mess with these unless u want everything to break!!
int SCREENY = 780;
PFont sitkaFont;  // our pretty font
PImage toyPlane;  // toy plane image for animations
int loadingStartTime;
boolean dataLoaded = false;
PImage easterEgg;
boolean showEasterEgg = false;
PVector eggPosition;
int eggWidth = 600;
int eggHeight = 450;

void settings() 
{
  size(SCREENX, SCREENY);         // initialising the size of the display, dimensions are finalized above.
  plane = loadImage("plane-photo(1).jpg");   // loading the image of the plane into the program
  plane.resize(SCREENX, SCREENY);     // resizing the plane to have it appropriately fit our screen dimensions
  size(SCREENX, SCREENY);             // same thing as above bud
  usaMap = loadImage("usaMap.png");     // loading the map of the USA into the program 
  usaMap.resize(SCREENX, SCREENY);      // resizing the size of the map to have it fit nicely into our program
  toyPlane = loadImage("toyPlane.png");  // loading the image of the toy plane into the program
  toyPlane.resize(51, 51);               //  resizing the size of the toy plane to have it fit nicely into our program
  easterEgg = loadImage("easterEgg.png");  // Load Easter Egg image
  easterEgg.resize(eggWidth, eggHeight);
  
}

void setup() // setup of the program
{
  easterSound = new SoundFile(this, "easterSound.mp3");
// easterSound.play();
  loadingStartTime = millis();    // having the loading timeset to milliseconds
  currentScreen = new loadingScreen(this);  // saying that the current screen we are on is the loading screen
  
  thread("loadingDataIntoBackground");     // showing the loading animation as a thread
}

void loadingDataIntoBackground(){      // the "loadingDataIntoBackground" class for our loading screen 
  sitkaFont = loadFont("Consolas.vlw");   // loading the font "Consolas.vlw" into the program, cuz it's bussin
  table = loadTable("flights.csv", "header");  // Laoding the data into the program
  barChart = new BarChartWidget(100, 100, SCREENX - 200, SCREENY - 300, table);  // plugging in dinmensions of the barchart into the program
  homeScreen = new HomeScreen();   // initialising the home screen
  flightScreen = new FlightScreen();  // initialising the flightscreen
  chartScreen = new ChartScreen();  //initialising the chart screen
  mapScreen = new mapScreen();    // initialising the map screen
 
  dataLoaded = true;    // setting the data loaded to true because we just did it above
}

void movieEvent(Movie m){
    if(m!=null){
       m.read();
    }
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

// Add this near your other event handlers

void keyPressed() {
  if (currentScreen instanceof FlightScreen) {
    ((FlightScreen)currentScreen).keyPressed();
  }
}

abstract class Screen 
{
  void display() 
  {
  }
  
  void mousePressed() 
  {
  }
  
  void mouseDragged() 
  {
  }
  
  void mouseWheel(MouseEvent event) 
  {
  }
}

class loadingScreen extends Screen {
  float progress = 0;
  String status = "Loading Flight Data...";  
  boolean videoAvailable = false;
  PApplet parent;
 
  
  loadingScreen(PApplet parent) {
    this.parent=parent;
    try {
      // Initialize video - make sure "loadingVideo.mp4" exists in your data folder
      loadingVideo = new Movie(parent, "loadingVideo.mp4");
      loadingVideo.loop();
      videoAvailable = true;
      println("Video loaded successfully");
    } catch (Exception e) {
      println("Error loading video: " + e.getMessage());
      videoAvailable = false;
    }
  }
  
  void display() {
    // Display the video as the background for the loading screen.
    if (videoAvailable && loadingVideo != null && loadingVideo.width > 0) {
      image(loadingVideo, 0, 0, width, height);
      if(loadingVideo.available()){
        loadingVideo.read();
      }
    } else {
      // Fallback background if video fails
      background(0);
      fill(100);
      rect(0, 0, width, height);
    }    
    
    // Calculate progress (either time-based or completion-based)
    float timeProgress = min(1.0, (millis() - loadingStartTime) / 5000.0);
    progress = dataLoaded ? 1.0 : timeProgress * 0.9; // Cap at 90% until data loads
    
    drawProgressBar(width/2 - 150, height/2, 300, 20, progress);
    
    if (dataLoaded) {
      status = "Loading complete!";
    } else if (millis() - loadingStartTime > 6000) {
      status = "Taking longer than expected...";
    }
    
    fill(255);
    textSize(40);
    textAlign(CENTER, CENTER);
    text(status, width/2, height/2 - 80);
    
    textSize(24);
    text(nf(progress * 100, 1, 1) + "%", width/2, height/2 + 80);
    drawProgressBar(width/2 - 150, height/2, 300, 20, progress);
    
    // Transition: if data is loaded and after a minimum time, switch to the home screen.
    if (dataLoaded && millis() - loadingStartTime > 2000) {
      // Optionally, stop the video playback.
      loadingVideo.stop();
      currentScreen = homeScreen;
    }
  }
  
  void drawProgressBar(float x, float y, float w, float h, float p) {
    noStroke();
    fill(100);
    rect(x, y, w, h, 10);
    
    fill(100, 200, 255);
    rect(x, y, w * p, h, 10);
    
    noFill();
    stroke(255);
    strokeWeight(2);
    rect(x, y, w, h, 10);
  }
}

class HomeScreen extends Screen
{
  // this is were the magic starts - our home screen stuff
  ButtonWidget startButton;  // the button that gets u into the action
  
  // constructor - sets up the welcome page
  HomeScreen() 
  {
    // slap that button right in the middle!
    startButton = new ButtonWidget(SCREENX/2 - 100, SCREENY/2 + 50, 200, 50, "Start FlyRadar");
  }
  
  void display() //class for the display of the home screen
  {
    background(25, 25, 112);   // Setting the colour of the homescreen
    image(plane, 0, 0);        // Putting plane image into the home screen
    fill(0, 0, 50, 100);      // Setting colour of the home screen
    rect(0, 0, SCREENX, SCREENY);   // setting rectangle for the screen using our finalised values: Screen X and Y
    fill(255);     // making it white
    textSize(80);   // Setting the size of text, it's as massive as the low taper fade meme
    textAlign(CENTER, CENTER);   // Aligning thge text with the centre
    text("FlyRadar", SCREENX/2, SCREENY/2 - 100);   // Having the text 
    textSize(24);   // size of the text is 24
    text("Flight Data Visualization Tool", SCREENX/2, SCREENY/2 - 40); // putting the text in 
    startButton.display();    // displaying the start button
    float pulseValue = 128 + 127 * sin(frameCount * 0.05);  // Our sin function to make the text pulse, its sick.
    fill(pulseValue);
    textSize(18);
    text("Click Start to Explore Flight Data", SCREENX/2, SCREENY/2 + 150);
        if (showEasterEgg) {
    image(easterEgg, SCREENX - eggWidth - 20, SCREENY - eggHeight - 20);
    eggPosition = new PVector(SCREENX - eggWidth - 20, SCREENY - eggHeight - 20);
  }
  }
  
  void mousePressed() 
  {
    if (startButton.isClicked(mouseX, mouseY))
    {
      currentScreen = flightScreen;
    }
       if (!showEasterEgg && mouseX > SCREENX - 60 && mouseY > SCREENY - 60) {
    showEasterEgg = true;
  } 
  else if (showEasterEgg && mouseX >= eggPosition.x && mouseX <= eggPosition.x + eggWidth && mouseY >= eggPosition.y && mouseY <= eggPosition.y + eggHeight) 
  {
    showEasterEgg = false;
  }
  
  if (!showEasterEgg && mouseX > SCREENX - 60 && mouseY > SCREENY - 60) {
  showEasterEgg = true;
  if (easterSound != null) {
    easterSound.play();  // ✅ Safe play call
  } else {
    println("easterSound is null — make sure it's loaded in setup()");
  }
}
else if (showEasterEgg && eggPosition != null &&
         mouseX >= eggPosition.x && mouseX <= eggPosition.x + eggWidth &&
         mouseY >= eggPosition.y && mouseY <= eggPosition.y + eggHeight){
  showEasterEgg = false;
}
  //ur looking at
  }
}

class FlightScreen extends Screen 
{
  // Remove dropdown and add searchBox variables
  DropdownWidget dateDropdown;  // lets u choose which day ur looking at
  ButtonWidget chartButton;
  ButtonWidget cancelFilterButton;
  ButtonWidget mapButton;
  ButtonWidget clearStateButton;
  String selectedState = "";
  String searchQuery = "";
  boolean searchBoxActive = false;
  int searchBoxX = 150;
  int searchBoxY = 10;
  int searchBoxW = 150;
  int searchBoxH = 25;
  float scrollOffset = 0;
  float targetScrollOffset = 0;
  float scrollVelocity = 0;
  float scrollFriction = 0.5;
  float scrollSensitivity = 15;
  boolean showDivertedOnly = false;
  boolean showCancelledOnly = false;

  FlightScreen() 
  {
    // Remove dropdown initialization, keep others
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
  
  void drawCheckbox(int x, int y, boolean checked) 
  {
    fill(255);
    stroke(0);
    rect(x, y, 20, 20);
    if (checked) {
      line(x + 4, y + 10, x + 9, y + 15);
      line(x + 9, y + 15, x + 16, y + 5);
    }
  }
  
  void display() 
  {
    textFont(sitkaFont);
    background(240);
    stroke(0);
    strokeWeight(1);
    fill(0);
    textSize(15);
    textAlign(LEFT);
    text("Search Flight #:", 10, 30);  // Changed from "Select Airline"
    text("Select Date:", 10, 70);

    // Draw search box
    fill(255);
    rect(searchBoxX, searchBoxY, searchBoxW, searchBoxH, 5);
    fill(0);
    if (searchQuery.isEmpty() && !searchBoxActive) {
      fill(150);
      text("Enter flight number...", searchBoxX + 5, searchBoxY + searchBoxH - 5);
    } else {
      fill(0);
      text(searchQuery, searchBoxX + 5, searchBoxY + searchBoxH - 5);
    }
    
    // Draw cursor if search box is active
    if (searchBoxActive && (frameCount % 60 < 30)) {
      float cursorX = searchBoxX + 5 + textWidth(searchQuery);
      line(cursorX, searchBoxY + 5, cursorX, searchBoxY + searchBoxH - 5);
    }

    fill(0);
    text("Show Only Cancelled:", 330, 30);
    drawCheckbox(500, 18, showCancelledOnly);
    fill(0);
    text("Show Only Diverted:", 330, 70);
    drawCheckbox(500, 58, showDivertedOnly);
    targetScrollOffset += scrollVelocity;
    scrollVelocity *= 0.85;
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
      if ((showCancelled || cancelled == 0))
      {
        dataRowCount++;
      }
    }
    int maxScroll = dataRowCount * 25 - (SCREENY - 130);
    if (maxScroll < 0)
    {
      maxScroll = 0;
    }
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
    clearStateButton.display();
    chartButton.display();
    cancelFilterButton.display();
    mapButton.display();
    fill(100);
    textSize(18); 
    textAlign(RIGHT);
    text("Showing all ", cancelFilterButton.x - 10, cancelFilterButton.y + 15);
    text(showCancelled ? " flights" : "non-cancelled flights", cancelFilterButton.x - 10, cancelFilterButton.y + 32);  
    fill(0);
    textAlign(LEFT);
    textSize(16);
    text("showing " + getFilteredCount() + " matching flights", 550, 100); 
  }
  
  void displayFlights() 
  {
    // this function is a beast - displays all the flight info
    // honestly im not sure how it works anymore but it does LOL
    drawColumnHeaders();
    int yOffset = 160 - (int)scrollOffset;
    int maxY = SCREENY - 20;
    int rowHeight = 30;
    int startIndex = max(0, (int)(scrollOffset / rowHeight));
    int visibleRows = (SCREENY - 160) / rowHeight + 2;
    int processedRows = 0;
    int totalFilteredRows = 0;
    for (int i = 0; i < table.getRowCount(); i++)
    {
      TableRow row = table.getRow(i);
      if (!passesFilters(row))
      {
        continue;
      }
      totalFilteredRows++;
      if (totalFilteredRows >= startIndex && processedRows < visibleRows)
      {
        if (yOffset > 160 && yOffset < maxY)
        {
          drawFlightRow(row, yOffset, rowHeight);
          processedRows++;
        }
      }
      yOffset += rowHeight;
    }
    drawScrollIndicator(totalFilteredRows, rowHeight);
    drawFooter();
  }
  
  // this function figures out which flights to show based on filters
  // its kinda messy but it works dont touch it!!
  boolean passesFilters(TableRow row) 
  {
    String carrier = row.getString("MKT_CARRIER");
    int flightNum = row.getInt("MKT_CARRIER_FL_NUM");
    String flightString = carrier + flightNum;
    int cancelled = row.getInt("CANCELLED");
    int diverted = row.getInt("DIVERTED");
    String date = row.getString("FL_DATE").split(" ")[0];
    String originState = row.getString("ORIGIN_STATE_ABR");

    boolean matchesSearch = searchQuery.isEmpty() || 
                          flightString.toLowerCase().contains(searchQuery.toLowerCase());

    if (showCancelledOnly && cancelled != 1) return false;
    if (showDivertedOnly && diverted != 1) return false;

    return matchesSearch &&
           (dateDropdown.selected.equals("ALL") || date.equals(dateDropdown.selected)) &&
           (showCancelled || cancelled == 0) &&
           (selectedState.equals("") || originState.equals(selectedState));
  }

  int getFilteredCount() 
  {
    int count = 0;
    for (int i = 0; i < table.getRowCount(); i++)
    {
      if (passesFilters(table.getRow(i)))
      {
        count++;
      }
    }
    return count;
  }
  
  void drawColumnHeaders() 
  {
    fill(70, 70, 120);
    rect(50, 130, SCREENX - 100, 30, 5);
    fill(255);
    textSize(14);
    textAlign(LEFT, CENTER);
    float dateCol = 60;
    float flightCol = dateCol + 150;
    float routeCol = flightCol + 200;
    float distanceCol = routeCol + 200;
    float statusCol = distanceCol + 150;
    float viewCol = statusCol + 100;
    text("Date", dateCol, 145);
    text("Flight #", flightCol, 145);
    text("Route", routeCol, 145);
    text("Distance", distanceCol, 145);
    text("Status", statusCol, 145);
    text("View", viewCol, 145);
  }
  
  void drawFlightRow(TableRow row, int y, int rowHeight) 
  {
    String date = row.getString("FL_DATE").split(" ")[0];
    String carrier = row.getString("MKT_CARRIER");
    int flightNum = row.getInt("MKT_CARRIER_FL_NUM");
    String origin = row.getString("ORIGIN");
    String dest = row.getString("DEST");
    float distance = row.getFloat("DISTANCE");
    int cancelled = row.getInt("CANCELLED");
    int diverted = row.getInt("DIVERTED");
    float dateCol = 60;
    float flightCol = dateCol + 150;
    float routeCol = flightCol + 200;
    float distanceCol = routeCol + 200;
    float statusCol = distanceCol + 150;
    textSize(18);
    textAlign(LEFT, CENTER);
    fill(0);
    text(date, dateCol, y + rowHeight / 2);
    fill(128, 0, 128);
    text(carrier + flightNum, flightCol, y + rowHeight / 2);
    fill(0, 0, 150);
    text(origin + " → " + dest, routeCol, y + rowHeight / 2);
    fill(0, 100, 0);
    text(nf(distance, 0, 1) + " mi", distanceCol, y + rowHeight / 2);
    if (cancelled == 1)
    {
      fill(200, 0, 0);
      text("CANCELLED", statusCol, y + rowHeight / 2);
    }
    else if (diverted == 1)
    {
      fill(255, 165, 0);
      text("DIVERTED", statusCol, y + rowHeight / 2);
    }
    else
    {
      fill(0, 150, 0);
      text("ON TIME", statusCol, y + rowHeight / 2);
    }
    stroke(220);
    line(50, y + rowHeight, SCREENX - 50, y + rowHeight);
    stroke(0);
    int viewButtonW = 60;
    int viewButtonH = 20;
    int viewButtonX = int(statusCol + 100);
    int viewButtonY = y + (rowHeight - viewButtonH) / 2;
    boolean hovering = mouseX >= viewButtonX && mouseX <= viewButtonX + viewButtonW &&
     mouseY >= viewButtonY && mouseY <= viewButtonY + viewButtonH;
     if (hovering){
     fill(60,180,60);
     }else{ 
     fill(50,150,50);  
     }
    rect(viewButtonX, viewButtonY, viewButtonW, viewButtonH, 5);
    fill(255);
    textAlign(CENTER, CENTER);
    text("View", viewButtonX + viewButtonW / 2, viewButtonY + viewButtonH / 2);
    textAlign(LEFT, BASELINE);
  }
  
  void drawFooter() 
  {
    fill(100);
    textSize(20);
    textAlign(RIGHT);
    text("Use mouse wheel to scroll", SCREENX - 60, 115);
    textAlign(LEFT);
    String filters = "Filters: ";
    if (!dateDropdown.selected.equals("ALL"))
    {
      filters += "Date: " + dateDropdown.selected + " ";
    }
    if (!selectedState.equals(""))
    {
      filters += "State: " + selectedState + " ";
    }
    if (!showCancelled) {
      filters += "(No cancelled flights)";
    }
    if (!filters.equals("Filters: "))
    {
      text(filters, 50, 115);
    }
  }
  
  void mousePressed() 
  {
    // Add search box activation check
    if (mouseX > searchBoxX && mouseX < searchBoxX + searchBoxW &&
        mouseY > searchBoxY && mouseY < searchBoxY + searchBoxH) {
      searchBoxActive = true;
    } else {
      searchBoxActive = false;
    }
    if (mouseX >= 500 && mouseX <= 520) {
  if (mouseY >= 18 && mouseY <= 38) {   
    showCancelledOnly = !showCancelledOnly;   
    if (showCancelledOnly) showDivertedOnly = false; // turn off other
    return;
  } else if (mouseY >= 58 && mouseY <= 78) {
    showDivertedOnly = !showDivertedOnly;
    if (showDivertedOnly) showCancelledOnly = false; // turn off other
    return;
  }
}
    dateDropdown.checkClick(mouseX, mouseY);
    if (chartButton.isClicked(mouseX, mouseY))
    {
      currentScreen = chartScreen;
      return;
    }
    if (cancelFilterButton.isClicked(mouseX, mouseY))
    {
      showCancelled = !showCancelled;
      cancelFilterButton.label = showCancelled ? "Hide Cancelled" : "Show All Flights"; 
      if (!showCancelled != showCancelledOnly){
      showCancelledOnly = false; 
      }
      scrollOffset = 0;
      targetScrollOffset = 0; 
      scrollVelocity = 0;
      return;
    }
    if (mapButton.isClicked(mouseX, mouseY))
    {
      currentScreen = mapScreen;
      return;
    }
    if (clearStateButton.isClicked(mouseX, mouseY))
    {
      selectedState = "";
      return;
    }
    if (mouseX > SCREENX - 25 && mouseX < SCREENX - 10 && mouseY > 110 && mouseY < SCREENY - 20)
    {
      handleScrollbarDrag();
      return;
    }
    int yOffset = 160 - (int)scrollOffset;
    int rowHeight = 30;
    int startIndex = max(0, (int)(scrollOffset / rowHeight));
    int visibleRows = (SCREENY - 160) / rowHeight + 2;
    int processedRows = 0;
    int totalFilteredRows = 0;
    for (int i = 0; i < table.getRowCount(); i++)
    {
      TableRow row = table.getRow(i);
      if (!passesFilters(row))
      {
        continue;
      }
      totalFilteredRows++;
      if (totalFilteredRows >= startIndex && processedRows < visibleRows)
      {
        if (yOffset > 160 && yOffset < SCREENY - 20)
        {
          float statusCol = 760;
          int viewButtonW = 60;
          int viewButtonH = 20;
          int viewButtonX = int(statusCol + 100);
          int viewButtonY = yOffset + (rowHeight - viewButtonH) / 2;
          if (mouseX >= viewButtonX && mouseX <= viewButtonX + viewButtonW && mouseY >= viewButtonY && mouseY <= viewButtonY + viewButtonH)
          {
            currentScreen = new FlightMapScreen(row);
            return;
          }
          processedRows++;
        }
      }
      yOffset += rowHeight;
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
    if (dateDropdown.expanded)
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
      if ((showCancelled || cancelled == 0))
      {
        totalFilteredRows++;
      }
    }
    int totalHeight = totalFilteredRows * 25;
    int maxScroll = totalHeight - (SCREENY - 130);
    if (maxScroll < 0)
    {
      maxScroll = 0;
    }
    float scrollRatio = constrain((mouseY - 110) / (float)(SCREENY - 130 - 30), 0, 1);
    targetScrollOffset = scrollRatio * maxScroll;
  }
  
  void drawScrollIndicator(int totalRows, int rowHeight) 
  {
    int totalHeight = totalRows * rowHeight;
    if (totalHeight <= SCREENY - 130)
    {
      return;
    }
    float scrollRatio = (SCREENY - 130) / (float)totalHeight;
    int scrollbarHeight = max(30, (int)((SCREENY - 130) * scrollRatio));  
    int scrollbarY = 160 + (int)(scrollOffset * (SCREENY - 130 - scrollbarHeight) / (totalHeight - (SCREENY - 130)));
    fill(200, 200, 200, 150);
    rect(SCREENX - 20, 160, 10, SCREENY - 130);
    fill(100, 100, 100, 200);
    rect(SCREENX - 20, scrollbarY, 10, scrollbarHeight, 5);
  }
  
  void keyPressed() {
    // Check if numeric input
    if ((key >= '0' && key <= '9') || 
        (key >= 'A' && key <= 'Z') || 
        (key >= 'a' && key <= 'z')) {
      searchQuery += key;
    }
    // Handle backspace
    else if (keyCode == BACKSPACE && searchQuery.length() > 0) {
      searchQuery = searchQuery.substring(0, searchQuery.length() - 1);
    }
    // Handle delete/clear
    else if (keyCode == DELETE) {
      searchQuery = "";
    }
  }
}

class ChartScreen extends Screen 
{
  ButtonWidget backButton;
  ButtonWidget nextChartButton;
  ChartScreen() 
  {
    backButton = new ButtonWidget(50, 10, 100, 30, "Back");
    barChart.animationProgress = 0;
    barChart.animating = true; 
    nextChartButton = new ButtonWidget(180, 10, 150, 30, "Next Chart"); 
  }
  
  void display() 
  {
    background(240);
    barChart.display();
    backButton.display();
    nextChartButton.display();
  }
  
  void mousePressed() 
  {
    if (backButton.isClicked(mouseX, mouseY))
    {
      currentScreen = flightScreen;
    }
    if (nextChartButton.isClicked(mouseX, mouseY)) 
    {
      currentScreen = new LineChartScreen();
      return;
    }
  }
}

class FlightMapScreen extends Screen 
{
  // this shows a cool map with planes flying around!
  // took me way too long to get the plane animation working properly smh
  
  TableRow flightRow;
  ButtonWidget backButton;
  float minLon = -125.0;
  float maxLon = -66.0;
  float minLat = 24.0;
  float maxLat = 50.0;
  HashMap<String, float[]> airportCoords = new HashMap<String, float[]>();
  HashMap<String, PVector> airportOffsets = new HashMap<String, PVector>();
  PVector originPos;
  PVector destPos;
  float animationProgress = 0.0;
  float animationSpeed = 0.003;  // make it go zoom zoom
  boolean animationComplete = false;
  
  FlightMapScreen(TableRow row) 
  {
    flightRow = row;
    backButton = new ButtonWidget(50, 10, 100, 30, "Back");
    airportCoords.put("ABQ", new float[]{35.0402f, -106.6090f});
    airportCoords.put("AUS", new float[]{30.1975f, -97.6664f});
    airportCoords.put("ATL", new float[]{33.6407f, -84.4277f});
    airportCoords.put("BNA", new float[]{36.1263f, -86.6774f});
    airportCoords.put("BOS", new float[]{42.3656f, -71.0096f});
    airportCoords.put("BWI", new float[]{39.1754f, -76.6684f});
    airportCoords.put("CLE", new float[]{41.4058f, -81.8539f});
    airportCoords.put("CLT", new float[]{35.2144f, -80.9473f});
    airportCoords.put("CVG", new float[]{39.0533f, -84.6630f});
    airportCoords.put("DAL", new float[]{32.8471f, -96.8517f});
    airportCoords.put("DCA", new float[]{38.8512f, -77.0402f});
    airportCoords.put("DEN", new float[]{39.8561f, -104.6737f});
    airportCoords.put("DFW", new float[]{32.8998f, -97.0403f});
    airportCoords.put("DTW", new float[]{42.2162f, -83.3554f});
    airportCoords.put("EWR", new float[]{40.6895f, -74.1745f});
    airportCoords.put("FLL", new float[]{26.0726f, -80.1527f});
    airportCoords.put("HNL", new float[]{21.3245f, -157.9251f});
    airportCoords.put("HOU", new float[]{29.6454f, -95.2789f});
    airportCoords.put("IAD", new float[]{38.9531f, -77.4565f});
    airportCoords.put("IAH", new float[]{29.9902f, -95.3368f});
    airportCoords.put("IND", new float[]{39.7169f, -86.2956f});
    airportCoords.put("JAX", new float[]{30.4941f, -81.6879f});
    airportCoords.put("JFK", new float[]{40.6413f, -73.7781f});
    airportCoords.put("LAS", new float[]{36.0840f, -115.1537f});
    airportCoords.put("LAX", new float[]{33.9416f, -118.4085f});
    airportCoords.put("LGA", new float[]{40.7769f, -73.8740f});
    airportCoords.put("MCI", new float[]{39.2976f, -94.7139f});
    airportCoords.put("MCO", new float[]{28.4312f, -81.3081f});
    airportCoords.put("MIA", new float[]{27.0f, -76.9f});
    airportCoords.put("MKE", new float[]{42.9470f, -87.8966f});
    airportCoords.put("MSP", new float[]{44.8848f, -93.2223f});
    airportCoords.put("MSY", new float[]{29.9934f, -90.2580f});
    airportCoords.put("OAK", new float[]{37.7126f, -122.2197f});
    airportCoords.put("OKC", new float[]{35.3931f, -97.6008f});
    airportCoords.put("ONT", new float[]{34.0559f, -117.6005f});
    airportCoords.put("ORD", new float[]{41.9742f, -87.9073f});
    airportCoords.put("PDX", new float[]{45.5887f, -122.5975f});
    airportCoords.put("PHL", new float[]{39.8729f, -75.2437f});
    airportCoords.put("PHX", new float[]{33.4342f, -112.0110f});
    airportCoords.put("PIT", new float[]{40.4914f, -80.2329f});
    airportCoords.put("RDU", new float[]{35.8776f, -78.7870f});
    airportCoords.put("RSW", new float[]{26.5362f, -81.7552f});
    airportCoords.put("SAN", new float[]{33.7338f, -118.1933f});
    airportCoords.put("SAT", new float[]{29.4246f, -98.4861f});
    airportCoords.put("SEA", new float[]{47f, -118.5f});
    airportCoords.put("SFO", new float[]{37.6213f, -122.3790f});
    airportCoords.put("SJC", new float[]{37.3639f, -121.9289f});
    airportCoords.put("SJU", new float[]{18.4394f, -66.0018f});
    airportCoords.put("SLC", new float[]{40.7899f, -111.9791f});
    airportCoords.put("SMF", new float[]{38.6954f, -121.5908f});
    airportCoords.put("STL", new float[]{38.7487f, -90.3700f});
    airportCoords.put("TPA", new float[]{27.9755f, -82.5332f});
    airportCoords.put("TUL", new float[]{36.1984f, -95.8881f});
    String origin = flightRow.getString("ORIGIN");
    String dest = flightRow.getString("DEST");
    originPos = getAirportScreenPosition(origin);
    destPos = getAirportScreenPosition(dest);
  }
  
  void display() 
  {
    background(255);
    image(usaMap, 0, 0, SCREENX, SCREENY);
    backButton.display();
    String flightInfo = flightRow.getString("FL_DATE") + " | " + flightRow.getString("MKT_CARRIER") + flightRow.getInt("MKT_CARRIER_FL_NUM") + " | " + flightRow.getString("ORIGIN") + " → " + flightRow.getString("DEST");
    fill(0);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(flightInfo, SCREENX/2, 40);
    int cancelled  = flightRow.getInt("CANCELLED");
    strokeWeight(0);
    if ( cancelled == 1) {
    fill (200,0,0);     
    textSize(22); 
    text("Flight did not leave the terminal (CANCELLED)", SCREENX / 2, SCREENY / 2);
    return;
  }
    String origin = flightRow.getString("ORIGIN");
    String dest = flightRow.getString("DEST");
    PVector originPos = getAirportScreenPosition(origin);
    PVector destPos = getAirportScreenPosition(dest);

    fill(255, 0, 0);
    noStroke();
    ellipse(originPos.x, originPos.y, 10, 10);
    ellipse(destPos.x, destPos.y, 10, 10);

    fill(0);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(origin, originPos.x, originPos.y - 15);
    text(dest, destPos.x, destPos.y - 15);
    
    stroke(0, 0, 255);
    strokeWeight(3);
    line(originPos.x, originPos.y, destPos.x, destPos.y);
    
    if (!animationComplete) 
    {
      animationProgress += animationSpeed;
      if (animationProgress >= 1.0) 
      {
        animationProgress = 0.0;  
      }
    }
    
    float currentX = lerp(originPos.x, destPos.x, animationProgress);
    float currentY = lerp(originPos.y, destPos.y, animationProgress);
    
    float angle = atan2(destPos.y - originPos.y, destPos.x - originPos.x);
    
    pushMatrix();
    translate(currentX, currentY);
    rotate(angle + -55);
    imageMode(CENTER);
    image(toyPlane, 0, 0);
    imageMode(CORNER);
    popMatrix();
  }
  
  void mousePressed() 
  {
    if (backButton.isClicked(mouseX, mouseY))
    {
      currentScreen = flightScreen;
    }
  }
  
  PVector getAirportScreenPosition(String code) 
  {
    float[] latLon = airportCoords.get(code);
    if (latLon == null)
    {
      return new PVector(SCREENX/2, SCREENY/2);
    }
    float lat = latLon[0];
    float lon = latLon[1];
    float x = map(lon, minLon, maxLon, 0, SCREENX);
    float y = map(lat, maxLat, minLat, 0, SCREENY); 
    PVector offset = airportOffsets.get(code);
    if (offset != null)
    {
      x += offset.x;
      y += offset.y;
    }
    return new PVector(x, y);
  }
  
  void restartAnimation() {
    animationProgress = 0.0;
    animationComplete = false;
  }
  
  void setAnimationSpeed(float speed) {
    animationSpeed = speed;
  }
}

class mapScreen extends Screen 
{
  PImage usaMap;
  ButtonWidget backButton;
  String[] states;
  float[][] coords;
  
  mapScreen() 
  {
    usaMap = loadImage("usaMap.png");
    backButton = new ButtonWidget(50, 10, 100, 30, "Back");
    states = new String[]
    {
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
      {973, 287}, {1013, 228}, {1043, 308}, {1027, 335}, {994, 328}, {1072, 255}, {1077, 231}, {1051, 179}, {1082, 196}, {1127, 139},
      {90, 665}, {220, 690}
    };
  }
  
  void display() 
  {
    background(255);
    image(usaMap, 0, 0, SCREENX, SCREENY);
    drawStateLabels();
    strokeWeight(0);
    backButton.display();
  }
  
  void drawStateLabels() 
  {
    textAlign(CENTER, CENTER);
    textSize(12);
    String[] stateAbbr = {
      "WA", "OR", "CA", "NV", "ID", "MT", "WY", "UT", "AZ", "CO", "NM", 
      "ND", "SD", "NE", "KS", "OK", "TX", 
      "MN", "IA", "MO", "AR", "LA", 
      "WI", "IL", "MS", "AL", 
      "MI", "IN", "OH", "KY", "TN", 
      "FL", "GA", "SC", "NC", "VA", "WV", 
      "PA", "NY", "NJ", "DE", "MD", "CT", "MA", "VT", "NH", "ME", 
      "AK", "HI"
    };
    int[][] colors = {
      {255, 34, 55}, {255, 248, 237}, {47, 49, 123}, {44, 41, 130}, {0, 173, 242}, {104, 51, 159},
      {247, 148, 29}, {192, 31, 47}, {241, 0, 142}, {10, 147, 69}, {100, 163, 120},
      {253, 175, 64}, {248, 237, 49}, {142, 198, 65}, {45, 55, 144}, {45, 55, 144}, {7, 167, 159},
      {255, 176, 63}, {234, 235, 79}, {42, 54, 154}, {34, 171, 225}, {14, 165, 150},
      {39, 32, 100}, {102, 44, 146}, {195, 181, 155}, {195, 181, 155},
      {196, 153, 108}, {138, 93, 60}, {202, 189, 181}, {138, 93, 60}, {160, 30, 102},
      {237, 27, 36}, {255, 189, 181}, {86, 50, 14}, {50, 50, 146}, {46, 48, 151}, {238, 0, 140},
      {238, 64, 53}, {255, 255, 255}, {255, 145, 142}, {246, 62, 54}, {238, 65, 58}, {158, 31, 102}, {239, 43, 125}, {255, 255, 255}, {255, 225, 255}, {213, 49, 118},
      {255, 255, 255}, {255, 255, 255}
    };
    for (int i = 0; i < states.length; i++) {
    fill(colors[i][0], colors[i][1], colors[i][2]);
    ellipse(coords[i][0], coords[i][1], 30, 20); // Draw the colored state ellipse
    fill(0);
    text(states[i], coords[i][0], coords[i][1]);
  }
}
  
  void mousePressed() 
  {
    String clickedState = getClickedState(mouseX, mouseY);
    if (clickedState != null)
    {
      flightScreen.selectedState = clickedState;
      currentScreen = flightScreen;
    }
    if (mouseX > 50 && mouseX < 150 && mouseY > 10 && mouseY < 30)
    {
      currentScreen = flightScreen;
    }
  }
  
  String getClickedState(int mx, int my) 
  {
    for (int i = 0; i < coords.length; i++)
    {
      float cx = coords[i][0];
      float cy = coords[i][1];
      float boxSize = 20; 
      if (mx > cx - boxSize/2 && mx < cx + boxSize/2 && my > cy - boxSize/2 && my < cy + boxSize/2) 
      {
        return states[i];
      }
    }
    return null;
  }
}

class ButtonWidget extends Screen 
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
    strokeWeight(0);
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

class DropdownWidget extends Screen 
{
  int x, y, w, h;
  ArrayList<String> options;
  boolean expanded = false;
  String selected;
  float scrollOffset = 0;
  float scrollSensitivity = 10;
  
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
    if (selected.equals(""))
    {
      selected = option;
    }
  }
  
  void display() 
  {
    fill(220);
    rect(x, y, w, h, 5);
    fill(0);
    text(selected, x + 10, y + h - 5);
    strokeWeight(0);
    if (expanded)
    {
      int maxDropdownHeight = SCREENY - y - h - 20;
      int totalHeight = options.size() * h;
      fill(255, 255, 255, 230);
      rect(x, y + h, w, min(totalHeight, maxDropdownHeight), 5);
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
      int maxDropdownHeight = SCREENY - y - h - 20;
      for (int i = 0; i < options.size(); i++)
      {
        float optionY = y + h + i * h - scrollOffset;
        if (mx > x && mx < x + w && my > optionY && my < optionY + h && optionY >= y + h && optionY < y + h + maxDropdownHeight)
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
      float totalHeight = options.size() * h;
      float maxDropdownHeight = SCREENY - y - h - 20;
      float maxScroll = max(0, totalHeight - maxDropdownHeight);
      scrollOffset = constrain(scrollOffset, 0, maxScroll);
    }
  }
}

class BarChartWidget extends Screen 
{
  // this makes those fancy graphs everyone loves
  // tbh the math here is pretty confusing but it works
  float animationProgress = 0;
  boolean animating = true;
  int x, y, w, h;
  HashMap<String, Integer> flightCounts;  // counts how many flights each airline has
  HashMap<String, Integer> cancelledCounts;  // keeps track of the fails lol
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
    // warning: this function is a mess but it makes pretty charts
    // just dont touch anything and it'll be fine
    fill(240);
    strokeWeight(0);
    if (animating) 
    {
      animationProgress += 0.02;  
        if (animationProgress >= 1) 
        {
         animationProgress = 1;
          animating = false;
        }
    }
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
      int diverted = divertedCounts.getOrDefault(carrier, 0);
      int fullBarHeight = int(map(flights, 0, maxFlights, 0, h - 100));
      int barHeight = int(fullBarHeight * animationProgress);  
      
      int fullCancelled = int(map(cancelled, 0, maxFlights, 0, h - 100));
      int cancelledHeight = int(fullCancelled * animationProgress);
      
      int fullDiverted = int(map(diverted, 0, maxFlights, 0, h - 100));
      int divertedHeight = int(fullDiverted * animationProgress);      
      
      fill(100, 100, 255);
      rect(startX + index * barWidth, y + h - barHeight, barWidth - 5, barHeight);
      fill(255, 100, 100);
      
      rect(startX + index * barWidth, y + h - barHeight, barWidth - 5, cancelledHeight);
      fill(100, 255, 100);
      
      rect(startX + index * barWidth, y + h - barHeight, barWidth - 5, divertedHeight);
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

class LineChartScreen extends Screen {
  ButtonWidget backButton;
  ButtonWidget nextButton;
  HashMap<String, Integer> dailyFlights = new HashMap<>();
  int maxFlights = 0;

  LineChartScreen() {
    backButton = new ButtonWidget(50, 10, 100, 30, "Back");
    nextButton = new ButtonWidget(180, 10, 150, 30, "Next Chart");

    for (TableRow row : table.rows()) {
      String date = row.getString("FL_DATE").split(" ")[0];
      dailyFlights.put(date, dailyFlights.getOrDefault(date, 0) + 1);
    }

    for (int count : dailyFlights.values()) {
      if (count > maxFlights) maxFlights = count;
    }
  }

  void display() {
    background(255);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("Flights Over Time", SCREENX / 2, 60);
    drawLineChart();
    backButton.display();
    nextButton.display();
  }

  void mousePressed() {
    if (backButton.isClicked(mouseX, mouseY)) {
      currentScreen = chartScreen;
    }
    if (nextButton.isClicked(mouseX, mouseY)) {
      currentScreen = new PieChartScreen();
    }
  }

  void drawLineChart() {
  int chartX = 100;
  int chartY = 220;
  int chartW = SCREENX - 200;
  int chartH = 300;

  ArrayList<String> sortedDates = new ArrayList<>(dailyFlights.keySet());
  sortedDates.sort((a, b) -> a.compareTo(b));

  // Axis lines (no top or right)
  stroke(0);
  strokeWeight(1);
  line(chartX, chartY, chartX, chartY + chartH); // y-axis
  line(chartX, chartY + chartH, chartX + chartW, chartY + chartH); // x-axis

  // Y-axis label
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  pushMatrix();
  translate(chartX - 50, chartY + chartH / 2);
  rotate(-HALF_PI);
  text("Number of Flights", 0, 0);
  popMatrix();

  // Y-axis numbers (ticks)
  int ySteps = 5;
  textSize(12);
  textAlign(RIGHT, CENTER);
  for (int i = 0; i <= ySteps; i++) {
    int yVal = int(map(i, 0, ySteps, 0, maxFlights));
    float yPos = chartY + chartH - map(yVal, 0, maxFlights, 0, chartH);
    stroke(200);
    line(chartX - 5, yPos, chartX, yPos);  // tick
    noStroke();
    fill(0);
    text(yVal, chartX - 10, yPos);
  }

  // Draw data line
  int pointCount = sortedDates.size();
  float spacing = chartW / (float)(pointCount - 1);

  stroke(50, 150, 255);
  strokeWeight(4);
  noFill();
  beginShape();
  for (int i = 0; i < pointCount; i++) {
    String date = sortedDates.get(i);
    int val = dailyFlights.get(date);
    float x = chartX + i * spacing;
    float y = chartY + chartH - map(val, 0, maxFlights, 0, chartH);
    vertex(x, y);
  }
  endShape();

  // X-axis labels
  fill(0);
  textSize(12);
  textAlign(CENTER);
  for (int i = 0; i < pointCount; i += max(1, pointCount / 6)) {
    String date = sortedDates.get(i);
    float x = chartX + i * spacing;
    text(date, x, chartY + chartH + 15);
  }
}
}

class PieChartScreen extends Screen {
  ButtonWidget backButton;
  float animationProgress = 0;
  boolean animating = true;
  HashMap<String, Integer> outcomeCounts = new HashMap<>();

  PieChartScreen() {
    backButton = new ButtonWidget(50, 10, 100, 30, "Back");

    int onTime = 0;
    int cancelled = 0;
    int diverted = 0;

    for (TableRow row : table.rows()) {
      int c = row.getInt("CANCELLED");
      int d = row.getInt("DIVERTED");
      if (c == 1) cancelled++;
      else if (d == 1) diverted++;
      else onTime++;
    }

    outcomeCounts.put("On Time", onTime);
    outcomeCounts.put("Cancelled", cancelled);
    outcomeCounts.put("Diverted", diverted);
  }

  void display() {
  background(255);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(30);
  text("Flight Outcome Distribution", SCREENX / 2, 60);

  if (animating) {
    animationProgress += 0.02;
    if (animationProgress >= 1) {
      animationProgress = 1;
      animating = false;
    }
  }

  drawPieChart(animationProgress);
  backButton.display();
}

  void mousePressed() {
    animationProgress = 0;
    animating = true;
    if (backButton.isClicked(mouseX, mouseY)) {
      currentScreen = new LineChartScreen();
    }
  }

  void drawPieChart(float progress) {
    int centerX = SCREENX / 2;
    int centerY = SCREENY / 2;
    float radius = 160;

    int total = 0;
    for (int count : outcomeCounts.values()) total += count;

    float angleStart = 0;
    float totalAngleDrawn = TWO_PI * progress;
    for (String label : outcomeCounts.keySet()) {
      float value = outcomeCounts.get(label);
      float angle = map(value, 0, total, 0, TWO_PI);
      if (angleStart >= totalAngleDrawn) break;
      float endAngle = min(angleStart + angle, totalAngleDrawn);

      if (label.equals("On Time")) fill(100, 200, 100);
      else if (label.equals("Cancelled")) fill(255, 100, 100);
      else fill(100, 100, 255);

      arc(centerX, centerY, radius * 2, radius * 2, angleStart, endAngle);
      angleStart += angle;
    }

    // Legend
    int legendX = centerX + 200;
    int legendY = centerY - 60;
    int boxSize = 20;

    textAlign(LEFT, CENTER);
    textSize(16);
    int i = 0;
    for (String label : outcomeCounts.keySet()) {
      int val = outcomeCounts.get(label);
      if (label.equals("On Time")) fill(100, 200, 100);
      else if (label.equals("Cancelled")) fill(255, 100, 100);
      else fill(100, 100, 255);

      rect(legendX, legendY + i * 30, boxSize, boxSize);
      fill(0);
      text(label + ": " + val, legendX + boxSize + 10, legendY + i * 30 + boxSize / 2);
      i++;
    }
  }
}
