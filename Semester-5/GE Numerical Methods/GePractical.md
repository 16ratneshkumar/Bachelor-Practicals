## Bisection Method
### Question 1:
```matlab
x0 = 0;
x1 = 2.0;
Nmax = 20;
eps = 0.0001;
f[x_] := Cos[x];
If[N[f[x0]* f[x1]]>0,
	Print["Your values do not satisfy the IVP, so change the value."],
For [i=1, i <= Nmax, i++, 
	m =(x0 + x1)/2;
	If[Abs[(x1-x0)/2]< eps, Return[m],
		Print[i,"th iteration value is :",m];
		Print["Estimated error in ",i," th iteration is : ",(x1 - x0)/2];
	If[f[m]* f[x1] > 0, x1 = m, x0 = m]]];
	Print["Root is: ",m]
	Print["Estimated error in", i," th iteration is : ",(x1 - x0)/2]]
	Plot[f[x],{x,-1,3},
	PlotRange -> {-1,1},
	PlotStyle -> {Red, Thick}, 
	PlotLabel -> "f[x] = "f [x], 
	AxesLabel -> {x,f[x]}]
```

### Question 2
```matlab
x0 = 0;
x1 = 2.0;
Nmax = 20;
eps = 0.00001;
f[x_] := Cos[x]-x(E^x);
If[N[f[x0]* f[x1]]>0,
	Print["Your values do not satisfy the IVP, so change the value."],
For [i=1, i <= Nmax, i++, 
	m =(x0 + x1)/2;
	If[Abs[(x1-x0)/2]< eps, Return[m],
		Print[i,"th iteration value is :",m];
		Print["Estimated error in ",i," th iteration is : ",(x1 - x0)/2];
	If[f[m]* f[x1] > 0, x1 = m, x0 = m]]];
	Print["Root is: ",m]
	Print["Estimated error in", i," th iteration is : ",(x1 - x0)/2]]
	Plot[f[x],{x,-1,3},
	PlotRange -> {-10,10},
	PlotStyle -> {Green, Thick}, 
	PlotLabel -> "f[x] = "f [x], 
	AxesLabel -> {x,f[x]}]
```


### Question 3
```matlab
x0 = Input["Enter first guess"];
x1 = Input["Enter Second guess"];
Nmax = Input["Enter Nmax guess"];
eps = Input["Enter approx error"];
f[x_] := Cos[x]-x(E^x);
If[N[f[x0]* f[x1]]>0,
	Print["Your values do not satisfy the IVP, so change the value."],
For [i=1, i <= Nmax, i++, 
	m =(x0 + x1)/2;
	If[Abs[(x1-x0)/2]< eps, Return[m],
		Print[i,"th iteration value is :",m];
		Print["Estimated error in ",i," th iteration is : ",(x1 - x0)/2];
	If[f[m]* f[x1] > 0, x1 = m, x0 = m]]];
	Print["Root is: ",m]
	Print["Estimated error in", i," th iteration is : ",(x1 - x0)/2]]
	Plot[f[x],{x,-1,3},
	PlotRange -> {-1,1},
	PlotStyle -> {Red, Thick}, 
	PlotLabel -> "f[x] = "f [x], 
	AxesLabel -> {x,f[x]}]
```

## Secant Method
### Question 1
```matlab
(*x0 = Input["Enter first guess"];
x1 = Input["Enter Second guess"];
Nmax = Input["Enter Nmax guess"];
eps = Input["Enter approx error"];
f[x_] = Input["Enter Function error"];*)
x0 = 0;
x1 = 1.0;
Nmax = 20;
eps = 0.00001;
f[x_] := Cos[x];
For [i=1, i <= Nmax, i++,  
	x2 =x1-((f[x1]*(x1 - x0))/(f[x1]- f[x0]));
	If[Abs[(x1-x2)]/2 < eps, Return[x2],x0=x1;x1=x2];
		Print[i,"th iteration value is :",x2];
		Print["Estimated error in ",i," th iteration is : ",Abs[x1 - x0]]];
	Print["Root is :",x2];
	Print["Estimated error in ",Abs[x2 - x1]];
	Plot[f[x],{x,-1,3},
	PlotRange -> {-2,2},
	PlotStyle -> {Red, Thick}, 
	PlotLabel -> "f[x] = "f [x], 
	AxesLabel -> {x,f[x]}]
```

