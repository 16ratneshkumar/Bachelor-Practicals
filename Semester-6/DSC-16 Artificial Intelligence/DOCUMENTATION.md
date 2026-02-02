# PROLOG PROGRAMS - Complete Solutions Documentation

## Table of Contents
1. [Family Tree Implementation](#1-family-tree-implementation)
2. [List Concatenation](#2-list-concatenation)
3. [List Reversal](#3-list-reversal)
4. [Sum of Two Numbers](#4-sum-of-two-numbers)
5. [Maximum of Two Numbers](#5-maximum-of-two-numbers)
6. [Factorial](#6-factorial)
7. [Fibonacci Series](#7-fibonacci-series)
8. [Power Function](#8-power-function)
9. [Multiplication](#9-multiplication)
10. [Membership Check](#10-membership-check)
11. [Sum of List](#11-sum-of-list)
12. [Even/Odd Length](#12-evenodd-length)
13. [Maximum in List](#13-maximum-in-list)
14. [Insert at Position](#14-insert-at-position)
15. [Delete at Position](#15-delete-at-position)

---

## 1. Family Tree Implementation

### Description
Implements a family tree using facts and rules to demonstrate various family relationships.

### Facts Defined
- `parent(Parent, Child)` - defines parent-child relationships
- `male(Person)` and `female(Person)` - defines gender

### Rules Implemented
- `father(X, Y)` - X is the father of Y
- `mother(X, Y)` - X is the mother of Y
- `son(X, Y)` - X is the son of Y
- `daughter(X, Y)` - X is the daughter of Y
- `sibling(X, Y)` - X and Y are siblings
- `brother(X, Y)` - X is the brother of Y
- `sister(X, Y)` - X is the sister of Y
- `grandparent(X, Y)` - X is the grandparent of Y
- `grandfather(X, Y)` - X is the grandfather of Y
- `grandmother(X, Y)` - X is the grandmother of Y
- `uncle(X, Y)` - X is the uncle of Y
- `aunt(X, Y)` - X is the aunt of Y
- `cousin(X, Y)` - X and Y are cousins
- `ancestor(X, Y)` - X is an ancestor of Y
- `descendant(X, Y)` - X is a descendant of Y

### Example Queries
```prolog
?- father(john, mary).
% Output: true

?- mother(X, tom).
% Output: X = susan

?- sibling(mary, tom).
% Output: true

?- grandparent(john, alice).
% Output: true

?- cousin(alice, charlie).
% Output: true

?- ancestor(john, X).
% Output: X = mary; X = tom; X = ann; X = alice; X = bob; X = charlie; etc.
```

---

## 2. List Concatenation

### Predicate
`conc(L1, L2, L3)` - concatenates L1 and L2 to get L3

### How It Works
1. **Base case**: `conc([], L2, L2)` - concatenating empty list with L2 gives L2
2. **Recursive case**: `conc([H|T1], L2, [H|T3])` - move head of L1 to result, recursively concatenate tail

### Example Queries
```prolog
?- conc([1,2], [3,4], L).
% Output: L = [1, 2, 3, 4]

?- conc([a,b,c], [d,e], L).
% Output: L = [a, b, c, d, e]

?- conc([1,2], X, [1,2,3,4]).
% Output: X = [3, 4]

?- conc(X, [3,4], [1,2,3,4]).
% Output: X = [1, 2]
```

---

## 3. List Reversal

### Predicates
- `reverse(L, R)` - simple reverse (less efficient)
- `reverse_tail(L, R)` - tail-recursive reverse (more efficient)

### How It Works
**Simple Version:**
1. **Base case**: `reverse([], [])` - reverse of empty list is empty list
2. **Recursive case**: reverse tail, then append head at the end

**Tail-Recursive Version:**
Uses an accumulator to build the reversed list efficiently.

### Example Queries
```prolog
?- reverse([1,2,3,4], R).
% Output: R = [4, 3, 2, 1]

?- reverse_tail([a,b,c,d,e], R).
% Output: R = [e, d, c, b, a]

?- reverse([1], R).
% Output: R = [1]
```

---

## 4. Sum of Two Numbers

### Predicate
`sum(X, Y, Sum)` - calculates Sum = X + Y

### How It Works
Uses Prolog's built-in `is` operator to evaluate arithmetic expressions.

### Example Queries
```prolog
?- sum(5, 3, S).
% Output: S = 8

?- sum(10, 25, S).
% Output: S = 35

?- sum(7.5, 2.5, S).
% Output: S = 10.0
```

---

## 5. Maximum of Two Numbers

### Predicate
`max(X, Y, M)` - M is the maximum of X and Y

### How It Works
1. If `X >= Y`, then `M = X`
2. If `Y > X`, then `M = Y`

Also includes alternative implementation using if-then-else.

### Example Queries
```prolog
?- max(5, 3, M).
% Output: M = 5

?- max(10, 15, M).
% Output: M = 15

?- max(7, 7, M).
% Output: M = 7
```

---

## 6. Factorial

### Predicates
- `factorial(N, F)` - simple recursive factorial
- `factorial_tail(N, F)` - tail-recursive factorial (more efficient)

### How It Works
**Simple Version:**
- `factorial(0, 1)` - base case
- `factorial(N, F)` - F = N * factorial(N-1)

**Tail-Recursive Version:**
Uses an accumulator to avoid stack overflow for large numbers.

### Example Queries
```prolog
?- factorial(5, F).
% Output: F = 120

?- factorial(0, F).
% Output: F = 1

?- factorial_tail(10, F).
% Output: F = 3628800
```

---

## 7. Fibonacci Series

### Predicates
- `generate_fib(N, T)` - generates Nth Fibonacci number (simple recursive)
- `fib_tail(N, T)` - tail-recursive version (more efficient)

### How It Works
**Simple Version:**
- `generate_fib(0, 0)` - base case
- `generate_fib(1, 1)` - base case
- `generate_fib(N, T)` - T = fib(N-1) + fib(N-2)

**Tail-Recursive Version:**
Uses two accumulators to track previous two Fibonacci numbers.

### Example Queries
```prolog
?- generate_fib(7, T).
% Output: T = 13

?- fib_tail(10, T).
% Output: T = 55

?- generate_fib(0, T).
% Output: T = 0
```

**Fibonacci Sequence:** 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55...

---

## 8. Power Function

### Predicate
`power(Num, Pow, Ans)` - Ans = Num^Pow

### How It Works
1. **Base case**: `power(_, 0, 1)` - anything to power 0 is 1
2. **Positive power**: recursive multiplication
3. **Negative power**: calculate positive power, then take reciprocal

### Example Queries
```prolog
?- power(2, 3, Ans).
% Output: Ans = 8

?- power(5, 4, Ans).
% Output: Ans = 625

?- power(2, -2, Ans).
% Output: Ans = 0.25

?- power(10, 0, Ans).
% Output: Ans = 1
```

---

## 9. Multiplication

### Predicates
- `multi(N1, N2, R)` - recursive multiplication
- `multi_simple(N1, N2, R)` - using built-in operator

### How It Works
**Recursive Version:**
- Implements multiplication as repeated addition
- Handles negative numbers correctly

**Simple Version:**
- Uses Prolog's built-in `*` operator

### Example Queries
```prolog
?- multi(3, 4, R).
% Output: R = 12

?- multi(-3, 4, R).
% Output: R = -12

?- multi_simple(7, 8, R).
% Output: R = 56
```

---

## 10. Membership Check

### Predicate
`memb(X, L)` - checks if X is a member of list L

### How It Works
1. **Base case**: `memb(X, [X|_])` - X is the head of the list
2. **Recursive case**: `memb(X, [_|T])` - check if X is in the tail

### Example Queries
```prolog
?- memb(3, [1,2,3,4]).
% Output: true

?- memb(5, [1,2,3,4]).
% Output: false

?- memb(X, [a,b,c]).
% Output: X = a; X = b; X = c
```

---

## 11. Sum of List

### Predicates
- `sumlist(L, S)` - simple recursive sum
- `sumlist_tail(L, S)` - tail-recursive sum (more efficient)

### How It Works
**Simple Version:**
1. **Base case**: `sumlist([], 0)` - sum of empty list is 0
2. **Recursive case**: sum = head + sum(tail)

**Tail-Recursive Version:**
Uses an accumulator to build the sum efficiently.

### Example Queries
```prolog
?- sumlist([1,2,3,4,5], S).
% Output: S = 15

?- sumlist_tail([10,20,30], S).
% Output: S = 60

?- sumlist([], S).
% Output: S = 0
```

---

## 12. Even/Odd Length

### Predicates
- `evenlength(List)` - true if list has even length
- `oddlength(List)` - true if list has odd length

### How It Works
Uses mutual recursion:
- Empty list has even length
- Single element list has odd length
- If tail has odd length, then list has even length
- If tail has even length, then list has odd length

Also includes alternative implementations using `length` and `mod`.

### Example Queries
```prolog
?- evenlength([1,2,3,4]).
% Output: true

?- oddlength([1,2,3]).
% Output: true

?- evenlength([a,b]).
% Output: true

?- oddlength([]).
% Output: false
```

---

## 13. Maximum in List

### Predicates
- `maxlist(L, M)` - finds maximum in list L
- `maxlist_alt(L, M)` - alternative implementation

### How It Works
1. **Base case**: `maxlist([X], X)` - max of single element is that element
2. **Recursive case**: compare head with max of tail

### Example Queries
```prolog
?- maxlist([3,7,2,9,1], M).
% Output: M = 9

?- maxlist_alt([5,2,8,1,9,3], M).
% Output: M = 9

?- maxlist([5], M).
% Output: M = 5
```

---

## 14. Insert at Position

### Predicate
`insert(I, N, L, R)` - inserts item I at position N in list L to get result R

### How It Works
1. **Base case**: `insert(I, 1, L, [I|L])` - insert at position 1 (beginning)
2. **Recursive case**: keep head, insert in tail at position N-1

### Example Queries
```prolog
?- insert(x, 3, [a,b,c,d], R).
% Output: R = [a, b, x, c, d]

?- insert(5, 1, [1,2,3], R).
% Output: R = [5, 1, 2, 3]

?- insert(z, 4, [a,b,c], R).
% Output: R = [a, b, c, z]
```

---

## 15. Delete at Position

### Predicate
`delete(N, L, R)` - deletes element at position N from list L to get result R

### How It Works
1. **Base case**: `delete(1, [_|T], T)` - delete first element
2. **Recursive case**: keep head, delete from tail at position N-1

### Example Queries
```prolog
?- delete(2, [a,b,c,d], R).
% Output: R = [a, c, d]

?- delete(1, [1,2,3,4], R).
% Output: R = [2, 3, 4]

?- delete(4, [a,b,c,d], R).
% Output: R = [a, b, c]
```

---

## Running the Programs

### Prerequisites
You need a Prolog interpreter installed. Common options:
- SWI-Prolog (recommended) - Download from: https://www.swi-prolog.org/

### Loading the File
1. Start your Prolog interpreter
2. Load the file:
   ```prolog
   ?- [prolog_programs].
   ```
   or
   ```prolog
   ?- consult('prolog_programs.pl').
   ```

### Running Queries
After loading, you can run any of the example queries shown above.

### Tips
- Use `;` to see alternative solutions
- Use `.` to stop seeing more solutions
- Use `trace.` to debug your queries
- Use `listing(predicate_name).` to see the definition of a predicate

---

## Key Prolog Concepts Used

### 1. Facts
Basic assertions about the world (e.g., `parent(john, mary).`)

### 2. Rules
Define relationships using logical implications (e.g., `father(X, Y) :- parent(X, Y), male(X).`)

### 3. Recursion
Essential for list processing and mathematical operations

### 4. Pattern Matching
Prolog automatically matches patterns in queries with facts/rules

### 5. Unification
Process of making two terms equal by finding appropriate substitutions

### 6. Backtracking
Prolog searches for all possible solutions automatically

### 7. Cut (!)
Used to prevent backtracking (not used in these basic examples)

### 8. Tail Recursion
More efficient recursion using accumulators

---

## Common Prolog Operators

- `:-` - "if" or "is defined as"
- `,` - "and" (conjunction)
- `;` - "or" (disjunction)
- `\=` - "not equal"
- `is` - arithmetic evaluation
- `=` - unification
- `==` - equality check without unification
- `[]` - empty list
- `[H|T]` - list with head H and tail T
- `_` - anonymous variable (don't care)

---

## Troubleshooting

### Common Errors

1. **Singleton variable warning**
   - Use `_` for variables you don't care about

2. **Arguments are not sufficiently instantiated**
   - Make sure variables have values before arithmetic operations

3. **Out of local stack**
   - Your recursion might not have a proper base case
   - Consider using tail recursion

4. **Syntax error**
   - Check for missing periods, commas, or parentheses
   - Variables must start with uppercase or underscore
