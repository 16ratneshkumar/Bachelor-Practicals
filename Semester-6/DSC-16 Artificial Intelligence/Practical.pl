% ============================================================================
% PROLOG PROGRAMS - Complete Solutions
% ============================================================================

% ----------------------------------------------------------------------------
% 1. FAMILY TREE IMPLEMENTATION
% ----------------------------------------------------------------------------

% Facts: parent(Parent, Child)
parent(john, mary).
parent(john, tom).
parent(john, ann).
parent(susan, mary).
parent(susan, tom).
parent(susan, ann).
parent(mary, alice).
parent(mary, bob).
parent(tom, charlie).
parent(tom, diana).
parent(ann, edward).

% Facts: gender
male(john).
male(tom).
male(bob).
male(charlie).
male(edward).
female(susan).
female(mary).
female(ann).
female(alice).
female(diana).

% Rules for family relationships
father(X, Y) :- parent(X, Y), male(X).
mother(X, Y) :- parent(X, Y), female(X).

child(X, Y) :- parent(Y, X).

son(X, Y) :- child(X, Y), male(X).
daughter(X, Y) :- child(X, Y), female(X).

sibling(X, Y) :- parent(Z, X), parent(Z, Y), X \= Y.
brother(X, Y) :- sibling(X, Y), male(X).
sister(X, Y) :- sibling(X, Y), female(X).

grandparent(X, Y) :- parent(X, Z), parent(Z, Y).
grandfather(X, Y) :- grandparent(X, Y), male(X).
grandmother(X, Y) :- grandparent(X, Y), female(X).

grandchild(X, Y) :- grandparent(Y, X).
grandson(X, Y) :- grandchild(X, Y), male(X).
granddaughter(X, Y) :- grandchild(X, Y), female(X).

uncle(X, Y) :- brother(X, Z), parent(Z, Y).
aunt(X, Y) :- sister(X, Z), parent(Z, Y).

cousin(X, Y) :- parent(Z, X), parent(W, Y), sibling(Z, W).

ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).

descendant(X, Y) :- ancestor(Y, X).

% ----------------------------------------------------------------------------
% 2. LIST CONCATENATION - conc(L1, L2, L3)
% ----------------------------------------------------------------------------

conc([], L2, L2).
conc([H|T1], L2, [H|T3]) :- conc(T1, L2, T3).

% ----------------------------------------------------------------------------
% 3. LIST REVERSAL - reverse(L, R)
% ----------------------------------------------------------------------------

reverse_list(L, R):-
    rev(L,[],R).
rev([], Acc, Acc).
rev([H|T],Acc, R) :-
    rev(T, [H|Acc], R).

% ----------------------------------------------------------------------------
% 4. SUM OF TWO NUMBERS - sum(X, Y, Sum)
% ----------------------------------------------------------------------------

sum(X, Y, Sum) :- Sum is X + Y.

% ----------------------------------------------------------------------------
% 5. MAXIMUM OF TWO NUMBERS - max(X, Y, M)
% ----------------------------------------------------------------------------

max(X, Y, X) :- X >= Y.
max(X, Y, Y) :- Y > X.

% ----------------------------------------------------------------------------
% 6. FACTORIAL - factorial(N, F)
% ----------------------------------------------------------------------------

factorial(0, 1).
factorial(N, F) :- 
    N > 0,
    N1 is N - 1,
    factorial(N1, F1),
    F is N * F1.

% ----------------------------------------------------------------------------
% 7. FIBONACCI SERIES - generate_fib(N, T)
% ----------------------------------------------------------------------------

generate_fib(0, 0).
generate_fib(1, 1).
generate_fib(N, T) :-
    N > 1,
    N1 is N - 1,
    N2 is N - 2,
    generate_fib(N1, T1),
    generate_fib(N2, T2),
    T is T1 + T2.

% ----------------------------------------------------------------------------
% 8. POWER FUNCTION - power(Num, Pow, Ans)
% ----------------------------------------------------------------------------

power(_, 0, 1).
power(Num, Pow, Ans) :-
    Pow > 0,
    Pow1 is Pow - 1,
    power(Num, Pow1, Ans1),
    Ans is Num * Ans1.
power(Num, Pow, Ans) :-
    Pow < 0,
    PosPow is -Pow,
    power(Num, PosPow, TempAns),
    Ans is 1 / TempAns.

% ----------------------------------------------------------------------------
% 9. MULTIPLICATION - multi(N1, N2, R)
% ----------------------------------------------------------------------------

multi_simple(N1, N2, R) :- R is N1 * N2.

% ----------------------------------------------------------------------------
% 10. MEMBERSHIP CHECK - memb(X, L)
% ----------------------------------------------------------------------------

memb(X, [X|_]).
memb(X, [_|T]) :- memb(X, T).

% ----------------------------------------------------------------------------
% 11. SUM OF LIST - sumlist(L, S)
% ----------------------------------------------------------------------------

sumlist([], 0).
sumlist([H|T], S) :-
    sumlist(T, S1),
    S is H + S1.

% ----------------------------------------------------------------------------
% 12. EVEN/ODD LENGTH - evenlength(List), oddlength(List)
% ----------------------------------------------------------------------------

evenlength([]).
evenlength([_|T]) :- oddlength(T).
oddlength([_]).
oddlength([_|T]) :- evenlength(T).

% ----------------------------------------------------------------------------
% 13. MAXIMUM IN LIST - maxlist(L, M)
% ----------------------------------------------------------------------------

max(X, Y, X) :- X >= Y.
max(X, Y, Y) :- Y > X.
maxlist([X], X).
maxlist([H|T], M) :-
    maxlist(T, M1),
    max(H, M1, M).


% ----------------------------------------------------------------------------
% 14. INSERT AT POSITION - insert(I, N, L, R)
% ----------------------------------------------------------------------------

insert(I, 1, L, [I|L]).
insert(I, N, [H|T], [H|R]) :-
    N > 1,
    N1 is N - 1,
    insert(I, N1, T, R).

% ----------------------------------------------------------------------------
% 15. DELETE AT POSITION - delete(N, L, R)
% ----------------------------------------------------------------------------

delete(1, [_|T], T).
delete(N, [H|T], [H|R]) :-
    N > 1,
    N1 is N - 1,
    delete(N1, T, R).
