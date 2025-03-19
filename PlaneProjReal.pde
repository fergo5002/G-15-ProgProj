Table table;
DropdownWidget dropdown;
BarChartWidget barChart; 
String selectedCarrier = "ALL"; 
int scrollOffset = 0; 
int SCREENX = 980;
int SCREENY = 980;
boolean showChart = false;
ButtonWidget chartButton;
ButtonWidget backButton;

void settings() 
{
  size(SCREENX, SCREENY);
}

void setup() 
{
  table = loadTable("flights_full.csv", "header");
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
}

void draw() 
{
  background(255); 
  
  fill(0);
  textSize(14);

  if (showChart) 
  {
    background(240);
    barChart.display();
    backButton.display();
  } else 
  {
    textAlign(LEFT); 
    text("Select Airline:", 50, 30);
    if (!dropdown.expanded) 
    {
      displayFlights();
    }
    dropdown.display();
    chartButton.display();
  }
}

void displayFlights() 
{
  text("Filtered Flights:", 50, 80);
  int yOffset = 110 - scrollOffset;
  int maxY = SCREENY - 20; 

  for (int i = 0; i < table.getRowCount(); i++) 
  {
    String carrier = table.getString(i, "MKT_CARRIER");
    if (!selectedCarrier.equals("ALL") && !carrier.equals(selectedCarrier)) continue; 

    if (yOffset > 90 && yOffset < maxY) 
    { 
      String date = table.getString(i, "FL_DATE");
      int flightNum = table.getInt(i, "MKT_CARRIER_FL_NUM");
      String origin = table.getString(i, "ORIGIN");
      String dest = table.getString(i, "DEST");
      float distance = table.getFloat(i, "DISTANCE");

      text(date + " | " + carrier + flightNum + " | " + origin + " → " + dest + " | " + distance + " miles", 50, yOffset);
    }
    yOffset += 25;
  }
}

void mousePressed() 
{
  if (showChart) 
  {
    if (backButton.isClicked(mouseX, mouseY)) 
    {
      showChart = false; 
    }
  } else 
  {
    dropdown.checkClick(mouseX, mouseY);
    if (chartButton.isClicked(mouseX, mouseY)) 
    {
      showChart = true;
    }
  }
}

class BarChartWidget 
{
  int x, y, w, h;
  HashMap<String, Integer> flightCounts;
  int maxFlights;

  BarChartWidget(int x, int y, int w, int h, Table table) 
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.flightCounts = new HashMap<>();

    for (TableRow row : table.rows()) 
    {
      String carrier = row.getString("MKT_CARRIER");
      flightCounts.put(carrier, flightCounts.getOrDefault(carrier, 0) + 1);
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
      int barHeight = int(map(flights, 0, maxFlights, 0, h - 100));

      fill(100, 100, 255);
      rect(startX + index * barWidth, y + h - barHeight, barWidth - 5, barHeight);

      fill(0);
      textSize(12);
      textAlign(CENTER);
      text(carrier, startX + index * barWidth + barWidth / 2, y + h + 20);
      text(flights, startX + index * barWidth + barWidth / 2, y + h - barHeight - 5);

      index++;
    }
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
    fill(50, 150, 50);
    rect(x, y, w, h, 5);
    fill(255);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isClicked(int mx, int my) 
  {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}