### Question 2

```matlab
x0 = 0;
x1 = 1.0;
Nmax = 20;
eps = 0.0001;
f[x_] := Cos[x]-x(E^x);
For [i=1, i <= Nmax, i++,  
	x2 =x1-((f[x1]*(x1 - x0))/(f[x1]- f[x0]));
	If[Abs[(x1-x2)]/2 < eps, Return[x2],x0=x1;x1=x2];
		Print[i,"th iteration value is :",x2];
		Print["Estimated error in ",i," th iteration is : ",Abs[x1 - x0]]];
	Print["Root is :",x2];
	Print["Estimated error in ",Abs[x2 - x1]];
	Plot[f[x],{x,-1,3},
	PlotRange -> {-2,2},
	PlotStyle -> {Red, Thick}, 
	PlotLabel -> "f[x] = "f [x], 
	AxesLabel -> {x,f[x]}]
```

## Regular Falsi
### Question 1
```matlab
x0 = 0;
x1 = 2.0;
Nmax = 20;
eps = 0.0001;
f[x_] := Cos[x];
If[N[f[x0]]*N[f[x1]]> 0,
	Print["These values do not satisfy the IVP so change the value."],
	For [i=1, i <= Nmax, i++,  
		x2 = N[x1-f[x1]*(x1 - x0)/(f[x1]- f[x0])];
		If [Abs[x1-x0]<eps,Return[N[x2]],
			Print[i,"th iterations value is: ", N[x2]];
			Print["Estimated error in ",i," th iteration is : ",N[x1 - x0]]];
	If[f[x2]*f[x1]>0,x1=x2,x0=x2]];
		Print["Root is :",N[x2]];
		Print["Estimated error in ",i," th iteration is : ",N[x1 - x0]]];
		If[N[f[x0]]*N[f[x1]]< 0,Plot[f[x],{x,-1,3}]]	
```

## Newton-Raphson Method
### Question 1
```matlab
x0 = 1;
Nmax = 20;
eps = 0.0001;
f[x_] := Cos[x];
For [i=1, i <= Nmax, i++,  
	x1 = N[x0-(f[x]/.x-> x0)/(D[f[x],x]/.x-> x0)];
	If [Abs[x1-x0]< eps, Return[x1],x0p=x0;x0=x1];
	Print["In ",i,"th Number of iterations the approximation to root is:", x1];
	Print["Estimated error in ",Abs[x1 - x0p]]];
Print["The Final approximation of root is:", x1];
Print["Estimated error in ",Abs[x1 - x0]];
Plot[f[x],{x,-1,3}]
```

### Question 2
```matlab
x0 = 0.5;
Nmax = 20;
eps = 0.0001;
f[x_] := x^3-5*x+1;
For [i=1, i <= Nmax, i++,  
	x1 = N[x0-(f[x]/.x-> x0)/(D[f[x],x]/.x-> x0)];
	If [Abs[x1-x0]< eps, Return[x1],x0p=x0;x0=x1];
	Print["In ",i,"th Number of iterations the approximation to root is:", x1];
	Print["Estimated error in ",Abs[x1 - x0p]]];
Print["The Final approximation of root is:", x1];
Print["Estimated error in ",Abs[x1 - x0]];
Plot[f[x],{x,-1,3}]
```

