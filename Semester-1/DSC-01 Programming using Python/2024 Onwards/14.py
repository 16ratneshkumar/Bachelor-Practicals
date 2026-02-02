# Inherit the above class to create a "3Dpoint" with additional attribute z. Override the method defined in "2DPoint" class , to calculate distance between two points of the "3DPoint" class.

class TwoDPoint:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __str__(self):
        return f"Coordinates of the point ({self.x}, {self.y})."

    def Calculate_Distance(self, other):
        dx = self.x - other.x
        dy = self.y - other.y
        distance = (dx**2 + dy**2)**0.5
        return distance

class ThreeDPoint(TwoDPoint):
    def __init__(self, x, y, z):
        super().__init__(x, y)
        self.z = z

    def __str__(self):
        return f"Coordinates of the point ({self.x}, {self.y}, {self.z})."

    def Calculate_Distance(self, other):
        dxy = super().Calculate_Distance(other)
        dz = self.z - other.z
        distance = (dxy**2 + dz**2)**0.5
        return distance

if __name__ == "__main__":
    choice = 'y'
    while choice == 'y':
        print("\nEnter 1st Co-ordinates: ")
        p1 = ThreeDPoint(int(input("Enter value at x-axis: ")), 
                         int(input("Enter value at y-axis: ")), 
                         int(input("Enter value at z-axis: ")))
        
        print("\nEnter 2nd Co-ordinates: ")
        p2 = ThreeDPoint(int(input("Enter value at x-axis: ")), 
                         int(input("Enter value at y-axis: ")), 
                         int(input("Enter value at z-axis: ")))
        
        print(f"\nPoint 1: {p1}")
        print(f"Point 2: {p2}")
        print(f"Distance between them: {p1.Calculate_Distance(p2):.4f}")
        
        choice = input("\nDo you want to use again (y/n): ").lower()
    
    print("Thank you for using my program")