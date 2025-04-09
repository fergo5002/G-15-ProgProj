Table table;
DropdownWidget dropdown;
String selectedCarrier = "ALL"; 
int scrollOffset = 0; 

void setup() 
{
  size(600, 500);
  table = loadTable("flights2k(1).csv", "header");

  dropdown = new DropdownWidget(140, 10, 150, 25);
  dropdown.addOption("ALL");
  
  for (TableRow row : table.rows()) {
    String carrier = row.getString("MKT_CARRIER");
    if (!dropdown.options.contains(carrier)) 
    {
      dropdown.addOption(carrier);
    }
  }
}

void draw() 
{
  background(255);
  fill(0);
  textSize(14);

  text("Select Airline:", 50, 30);

  if (!dropdown.expanded) 
  {
    displayFlights();
  }
  
  dropdown.display(); 
}

void displayFlights() 
{
  text("Filtered Flights:", 50, 80);
  int yOffset = 110 - scrollOffset;

  for (int i = 0; i < table.getRowCount(); i++) 
  {
    String carrier = table.getString(i, "MKT_CARRIER");
    if (!selectedCarrier.equals("ALL") && !carrier.equals(selectedCarrier)) continue; 

    if (yOffset > 90 && yOffset < height - 20) { // Ensure visible rows
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
println("poo") 

void mousePressed() 
{
  dropdown.checkClick(mouseX, mouseY);
}

void mouseWheel(MouseEvent event) 
{
  scrollOffset += event.getCount() * 10;
  scrollOffset = constrain(scrollOffset, 0, table.getRowCount() * 25 - height + 150);
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
      rect(x, y + h, w, options.size() * h, 5); 
      
      for (int i = 0; i < options.size(); i++) 
      {
        fill(240);
        rect(x, y + (i + 1) * h, w, h, 5);
        fill(0);
        text(options.get(i), x + 10, y + (i + 2) * h - 5);
      }
    }
  }

  void planeFinder()
  {
   //poop poop poop
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
