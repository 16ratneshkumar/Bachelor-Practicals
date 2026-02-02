'''Define a class Employee that stores information about employees in the company. The class should contain the following:
    1. data members- count (to keep a record of all the objects being created for this class) and for every employee: an employee number, Name, Dept, Basic, DA and HRA.
    2. function members:
            1. init method to initialize and/or update the members. Add statements to ensure that the program is terminated if any of Basic, DA and HRA is set to a negative value.
            2. function salary, that returns salary as the sum of Basic, DA and HRA.
            3. del function to decrease the number of objects created for the class.
            4. __str __ function to display the details of an employee along with the salary of an employee in a proper format.'''

class Employee:
    count = 0 

    def __init__(self, emp_no, name, dept, basic, da, hra):
        if basic < 0 or da < 0 or hra < 0:
            print("Error: Basic, DA, and HRA cannot be negative.")
            raise ValueError("Basic, DA, and HRA cannot be negative.")
        
        self.emp_no = emp_no
        self.name = name
        self.dept = dept
        self.basic = basic
        self.da = da
        self.hra = hra
        Employee.count += 1

    def salary(self):
        return self.basic + self.da + self.hra

    def __del__(self):
        Employee.count -= 1

    def __str__(self):
        return (f"Employee Number: {self.emp_no}\n"
                f"Name           : {self.name}\n"
                f"Department     : {self.dept}\n"
                f"Salary         : {self.salary():.2f}")
    
    def setName(self, name):
        self.name = name
    
    def setDept(self, dept):
        self.dept = dept
    
    def setBasic(self, basic):
        self.basic = basic
    
    def setDA(self, da):
        self.da = da
    
    def setHRA(self, hra):
        self.hra = hra


if __name__ == "__main__":
    print(f"Initial Employee Count: {Employee.count}")
    
    e1 = Employee(101, "Alice", "HR", 50000, 5000, 10000)
    print("\nEmployee 1 Details:")
    print(e1)
    print(f"Current Employee Count: {Employee.count}")

    e1.setName("Alicia")
    e1.setDept("Marketing")
    e1.setBasic(55000)
    e1.setDA(5500)
    e1.setHRA(11000)
    print("\nUpdated Employee 1 Details:")
    print(e1)
    
    e2 = Employee(102, "Bob", "IT", 60000, 6000, 12000)
    print("\nEmployee 2 Details:")
    print(e2)
    print(f"Current Employee Count: {Employee.count}")
    
    del e1
    print(f"\nEmployee Count after deleting e1: {Employee.count}")
    
    e3 = Employee(103, "Charlie", "Sales", -100, 100, 100)
