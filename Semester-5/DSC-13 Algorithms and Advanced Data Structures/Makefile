# Makefile for Algorithms and Advanced Data Structures Practical Programs

# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -Wall -std=c++11

# Executables
TARGETS = 1.exe 2.exe 3.exe 4.exe 5.exe 6.exe 7.exe

# Default target
all: $(TARGETS)

# Rules for each executable
1.exe: 1.cpp
	$(CXX) $(CXXFLAGS) 1.cpp -o 1.exe

2.exe: 2.cpp
	$(CXX) $(CXXFLAGS) 2.cpp -o 2.exe

3.exe: 3.cpp
	$(CXX) $(CXXFLAGS) 3.cpp -o 3.exe

4.exe: 4.cpp
	$(CXX) $(CXXFLAGS) 4.cpp -o 4.exe

5.exe: 5.cpp
	$(CXX) $(CXXFLAGS) 5.cpp -o 5.exe

6.exe: 6.cpp
	$(CXX) $(CXXFLAGS) 6.cpp -o 6.exe

7.exe: 7.cpp
	$(CXX) $(CXXFLAGS) 7.cpp -o 7.exe

# Clean up
clean:
	rm -f $(TARGETS)

# Information
info:
	@echo "Available programs:"
	@echo "1.exe - Randomized Quick Sort"
	@echo "2.exe - Randomized Select"
	@echo "3.exe - Kruskal's Algorithm"
	@echo "4.exe - Bellman Ford Algorithm"
	@echo "5.exe - B-Tree"
	@echo "6.exe - KMP Algorithm"
	@echo "7.exe - Suffix Tree"