## Jacobi Method
### Question 1
```matlab
GaussJacobi[A0_, b0_, x0_, maxiter_] := 
 Module[{A = N[A0], b = N[b0], xk = x0, xk1, i, j, k = 0, n, m, 
   OutputDetails},
  
  size = Dimensions[A];
  n = size[[1]];
  m = size[[2]];
  
  If[n != m, 
   Print["Not a square matrix, cannot proceed with Gauss-Jacobi method"];
   Return[]
   ];
  
  OutputDetails = {xk};
  xk1 = Table[0, {n}];
  
  While[k < maxiter,
   For[i = 1, i <= n, i++,
    xk1[[i]] = (1/A[[i, i]])*(b[[i]] - 
        Sum[A[[i, j]]*xk[[j]], {j, 1, i - 1}] - 
        Sum[A[[i, j]]*xk[[j]], {j, i + 1, n}])
    ];
   k++;
   OutputDetails = Append[OutputDetails, xk1];
   xk = xk1;
   ];
  
  colHeading = Table[X[s], {s, 1, n}];
  Print[NumberForm[
    TableForm[OutputDetails, 
     TableHeadings -> {None, colHeading}], 6]];
  Print["No. of iterations performed: ", maxiter];
  ];
A = {{5, 1, 2}, {-3, 9, 4}, {1, 2, -7}};
b = {10, -14, -33};
X0 = {0, 0, 0};
GaussJacobi[A, b, X0, 15]
```

### Question 2
```matlab
GaussJacobi[A0_, b0_, x0_, maxiter_] := 
 Module[{A = N[A0], b = N[b0], xk = x0, xk1, i, j, k = 0, n, m, 
   OutputDetails},
  
  size = Dimensions[A];
  n = size[[1]];
  m = size[[2]];
  
  If[n != m, 
   Print["Not a square matrix, cannot proceed with Gauss-Jacobi method"];
   Return[]
   ];
  
  OutputDetails = {xk};
  xk1 = Table[0, {n}];
  
  While[k < maxiter,
   For[i = 1, i <= n, i++,
    xk1[[i]] = (1/A[[i, i]])*(b[[i]] - 
        Sum[A[[i, j]]*xk[[j]], {j, 1, i - 1}] - 
        Sum[A[[i, j]]*xk[[j]], {j, i + 1, n}])
    ];
   k++;
   OutputDetails = Append[OutputDetails, xk1];
   xk = xk1;
   ];
  
  colHeading = Table[X[s], {s, 1, n}];
  Print[NumberForm[
    TableForm[OutputDetails, 
     TableHeadings -> {None, colHeading}], 6]];
  Print["No. of iterations performed: ", maxiter];
  ];
A = {{4, 1, 1}, {1, 5, 2}, {1, 2, 3}};
b = {2, -6, -4};
X0 = {0.5, -0.5, -0.5};
GaussJacobi[A, b, X0, 15]
```
### Question 3
```matlab
GaussJacobiMatrixForm[A0_, b0_, x0_, maxiter_] := 
  Module[{A = N[A0], b = N[b0], xk = x0, k = 0, D, R, Dinv, 
    OutputDetails}, D = DiagonalMatrix[Diagonal[A]]; R = A - D; 
   Dinv = Inverse[D]; OutputDetails = {xk}; 
   While[k < maxiter, xk = Dinv.(b - R.xk); 
    OutputDetails = Append[OutputDetails, xk];
    k++;];
   colHeading = Table[Subscript[x, s], {s, 1, Length[x0]}];
   Print[NumberForm[
     TableForm[OutputDetails, TableHeadings -> {None, colHeading}], 
     6]];
   Print["No. of iterations performed: ", maxiter];];
A = {{5, 1, 2}, {-3, 9, 4}, {1, 2, -7}};
b = {10, -14, -33};
X0 = {0, 0, 0};

GaussJacobiMatrixForm[A, b, X0, 15]
```

## Gauss Seidel Method
### Question 1
```matlab
GaussSeidel[A0_, b0_, x0_, maxiter_] := 
  Module[{A = N[A0], b = N[b0], xk = x0, xk1, i, j, k = 0, n, m, 
    OutputDetails, size, colHeading}, size = Dimensions[A];
   n = size[[1]];
   m = size[[2]];
   If[n != m, 
    Print["Not a square matrix, cannot proceed with Gauss-Seidel \
method"];
    Return[]];
   OutputDetails = {xk};
   xk1 = Table[0, {n}]; 
   While[k < maxiter, 
    For[i = 1, i <= n, i++, 
     xk1[[i]] = (1/A[[i, i]])*(b[[i]] - 
         Sum[A[[i, j]]*xk1[[j]], {j, 1, i - 1}] - 
         Sum[A[[i, j]]*xk[[j]], {j, i + 1, n}])];
    xk = xk1; OutputDetails = Append[OutputDetails, xk];
    k++;];
   colHeading = Table[Subscript[x, s], {s, 1, n}];
   Print[NumberForm[
     TableForm[OutputDetails, TableHeadings -> {None, colHeading}], 
     6]];
   Print["No. of iterations performed: ", maxiter];];
A = {{5, 1, 2}, {-3, 9, 4}, {1, 2, -7}};
b = {10, -14, -33};
X0 = {0, 0, 0};
GaussSeidel[A, b, X0, 15];
```

