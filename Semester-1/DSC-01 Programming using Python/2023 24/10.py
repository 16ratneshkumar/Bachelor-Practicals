# Write A Program to define a class 2DPoint with coordinates x and y as attributes. Create relevant methods and print the objects. Also define a method distance to calculate the distance between any two point objects.
class TwoDPoint:
    def __init__(self,x,y):
        self.x=x
        self.y=y
    def __str__(self):
        return f"Coordinates of the point ({self.x},{self.y})."
    def Calculate_Distance(self,other):
        dx=self.x-other.x
        dy=self.y-other.y
        distance=(dx**2+dy**2)**0.5
        return distance
choice='y'
while choice=='y':
    print("Enter 1st Co-ordinates: ")
    p1 = TwoDPoint(int(input("Enter value at x-axis: ")), int(input("Enter value at y-axis: ")))
    print("Enter 2nd Co-ordinates: ")
    p2 = TwoDPoint(int(input("Enter value at x-axis: ")), int(input("Enter value at y-axis: ")))
    print(p1)
    print(p2)
    print(p1.Calculate_Distance(p2))
    choice=input("Do you want to use again(y/n):").lower()
print("Thank you for using my program")
