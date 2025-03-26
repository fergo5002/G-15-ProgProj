// -------------------------------------
// Global variables and assets
// -------------------------------------
Table table;
BarChartWidget barChart;
PImage plane;

Screen currentScreen;
HomeScreen homeScreen;
FlightScreen flightScreen;
ChartScreen chartScreen;

boolean showCancelled = true;

int SCREENX = 980;
int SCREENY = 980;

// New global font variable
PFont sitkaFont;

// -------------------------------------
// Setup and draw
// -------------------------------------
void settings()
{
    size(SCREENX, SCREENY);
    plane = loadImage("plane-photo(1).jpg");
    plane.resize(SCREENX, SCREENY);
}

void setup()
{
    sitkaFont = loadFont("SitkaText-18.vlw");
    
    table = loadTable("flights.csv", "header");
    barChart = new BarChartWidget(100, 100, SCREENX - 200, SCREENY - 300, table);
  
    homeScreen = new HomeScreen();
    flightScreen = new FlightScreen();
    chartScreen = new ChartScreen();
    
    // Start on the home screen
    currentScreen = homeScreen;
}

void draw()
{
    currentScreen.display();
}

// -------------------------------------
// Mouse events
// -------------------------------------
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

// -------------------------------------
// Screen base class
// -------------------------------------
abstract class Screen
{
    void display() {}
    void mousePressed() {}
    void mouseDragged() {}
    void mouseWheel(MouseEvent event) {}
}

// -------------------------------------
// Home Screen
// -------------------------------------
class HomeScreen extends Screen
{
    ButtonWidget startButton;
    
    HomeScreen()
    {
        startButton = new ButtonWidget(SCREENX / 2 - 100, SCREENY / 2 + 50, 200, 50, "Start FlyRadar");
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
        text("FlyRadar", SCREENX / 2, SCREENY / 2 - 100);
        
        textSize(24);
        text("Flight Data Visualization Tool", SCREENX / 2, SCREENY / 2 - 40);
        
        startButton.display();
        
        float pulseValue = 128 + 127 * sin(frameCount * 0.05);
        fill(pulseValue);
        textSize(18);
        text("Click Start to Explore Flight Data", SCREENX / 2, SCREENY / 2 + 150);
    }
    
    void mousePressed()
    {
        if (startButton.isClicked(mouseX, mouseY))
        {
            currentScreen = flightScreen;
        }
    }
}

// -------------------------------------
// Flight Screen (with SitkaText-18 + color-coded text)
// -------------------------------------
class FlightScreen extends Screen
{
    DropdownWidget dropdown;
    ButtonWidget chartButton;
    ButtonWidget cancelFilterButton;
    
    float scrollOffset = 0;
    float targetScrollOffset = 0;
    float scrollVelocity = 0;
    float scrollFriction = 0.9;   // how quickly scrolling stops
    float scrollSensitivity = 15; // responsiveness
    
    FlightScreen()
    {
        dropdown = new DropdownWidget(140, 10, 150, 25);
        dropdown.addOption("ALL");
        
        // Add carriers from the CSV
        for (TableRow row : table.rows())
        {
            String carrier = row.getString("MKT_CARRIER");
            if (!dropdown.options.contains(carrier))
            {
                dropdown.addOption(carrier);
            }
        }
        
        chartButton = new ButtonWidget(700, 10, 200, 30, "View Chart");
        cancelFilterButton = new ButtonWidget(450, 10, 200, 30, "Hide Cancelled");
    }
    
    void display()
    {
        // Use the custom SitkaText-18 font on this screen
        textFont(sitkaFont);

        background(240);
        
        fill(0);
        textSize(14);
        textAlign(LEFT);
        text("Select Airline:", 50, 30);
        
        // Apply scrolling physics
        targetScrollOffset += scrollVelocity;
        scrollVelocity *= scrollFriction;
        if (abs(scrollVelocity) < 0.1)
        {
            scrollVelocity = 0;
        }
        
        // Calculate max scroll limit based on filtered rows
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
        
        // Bounce effect at scroll boundaries
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
        
        // Smoothly approach target scroll offset
        float scrollDifference = targetScrollOffset - scrollOffset;
        scrollOffset += scrollDifference * 0.3;
        if (abs(scrollDifference) < 0.1 && abs(scrollVelocity) < 0.1)
        {
            scrollOffset = targetScrollOffset;
        }
        
        // Display flights
        displayFlights();
        
        // Display dropdown & buttons
        dropdown.display();
        chartButton.display();
        cancelFilterButton.display();
        
        fill(100);
        textSize(12);
        textAlign(RIGHT);
        text(
            "Showing " + (showCancelled ? "all flights" : "only non-cancelled flights"),
            cancelFilterButton.x - 10,
            cancelFilterButton.y + 20
        );
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
            if (!dropdown.selected.equals("ALL") && !carrier.equals(dropdown.selected)) continue;
            if (!showCancelled && cancelled == 1) continue;
            
            totalFilteredRows++;
            
            if (totalFilteredRows >= startIndex && processedRows < visibleRows)
            {
                if (yOffset > 90 && yOffset < maxY)
                {
                    // Gather data
                    String date      = row.getString("FL_DATE");
                    int flightNum    = row.getInt("MKT_CARRIER_FL_NUM");
                    String origin    = row.getString("ORIGIN");
                    String dest      = row.getString("DEST");
                    float distance   = row.getFloat("DISTANCE");
                    
                    // Build the flight info in parts
                    String datePart    = date + " | ";
                    String carrierPart = carrier + flightNum + " | ";
                    String routePart   = origin + " -> " + dest + " | ";
                    String distPart    = distance + " miles";
                    
                    // Draw each part in a different color
                    float xPos = 50;
                    
                    // Date in teal
                    fill(0, 128, 128);
                    text(datePart, xPos, yOffset);
                    xPos += textWidth(datePart);
                    
                    // Carrier in purple
                    fill(128, 0, 128);
                    text(carrierPart, xPos, yOffset);
                    xPos += textWidth(carrierPart);
                    
                    // Route in dark blue
                    fill(0, 0, 150);
                    text(routePart, xPos, yOffset);
                    xPos += textWidth(routePart);
                    
                    // Distance in dark green
                    fill(0, 100, 0);
                    text(distPart, xPos, yOffset);
                    xPos += textWidth(distPart);
                    
                    // If flight is cancelled, append a red note
                    if (cancelled == 1)
                    {
                        fill(255, 0, 0);
                        String cancelledNote = " [CANCELLED]";
                        text(cancelledNote, xPos, yOffset);
                    }
                    
                    processedRows++;
                }
            }
            yOffset += rowHeight;
        }
        
