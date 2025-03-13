  ArrayList<Flight> flights = new ArrayList<Flight>();
  ArrayList<Flight> allFlights = new ArrayList<Flight>(); // Preserve all flights
  ArrayList<String> airports = new ArrayList<String>();
  ArrayList<String> dates = new ArrayList<String>();
  Widget airportWidget, dateWidget;
  float scrollOffset = 0;
  float airportScrollOffset = 0;
  float dateScrollOffset = 0;
  float scrollSpeed = 20;
  boolean showAirportDropdown = false;
  boolean showDateDropdown = false;
  
  void setup() 
  {
    size(800, 600);
    background(255);
    textSize(16);
    
    loadFlights("flights2k(1) (2).csv");
    println("Loaded " + flights.size() + " flights.");
    
    airportWidget = new Widget(width - 200, 20, 180, 40, "Sort by Airport");
    dateWidget = new Widget(width - 200, 70, 180, 40, "Sort by Date");
  }
  
  void draw()
  {
    background(255);
    fill(0);
    textAlign(LEFT, TOP);
    
    for (int i = 0; i < flights.size(); i++) 
    {
      Flight f = flights.get(i);
      float y = 100 + i * 30 - scrollOffset;
      if (y > 50 && y < height - 30) 
      {
        text(f.date + " | " + f.flightNumber + " | " + f.carrier + " | " + f.origin + " -> " + f.destination 
             + " | Dep: " + f.depTime + " | Arr: " + f.arrTime + " | " + f.distance + " miles", 
             50, y);
      }
    }
    
    airportWidget.display();
    dateWidget.display();
    
    if (showAirportDropdown)
    {
      airportWidget.displayDropdown(airports, airportScrollOffset);
    }
    if (showDateDropdown)
    {
      dateWidget.displayDropdown(dates, dateScrollOffset);
    }
  }
  
  void keyPressed() 
  {
    if (keyCode == UP)
    {
      scrollOffset -= scrollSpeed;
      if (scrollOffset < 0) scrollOffset = 0;
    } 
    else if (keyCode == DOWN)
    {
      scrollOffset += scrollSpeed;
      if (scrollOffset > flights.size() * 30 - height + 100)
      {
        scrollOffset = flights.size() * 30 - height + 100;
      }
    }
  }
  
  void mouseWheel(MouseEvent event)
  {
    float e = event.getCount();
    if (showAirportDropdown && mouseX > airportWidget.x && mouseX < airportWidget.x + airportWidget.w)
    {
      airportScrollOffset += e * scrollSpeed;
      airportScrollOffset = constrain(airportScrollOffset, 0, max(0, airports.size() * 30 - 150));
    }
    else if (showDateDropdown && mouseX > dateWidget.x && mouseX < dateWidget.x + dateWidget.w)
    {
      dateScrollOffset += e * scrollSpeed;
      dateScrollOffset = constrain(dateScrollOffset, 0, max(0, dates.size() * 30 - 150));
    }
    else 
    {
      scrollOffset += e * scrollSpeed;
      scrollOffset = constrain(scrollOffset, 0, max(0, flights.size() * 30 - height + 100));
    }
  }
  
  void mousePressed() {
    if (airportWidget.isClicked(mouseX, mouseY))
    {
      showAirportDropdown = !showAirportDropdown;
    }
    else if (dateWidget.isClicked(mouseX, mouseY)) 
    {
      showDateDropdown = !showDateDropdown;
    } 
    else if (showAirportDropdown) 
    {
      for (int i = 0; i < airports.size(); i++) 
      {
        float y = airportWidget.y + airportWidget.h + i * 30 - airportScrollOffset;
        if (mouseX > airportWidget.x && mouseX < airportWidget.x + airportWidget.w && 
            mouseY > y && mouseY < y + 30) 
            {
          sortFlightsByAirport(airports.get(i));
          showAirportDropdown = false;
        }
      }
    } else if (showDateDropdown) {
      for (int i = 0; i < dates.size(); i++) 
      {
        float y = dateWidget.y + dateWidget.h + i * 30 - dateScrollOffset;
        if (mouseX > dateWidget.x && mouseX < dateWidget.x + dateWidget.w && 
            mouseY > y && mouseY < y + 30)
            {
          filterFlightsByDate(dates.get(i));
          showDateDropdown = false;
        }
      }
    }
  }
  
  void loadFlights(String filename)
  {
    Table table = loadTable(filename, "header");
    
    for (TableRow row : table.rows()) 
    {
      String date = row.getString("FL_DATE");
      if (!dates.contains(date)) {
        dates.add(date);
      }
      
      String origin = row.getString("ORIGIN");
      if (!airports.contains(origin))
      {
        airports.add(origin);
      }
      
      Flight flight = new Flight(
        date, row.getString("MKT_CARRIER"),
        row.getString("MKT_CARRIER_FL_NUM"), origin,
        row.getString("DEST"), row.getString("DEP_TIME"),
        row.getString("ARR_TIME"), row.getInt("DISTANCE"));
  
      allFlights.add(flight);
    }
    flights = new ArrayList<>(allFlights);
    airports.sort(String::compareTo);
    dates.sort(String::compareTo);
  }
  
  void sortFlightsByAirport(String airport)
  {
    flights.sort((a, b) -> a.origin.equals(airport) ? -1 : (b.origin.equals(airport) ? 1 : 0));
  }
  
  void filterFlightsByDate(String date) 
  {
    flights.clear();
    for (Flight f : allFlights)
    {
      if (f.date.equals(date)) 
      {
        flights.add(f);
      }
    }
  }
  
  
  class Widget 
  {
    float x, y, w, h;
    String label;
    
    Widget(float x, float y, float w, float h, String label) 
    {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.label = label;
    }
    
    void display() 
    {
      fill(200);
      rect(x, y, w, h, 10);
      fill(0);
      textAlign(CENTER, CENTER);
      text(label, x + w / 2, y + h / 2);
    }
    
    void displayDropdown(ArrayList<String> options, float scrollOffset) {
      fill(220);
      for (int i = 0; i < options.size(); i++) {
        float yPos = y + h + i * 30 - scrollOffset;
        if (yPos > y + h - 30 && yPos < y + h + 150) {
          rect(x, yPos, w, 30);
          fill(0);
          textAlign(LEFT, CENTER);
          text(options.get(i), x + 10, yPos + 15);
          fill(220);
        }
      }
    }
    
    boolean isClicked(float mx, float my) 
    {
      return mx > x && mx < x + w && my > y && my < y + h;
    }
  }
  
  class Flight
  {
    String date;
    String carrier;
    String flightNumber;
    String origin;
    String destination;
    String depTime6558y9453;
    String arrTime45945;
    int distance;
  
    Flight(String date, String carrier, String flightNumber, String origin, 
           String destination, String depTime, String arrTime, int distance)
           {
      this.date = date;
      this.carrier = carrier;
      this.flightNumber = flightNumber;
      this.origin = origin;
      this.destination = destination;
      this.depTime = depTime;
      this.arrTime = arrTime;
      this.distance = distance;
    }
  }