### Question 2
```matlab
GaussSeidelMatrixForm[A0_, b0_, x0_, maxiter_] := 
  Module[{A = N[A0], b = N[b0], xk = x0, k = 0, D, L, U, DLinv, 
    OutputDetails}, D = DiagonalMatrix[Diagonal[A]];
   L = LowerTriangularize[A, -1];
   U = UpperTriangularize[A, 1];
   DLinv = Inverse[D + L];
   OutputDetails = {xk};
   While[k < maxiter, xk = -DLinv.U.xk + DLinv.b;
    OutputDetails = Append[OutputDetails, xk];
    k++;];
   colHeading = Table[Subscript[x, s], {s, 1, Length[x0]}];
   Print[NumberForm[
     TableForm[OutputDetails, TableHeadings -> {None, colHeading}], 
     6]];
   Print["No. of iterations performed: ", maxiter];];
A = {{5, 1, 2}, {-3, 9, 4}, {1, 2, -7}};
b = {10, -14, -33};
X0 = {0, 0, 0};
GaussSeidelMatrixForm[A, b, X0, 15]
```
## Lagrange Interpolation
### Question 1
```matlab
LagrangePolynomial[x0_, f0_] := 
 Module[{xi = x0, fi = f0, n, m, polynomial},
  n = Length[xi];
  m = Length[fi];
  If[n != m,
   Print["List of points and function's values are not of same size"];
   Return[];];
  
  For[i = 1, i <= n, i++,
   L[i, x_] = (Product[(x - xi[[j]])/(xi[[i]] - xi[[j]]), {j, 1, i - 1}]) *
               (Product[(x - xi[[j]])/(xi[[i]] - xi[[j]]), {j, i + 1, n}]);];
  polynomial[x_] := Sum[L[k, x]*fi[[k]], {k, 1, n}];
  Return[polynomial[x]];]
nodes = {0, 1, 3};
values = {1, 3, 55};

lagrangePolynomial[x_] = LagrangePolynomial[nodes, values]
Expand[%]
nodes = {1, 3, 5, 7, 9};
values = {N[Log[1]], N[Log[3]], N[Log[5]], N[Log[7]], N[Log[9]]};
lagrangePolynomial[x_] = LagrangePolynomial[nodes, values]
Simplify[%]
Plot[{lagrangePolynomial[x], Log[x]}, {x,1,10}, Ticks-> {Range[0,10]}, PlotLegends -> "Expressions"]
```

## Newton Interpolation
```matlab
newtonDividedDifference[x_List, y_List] :=
 Module[{n = Length[x], dd, i, j},dd = Table[0, {n}, {n}];
  Do[dd[[i, 1]] = y[[i]],{i, 1, n}];
  For[j = 2, j <= n, j++, For[i = j, i <= n, i++,
    dd[[i, j]] = (dd[[i, j - 1]] - dd[[i - 1, j - 1]])/(x[[i]] - x[[i - j + 1]]);];];dd]

newtonPolynomial[x_List, y_List, var_Symbol] :=
 Module[{dd = newtonDividedDifference[x, y], n = Length[x], poly},poly = dd[[1, 1]];
  Do[poly = poly + dd[[i, i]] * Product[var - x[[k]], {k, 1, i - 1}],{i, 2, n}];
  Expand[poly]]

xVals = {0.5, 1.5, 3, 5, 6.5, 8};
yVals = {1.625, 5.875, 31, 131, 282.125, 521};
P = newtonPolynomial[xVals, yVals, x]
f7 = P /. x -> 7
```

