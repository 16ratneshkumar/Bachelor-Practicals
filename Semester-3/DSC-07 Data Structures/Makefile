# Makefile for Data Structures Practical Programs

# Compiler and Flags
CXX = g++
CXXFLAGS = -Wall -std=c++11

# Target Executables
TARGETS = 1.exe 2.exe 3.1.exe 3.2.exe 4.exe 5.exe 6.1.exe 6.2.exe 6.3.exe 6.4.exe 7.exe 8.exe 9.exe 10.exe

# Default target: build all programs
all: $(TARGETS)

# Individual build rules
1.exe: 1.cpp
	$(CXX) $(CXXFLAGS) 1.cpp -o 1.exe

2.exe: 2.cpp
	$(CXX) $(CXXFLAGS) 2.cpp -o 2.exe

3.1.exe: 3.1.cpp
	$(CXX) $(CXXFLAGS) 3.1.cpp -o 3.1.exe

3.2.exe: 3.2.cpp
	$(CXX) $(CXXFLAGS) 3.2.cpp -o 3.2.exe

4.exe: 4.cpp
	$(CXX) $(CXXFLAGS) 4.cpp -o 4.exe

5.exe: 5.cpp
	$(CXX) $(CXXFLAGS) 5.cpp -o 5.exe

6.1.exe: 6.1.cpp
	$(CXX) $(CXXFLAGS) 6.1.cpp -o 6.1.exe

6.2.exe: 6.2.cpp
	$(CXX) $(CXXFLAGS) 6.2.cpp -o 6.2.exe

6.3.exe: 6.3.cpp
	$(CXX) $(CXXFLAGS) 6.3.cpp -o 6.3.exe

6.4.exe: 6.4.cpp
	$(CXX) $(CXXFLAGS) 6.4.cpp -o 6.4.exe

7.exe: 7.cpp
	$(CXX) $(CXXFLAGS) 7.cpp -o 7.exe

8.exe: 8.cpp
	$(CXX) $(CXXFLAGS) 8.cpp -o 8.exe

9.exe: 9.cpp
	$(CXX) $(CXXFLAGS) 9.cpp -o 9.exe

10.exe: 10.cpp
	$(CXX) $(CXXFLAGS) 10.cpp -o 10.exe

# Clean up build artifacts
clean:
	rm -f $(TARGETS)

# Show information about available programs
info:
	@echo "Available programs (DSC-07 Data Structures):"
	@echo "1.exe   - Singly Linked List ADT"
	@echo "2.exe   - Doubly Linked List ADT"
	@echo "3.1.exe - Circular Singly Linked List"
	@echo "3.2.exe - Circular Doubly Linked List"
	@echo "4.exe   - Stack using Array"
	@echo "5.exe   - Stack using Linked List"
	@echo "6.1.exe - Prefix Evaluation (Array Stack)"
	@echo "6.2.exe - Postfix Evaluation (Array Stack)"
	@echo "6.3.exe - Prefix Evaluation (LL Stack)"
	@echo "6.4.exe - Postfix Evaluation (LL Stack)"
	@echo "7.exe   - Queue using Circular Array"
	@echo "8.exe   - Queue using Circular Linked List"
	@echo "9.exe   - Binary Search Tree"
	@echo "10.exe  - Balanced Search Tree (AVL)"
