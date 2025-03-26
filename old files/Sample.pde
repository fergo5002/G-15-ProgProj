
Table table;

void setup() {
  size(600, 400); // Set window size
  table = loadTable("flights2k(1).csv", "header"); 

  println("Flight Data (First 10 rows):");
  for (int i = 0; i < min(10, table.getRowCount()); i++) 
  { 
    String date = table.getString(i, "FL_DATE");
    String carrier = table.getString(i, "MKT_CARRIER");
    int flightNum = table.getInt(i, "MKT_CARRIER_FL_NUM");
    String origin = table.getString(i, "ORIGIN");
    String dest = table.getString(i, "DEST");
    float distance = table.getFloat(i, "DISTANCE");

    println(date + " | " + carrier + flightNum + " | " + origin + " → " + dest + " | " + distance + " miles");
  }
}

void draw() {
  background(255);
  fill(0);
  textSize(14);
  
  text("Flight Data:", 50, 40);
  int yOffset = 70;

  for (int i = 0; i < min(10, table.getRowCount()); i++) { // Show first 10 rows
    String date = table.getString(i, "FL_DATE");
    String carrier = table.getString(i, "MKT_CARRIER");
    int flightNum = table.getInt(i, "MKT_CARRIER_FL_NUM");
    String origin = table.getString(i, "ORIGIN");
    String dest = table.getString(i, "DEST");
    float distance = table.getFloat(i, "DISTANCE");

    text(date + " | " + carrier + flightNum + " | " + origin + " → " + dest + " | " + distance + " miles", 50, yOffset);
    yOffset += 30; // Move text down for next row
  }
}