        // Draw scrollbar
        drawScrollIndicator(totalFilteredRows, rowHeight);
        
        fill(100);
        textSize(12);
        text("Use mouse wheel to scroll", SCREENX - 200, SCREENY - 20);
    }
    
    void drawScrollIndicator(int totalRows, int rowHeight)
    {
        int totalHeight = totalRows * rowHeight;
        if (totalHeight <= SCREENY - 130) return;
        
        int scrollbarHeight = (SCREENY - 130) * (SCREENY - 130) / totalHeight;
        scrollbarHeight = max(30, scrollbarHeight);
        
        int scrollbarY = 110 + (int)(
            scrollOffset * (SCREENY - 130 - scrollbarHeight)
            / (totalHeight - (SCREENY - 130))
        );
        scrollbarY = constrain(scrollbarY, 110, SCREENY - scrollbarHeight - 20);
        
        fill(200, 200, 200, 150);
        rect(SCREENX - 20, 110, 10, SCREENY - 130);
        
        fill(100, 100, 100, 200);
        rect(SCREENX - 20, scrollbarY, 10, scrollbarHeight, 5);
    }
    
    void mousePressed()
    {
        dropdown.checkClick(mouseX, mouseY);
        
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
        
        // Check if clicking on scrollbar
        if (mouseX > SCREENX - 25 && mouseX < SCREENX - 10 && mouseY > 110 && mouseY < SCREENY - 20)
        {
            handleScrollbarDrag();
        }
    }
    
    void mouseDragged()
    {
        // Dragging the scrollbar
        if (mouseX > SCREENX - 25 && mouseX < SCREENX - 10 && mouseY > 110 && mouseY < SCREENY - 20)
        {
            handleScrollbarDrag();
            scrollVelocity = 0;
        }
    }
    
    void mouseWheel(MouseEvent event)
    {
        // Only scroll if the dropdown is not expanded
        if (!dropdown.expanded)
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
            
            if ((dropdown.selected.equals("ALL") || carrier.equals(dropdown.selected))
                && (showCancelled || cancelled == 0))
            {
                totalFilteredRows++;
            }
        }
        
        int totalHeight = totalFilteredRows * 25;
        int maxScroll = totalHeight - (SCREENY - 130);
        if (maxScroll < 0) maxScroll = 0;
        
        float scrollRatio = constrain(
            (mouseY - 110) / (float)(SCREENY - 130 - 30),
            0,
            1
        );
        targetScrollOffset = scrollRatio * maxScroll;
    }
}

// -------------------------------------
// Chart Screen
// -------------------------------------
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

// -------------------------------------
// ButtonWidget
// -------------------------------------
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
        // Simple color assignment
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

// -------------------------------------
// DropdownWidget
// -------------------------------------
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
        }
        else if (expanded)
        {
            for (int i = 0; i < options.size(); i++)
            {
                int top = y + (i + 1) * h;
                int bottom = y + (i + 2) * h;
                
                if (mx > x && mx < x + w && my > top && my < bottom)
                {
                    selected = options.get(i);
                    expanded = false;
                    
                    // Reset scroll in FlightScreen
                    flightScreen.scrollOffset = 0;
                    flightScreen.targetScrollOffset = 0;
                    flightScreen.scrollVelocity = 0;
                }
            }
        }
    }
}

// -------------------------------------
// BarChartWidget
// -------------------------------------
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
        flightCounts = new HashMap<>();
        cancelledCounts = new HashMap<>();
        
        for (TableRow row : table.rows())
        {
            String carrier = row.getString("MKT_CARRIER");
            int cancelled = row.getInt("CANCELLED");
            
            flightCounts.put(carrier, flightCounts.getOrDefault(carrier, 0) + 1);
            if (cancelled == 1)
            {
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
            
            if (cancelled > 0)
            {
                fill(255, 0, 0);
                text("(" + cancelled + " canc.)",
                     startX + index * barWidth + barWidth / 2,
                     y + h - barHeight - 20);
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
