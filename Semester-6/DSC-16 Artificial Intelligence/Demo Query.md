### EXAMPLE QUERIES TO TEST THE PROGRAMS:

1. FAMILY TREE:
```
father(john, mary).
mother(X, tom).
sibling(mary, tom).
grandparent(john, alice).
cousin(alice, charlie).
ancestor(john, alice).
```

2. CONCATENATION:
```
conc([1,2], [3,4], L).
conc([a,b,c], [d,e], L).
```

3. REVERSE:
```
reverse([1,2,3,4], R).
reverse_tail([a,b,c,d,e], R).
```

4. SUM:
```
sum(5, 3, S).
sum(10, 25, S).
```

5. MAXIMUM:
```
max(5, 3, M).
max(10, 15, M).
```

6. FACTORIAL:
```
factorial(5, F).
factorial_tail(6, F).
```

7. FIBONACCI:
```
generate_fib(7, T).
fib_tail(10, T).
```

8. POWER:
```
power(2, 3, Ans).
power(5, 4, Ans).
power(2, -2, Ans).
```

9. MULTIPLICATION:
```
multi(3, 4, R).
multi(-3, 4, R).
multi_simple(7, 8, R).
```

10. MEMBERSHIP:
```
memb(3, [1,2,3,4]).
memb(5, [1,2,3,4]).
```

11. SUM LIST:
```
sumlist([1,2,3,4,5], S).
sumlist_tail([10,20,30], S).
```

12. EVEN/ODD LENGTH:
```
evenlength([1,2,3,4]).
oddlength([1,2,3]).
evenlength([a,b]).
```

13. MAX LIST:
```
maxlist([3,7,2,9,1], M).
maxlist_alt([5,2,8,1,9,3], M).
```

14. INSERT:
```
insert(x, 3, [a,b,c,d], R).
insert(5, 1, [1,2,3], R).
```
15. DELETE:
```
delete(2, [a,b,c,d], R).
delete(1, [1,2,3,4], R).
```