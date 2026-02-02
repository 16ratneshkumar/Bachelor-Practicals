# DSC-09: Computer Graphics - Practicals

[![Course](hthttps://github.com/16ratneshkumar/Miscellaneoustps://img.shields.io/badge/Course-DSC--09-blue.svg?style=for-the-badge)](https://www.du.ac.in/)

Welcome to the collection of practical assignments for the **Computer Graphics** course. This repository contains implementations for various Computer Graphics algorithms using C++.

---

## 🛠️ Library Setup

This project uses `graphics.h` (Borland Graphics Interface). To run these programs in Visual Studio Code, you need to set up MinGW and the necessary graphics libraries.

**Quick Setup:**
1.  Install MinGW.
2.  Copy `graphics.h` and `winbgim.h` to `include` folder.
3.  Copy `libbgi.a` to `lib` folder.
4.  Link with `-lbgi -lgdi32 -lcomdlg32 -luuid -loleaut32 -lole32`.

👉 **[Click here for detailed Setup Instructions](./Library%20Setup/README.md)**

---

## 📅 List of Practical

1.  [Write a program to implement Bresenham’s line drawing algorithm.](./1.%20Bresenham's%20Line%20Drawing%20Algorithm.cpp)
2.  [Write a program to implement mid-point circle drawing algorithm.](./2.%20Midpoint%20Circle%20Drawing%20Algorithm.cpp)
3.  [Write a program to clip a line using Cohen and Sutherland line clipping algorithm.](./3.%20Cohen%20And%20Sutherland%20Line%20Clipping%20Algorithm.cpp)
4.  [Write a program to clip a polygon using Sutherland Hodgeman algorithm.](./4.%20Sutherland%20Hodgemann%20Algorithm.cpp)
5.  [Write a program to fill a polygon using Scan line fill algorithm.](./5.%20Scan%20Line%20Fill%20Algorithm.cpp)
6.  [Write a program to apply various 2D transformations on a 2D object (use homogenous Coordinates).](./6.%202D%20Transformations%20On%20A%202D%20Object.cpp)
7.  [Write a program to apply various 3D transformations on a 3D object and then apply parallel and perspective projection on it.](./7.%203D%20Transformations%20On%20A%203D%20Object.cpp)
8.  Write a program to draw these curve:
    1.  [Bezier curve.](./8.1.%20Bezier%20Curve.cpp)
    2.  [Hermite curve.](./8.2.%20Hermite%20Curve.cpp)
9.  [Write a program to implement Digital Differential Analyzer (DDA) Algorithm.](./Digital%20Differential%20Analyzer(DDA)%20Algorithm.cpp)

---
<p align="right">
  <i>Developed with ❤️ by <a href="https://github.com/16ratneshkumar">16ratneshkumar</a></i>
</p>