### Question 1:
```matlab
NDD[x0_, f0_, startindex_, endindex_] :=
 Module[{x = x0, f = f0, i = startindex, j = endindex, answer},
  If[i == j,Return[f[[i]]],answer = (NDD[x, f, i + 1, j] - NDD[x, f, i, j - 1])/(x[[j]] - x[[i]]);
   Return[answer]];];
x = {0.5, 1.5, 3, 5, 6.5, 8};
f = {1.625, 5.875, 31, 131, 282.125, 521};
NDD[x, f, 1, 2]
```

### Question 2:
```matlab
NDDP[x0_, f0_] := Module[{x1 = x0, f = f0, n, newtonPolynomial, k, j},
  n = Length[x1];
  newtonPolynomial[y_] = 0;
  For[i = 1, i <= n, i++, prod[y_] = 1;
   For[k = 1, k <= i - 1, k++, prod[y_] = prod[y] * (y - x1[[k]])];
   newtonPolynomial[y_] =
    newtonPolynomial[y] + NDD[x1, f, 1, i] * prod[y]];
  Return[newtonPolynomial[y]];];
nodes = {0, 1, 3};
values = {1, 3, 55};
NDDP[nodes, values]
```

## Trapezoidal Rule Method
### Question 1
```matlab
a = Input["Enter the left end point"];
b = Input["Enter the right end point"];
n = Input["Enter the number of sub intervals to be formed"];
h = (b - a)/n;
y = Table[a + i*h, {i, 1, n}];
f[x] := Log[x];
sumodd = 0;
sumeven = 0;
For[i = 1, i < n, i += 2, sumodd += 2*f[x] /. x -> y[[i]]];
For[i = 2, i < n, i += 2, sumodd += 2*f[x] /. x -> y[[i]]];
Tn = (h/2)*((f[x] /. x -> a) + N[sumodd] + 
     N[sumeven] + (f[x] /. x -> b));
Print["For n=", n, ",Trapezoidal estimate is:", Tn]
in = Integrate[Log[x], {x, 4, 5.2}];
Print["True value is ", in]
Print["Absolute error is", Abs[Tn - in]]
```

### Question 2
```matlab
a = Input["Enter the left end point"];
b = Input["Enter the right end point"];
n = Input["Enter the number of sub intervals to be formed"];
h = (b - a)/n;
y = Table[a + i*h, {i, 1, n}];
f[x] := Sin[x];
sumodd = 0;
sumeven = 0;
For[i = 1, i < n, i += 2, sumodd += 2*f[x] /. x -> y[[i]]];
For[i = 2, i < n, i += 2, sumodd += 2*f[x] /. x -> y[[i]]];
Tn = (h/2)*((f[x] /. x -> a) + N[sumodd] + 
     N[sumeven] + (f[x] /. x -> b));
Print["For n=", n, ",Trapezoidal estimate is:", Tn]
in = Integrate[Sin[x], {x, 0, Pi/2}];
Print["True value is ", in]
Print["Absolute error is", Abs[Tn - in]]
```

## Euler Method
### Question 1
```matlab
EulerMethod[a0_, b0_, n0_, f_, alpha_] := 
  Module[{a = a0, b = b0, n = n0, h, ti}, h = (b - a)/n;
   ti = Table[a + (j - 1) h, {j, 1, n + 1}];
   ui = Table[0, {n + 1}];
   ui[[1]] = alpha;
   OutputDetails = {{0, ti[[1]], alpha}};
   For[i = 1, i <= n, i++, 
    ui[[i + 1]] = ui[[i]] + h*f[ti[[i]], ui[[i]]];
    OutputDetails = 
     Append[OutputDetails, {i, N[ti[[i + 1]]], N[ui[[i + 1]]]}];];
   Print[NumberForm[
     TableForm[OutputDetails, 
      TableHeadings -> {None, {"i", "ti", "ui"}}], 6]];
   Print["Subinterval size h used= ", h];];
f[t_, w_] := 1 + w/t;
a = 1;
b = 6;
n = 10;
alpha = 1;
EulerMethod[a, b, 10, f, alpha];
```

