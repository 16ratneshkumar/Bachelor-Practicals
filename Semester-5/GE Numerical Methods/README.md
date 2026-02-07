# GE: Numerical Methods - Practicals

![Course](https://img.shields.io/badge/Course-GE--Numerical%20Methods-blue.svg?style=for-the-badge)

Welcome to the collection of practical assignments for the **Numerical Methods** course. This repository contains implementations for various numerical algorithms using **Wolfram Mathematica**.

---

## 🛠️ Environment Setup

This project uses **Wolfram Language** (`.nb` formats). To run these programs, you need a environment that support Wolfram Mathematica code.

**Quick Setup:**
1.  **Wolfram Mathematica:** Download and install from [wolfram.com](https://www.wolfram.com/mathematica/).
2.  **Wolfram Cloud (Free Alternative):** You can also run these notebooks online via [Wolfram Cloud](https://www.wolframcloud.com/).
3.  **Loading the File:** Open `GE Practical.nb` in Mathematica or reference the code in [GePractical.md](./GePractical.md).

---

## 📅 List of Practicals

The following methods are implemented and detailed in [GePractical.md](./GePractical.md):

### 1️⃣ Solution of Transcendental & Algebraic Equations
*   **[Bisection Method](./GePractical.md#bisection-method)** - Finding roots by repeatedly bisecting an interval (3 Variations).
*   **[Secant Method](./GePractical.md#secant-method)** - Root-finding using secant lines (2 Variations).
*   **[Regula Falsi (Regular Falsi)](./GePractical.md#regular-falsi)** - Root-finding using linear interpolation and falsi position.
*   **[Newton-Raphson Method](./GePractical.md#newton-raphson-method)** - Finding roots using tangents and automatic differentiation (2 Variations).

### 2️⃣ Solution of Linear Algebraic Equations
*   **[Gauss-Jacobi Method](./GePractical.md#jacobi-method)** - Iterative solver with support for standard and Matrix Form (`GaussJacobiMatrixForm`).
*   **[Gauss-Seidel Method](./GePractical.md#gauss-seidel-method)** - Improved iterative solver with standard and Matrix Form (`GaussSeidelMatrixForm`).

### 3️⃣ Interpolation
*   **[Lagrange Interpolation](./GePractical.md#lagrange-interpolation)** - Polynomial interpolation with support for plotting and comparison with built-in functions.
*   **[Newton's Divided Difference](./GePractical.md#newton-interpolation)** - Implementation of Divided Difference tables and Polynomial construction (NDD/NDDP).

### 4️⃣ Numerical Integration
*   **[Trapezoidal Rule](./GePractical.md#trapezoidal-rule-method)** - Composite Trapezoidal rule with error verification against true integrals.
*   **[Simpson's Rule](./GePractical.md#simpsons-rule)** - Composite Simpson's 1/3rd rule with input validation for even sub-intervals.

### 5️⃣ Numerical Solution of Ordinary Differential Equations
*   **[Euler's Method](./GePractical.md#euler-method)** - Solving ODEs using fixed number of steps or fixed step size `h`.
*   **[2nd Order Runge-Kutta (Modified Euler)](./GePractical.md#2nd-order-runge-kutta-method)** - More accurate ODE solver with built-in comparison to exact solutions.

---
<p align="right">
  <i>Developed with ❤️ by <a href="https://github.com/16ratneshkumar">16ratneshkumar</a></i>
</p>
