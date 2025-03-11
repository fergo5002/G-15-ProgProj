Ball[] balls; // Declare the array
void setup() 
{
size(400, 400);
balls = new Ball[5]; // Create an array with 5 slots

// Fill the array with Ball objects
for (int i = 0; 
    i < balls.length; 
    i++) 
{
balls[i] = new Ball(random(width), random(height));
}
}

void draw() 
{
background(1);
for (int i = 0; i < balls.length; i++) 
{
balls[i].display();
}
}


class Ball 
{
float x, y;
Ball(float x, float y) 
{
this.x = x; this.y = y;
}


void display()
{
ellipse(x, y, 20, 20);
}
}







float x, y;
float speedX = 3;
float angle = 0;
float rotationSpeed = 0.05;
//void setup() {
// size(800, 600);
// x = 0 ;
//y = height / 2;
//}
//void draw() {
// background(0);
// x += speedX;
// if (x > width || x < 0) {
// speedX *= -1;
// }
// angle += rotationSpeed;
// pushMatrix();
// translate(x, y);
// rotate(angle);
// fill(255, 0, 0);
// rectMode(CENTER);
// rect(0, 0, 100, 50);
// popMatrix();
//}