### Question 2
```matlab
EulerMethodwithH[a0_, b0_, h0_, f_, alpha_] :=
  Module[{a = a0, b = b0, h = h0, n, ti},
   n = (b - a)/h;
   ti = Table[a + (j - 1) h, {j, 1, n + 1}];
   ui = Table[0, {n + 1}];
   ui[[1]] = alpha;
   OutputDetails = {{0, ti[[1]], alpha}};
   For[i = 1, i <= n, i++,
    ui[[i + 1]] = ui[[i]] + h*f[ti[[i]], ui[[i]]];
    OutputDetails = Append[OutputDetails,
      {i, N[ti[[i + 1]]], N[ui[[i + 1]]]}];];
   Print[NumberForm[
     TableForm[OutputDetails, 
      TableHeadings -> {None, {"i", "ti", "ui"}}], 6]];
   Print["Subinterval size h used= ", h];];
g[t_, w_] := 1 + w/t;
a = 1;
b = 6;
h = .2;
alpha = 1;
EulerMethodwithH[a, b, h, g, alpha];
```


## 2nd Order Runge Kutta Method
### Question 1
```matlab
ModifiedEulerMethod[a0_, b0_, n0_, f_, alpha_, actualSolution_] :=
 Module[{a=a0, b=b0, n=n0, h, ti, K1, K2},
 h = (b-a)/n;
 ti=Table[a+(j-1) h,{j,1,n+1}];
wi=Table[0,{n+1}];wi[[1]] =alpha;
actualSol = actualSolution[ti[[1]]];
difference = Abs[actualSol - wi[[1]]];
OutputDetails={{0,ti[[1]],alpha,actualSol, difference}};
For[i=1,i<=n,i++,
K1 = h f[ti[[i]],wi[[i]]];
K2 = h f[ti[[i]] +h/2,wi[[i]]+ K1/2];
wi[[i+1]] =wi[[i]]+K2;
actualSol = actualSolution[ti[[i+1]]];
difference =Abs[actualSol - wi[[i+1]]];
OutputDetails=Append[OutputDetails,{i,N[ti[[i+1]]],N[wi[[i+1]]],N[actualSol],N[difference]}];];
Print[NumberForm[TableForm[OutputDetails,TableHeadings->{None,{"i","ti","wi","actSol(ti)","Abs(wi-actSol(ti))"}}],6]];];
f[t_,x_] := 1+x/t;
actualSolution[t_]:=t(1+Log[t]);
ModifiedEulerMethod[1, 6, 5,f,1,actualSolution]
```

## Simpson's Rule
### Question : 1
```matlab
Simpson[f_, a_, b_, n_] := Module[{h = (b - a)/n},
  If[OddQ[n], Return["n must be even"]];
  (h/3) * (f[a] + f[b] +
     4*Sum[f[a + i*h], {i, 1, n - 1, 2}] +
     2*Sum[f[a + i*h], {i, 2, n - 2, 2}])]
f[x_] := 1/(1 + x)
Simpson[f, 0, 1, 2]
```

### Question : 2
```matlab
Simpson[f_, a_, b_, n_] := Module[{h = (b - a)/n},
  If[OddQ[n], Return["n must be even"]];
  (h/3) * (f[a] + f[b] +
     4*Sum[f[a + i*h], {i, 1, n - 1, 2}] +
     2*Sum[f[a + i*h], {i, 2, n - 2, 2}])]
f[x_] := 1/(1 + x)
Simpson[f, 0, 1, 3]
```

### Question : 3
```matlab
SimpsonOneThird[f_, a_, b_, n_] := 
 Module[{h, sum1, sum2},
  If[OddQ[n], Return["n must be even"]];
  h = (b - a)/n;
  sum1 = Sum[f[a + i*h], {i, 1, n - 1, 2}];
  sum2 = Sum[f[a + i*h], {i, 2, n - 2, 2}];
  (h/3)*(f[a] + 4*sum1 + 2*sum2 + f[b])]
f[x_] := 1/(1 + x)
SimpsonOneThird[f, 0, 1, 2]
```
