%-*- mode: prolog; -*-


% An employee is represented using the structure
% employee(Name, Age, Department, Salary).

% List of employees used for testing
employees([ employee(tom, 33, cs, 85000.00),
	    employee(joan, 23, ece, 110000.00),
	    employee(bill, 29, cs, 69500.00),
	    employee(john, 28, me, 58200.00),
	    employee(sue, 19, cs, 22000.00)
	  ]).


%%% #1 10-points
% dept_employees(Employees, Dept, DeptEmployees): Given a list
% Employees of employees and a department Dept match DeptEmployees
% to the subsequence of Employees having department Dept.

dept_employees([],_,[]).
dept_employees([E|Es],Dept,[E|Zs]):-
    E = employee(_,_,Dept,_),
    dept_employees(Es,Dept,Zs).
dept_employees([E|Es],Dept,Zs):-
    E \= employee(_,_,Dept,_),
    dept_employees(Es,Dept,Zs).



%%% #2 15-points
% employees_salary_sum(Employees, Sum): succeeds iff Sum matches sum
% of salaries of the employees in Employees.  Must be tail-recursive.
employees_salary_sum(Employees, Sum) :- 
     total(Employees,0,Sum).

total([],A,A).
total([X|Y],Acc,Sum):-
    X=employee(_,_,_,A),
    Addsum is Acc+A,
    total(Y,Addsum,Sum).


%%% #3: 15-points
% list_access(Indexes, List, Z): Given a list Indexes containing
% 0-based indexes and a list List possibly containing lists nested to
% an abitrary depth, match Z with the element in List indexed
% successively by the indexes in Indexes. Match Z with the atom nil if
% there is no such element.
list_access([],X,X).
list_access([_|_],[],nil).
list_access([I|Is],List,Y):-
    List=[_|_],
    list_val(I,List,EVal),
    list_access(Is,EVal,Y).

list_val(_,[],nil).
list_val(0,[Y|_],Y).
list_val(I,[_|K],Y):-
    I>0,
    I1 is I-1,
    list_val(I1, K, Y).


%%% #4 15-points
% count_non_pairs(List, NNonPairs): NNonPairs matches the # of non-pairs
% in list List, including the non-pairs in any lists nested directly or
% indirectly in List.  Note that lists which are nested within a structure
% are not processed.
% The count will be the number of leaves in the tree corresponding to the
% list structure of List.
count_non_pairs([],1).
count_non_pairs(Z, 1):-
    Z \= [_|_].
count_non_pairs([X|Y], NNonPairs):-
    count_non_pairs(Y, NNPair),
    count_non_pairs(X, NNPairr),
    NNonPairs is NNPair + NNPairr.


%%% #5 10-points
% divisible_by(Ints, N, Int): Int is an integer in list of integers Ints
% which is divisible by N.  Successive Int's are returned on backtracking
% in the order they occur within list Ints.
% Hint: use member/2 and the mod operator
divisible_by([], _, []).
divisible_by([H|T], X, [H|Ts]) :- H mod X =:= 0, divisible_by(T, X, Ts).
divisible_by([H|T], X, Ts) :- H mod X =\= 0, divisible_by(T, X, Ts).


%%% #6 15-points
% re_match(Re, List): Regex Re matches all the symbols in List.
% A regex is represented in Prolog as follows:
%   A Prolog symbol Sym (for which atomic(Sym) is true) is a Prolog regex.
%   If A and B are Prolog regex's, then so is conc(A, B) representing AB.
%   If A and B are Prolog regex's, then so is alt(A, B) representing A|B.
%   If A is a Prolog regex, then so is kleene(A), representing A*.
re_match(Re, List) :- 'TODO'(Re, List).

:- begin_tests(re_match).
test(single) :-
    re_match(a, [a]).
test(single_fail, fail) :-
    re_match(a, [b]).
test(conc) :-
    re_match(conc(a, b), [a, b]).
test(conc_fail, fail) :-
    re_match(conc(a, b), [a, c]).
test(alt1, nondet) :-
    re_match(alt(a, b), [a]).
test(alt2, nondet) :-
    re_match(alt(a, b), [b]).
test(alt_fail, fail) :-
    re_match(alt(a, b), [c]).
test(kleene_empty, nondet) :-
    re_match(kleene(a), []).
test(kleene_single, nondet) :-
    re_match(kleene(a), [a]).
test(kleene_multiple, nondet) :-
    re_match(kleene(a), [a, a, a, a]).
test(conc_kleene_sym, nondet) :-
    re_match(conc(kleene(a), b), [a, a, a, a, b]).
test(kleene_kleene0, nondet) :-
    re_match(conc(kleene(a), kleene(b)), [a, a, a, a]).
test(kleene_kleene, nondet) :-
    re_match(conc(kleene(a), kleene(b)), [a, a, a, a, b, b, b]).
test(kleene_kleene_fail, fail) :-
    re_match(conc(kleene(a), kleene(b)), [a, a, a, a, b, b, b, a]).
test(kleene_conc, nondet) :-
    re_match(kleene(conc(a, b)), [a, b, a, b, a, b]).
test(kleene_conc_fail, fail) :-
    re_match(kleene(conc(a, b)), [a, b, a, b, a, b, a]).
test(kleene_alt, nondet) :-
    re_match(kleene(alt(a, b)), [a, a, b, a, b, a, b, b]).
test(conc_kleene_conc, nondet) :-
    re_match(conc(a, conc(kleene(b), a)), [a, b, b, b, a]).
test(conc_kleene0_conc, nondet) :-
    re_match(conc(a, conc(kleene(b), a)), [a, a]).
test(conc_kleene_conc_fail, fail) :-
    re_match(conc(a, conc(kleene(b), a)), [a, b, b, b]).
test(complex1, nondet) :-
    re_match(conc(kleene(alt(a, b)), kleene(alt(0, 1))), [a,b,b,a,0,0,1,1]).
test(complex2, nondet) :-
    re_match(conc(kleene(alt(a, b)), kleene(alt(0, 1))), [0,0,1,1]).
test(complex_empty, nondet) :-
    re_match(conc(kleene(alt(a, b)), kleene(alt(0, 1))), []).
:- end_tests(re_match).

%%% #7 20-points
% clausal_form(PrologRules, Form): given a non-empty list PrologRules
% of Prolog rules of the form Head or (Head :- Body), Form matches a
% logical conjunction (using the infix operator /\) of the clauses
% corresponding to each rule in PrologRules, where each clause is a
% disjunction (represented using the infix \/ operator) of literals with
% the prefix ~ operator used to indicate negative literals.
:- op(200, fx, ~). %declare ~ operator
clausal_form(PrologRules, Form) :- 'TODO'(PrologRules, Form).

:- begin_tests(clausal_form).
test(single_head, all(Z = [p(a, b)])) :-
    clausal_form([p(a, b)], Z).
test(simple_rule, all(Z = [p(a, b) \/ ~q(a, b)])) :-
    clausal_form([(p(a, b) :- q(a, b))], Z).
test(rule_with_multi_body,
     all(Z = [p(a, b) \/ ~q(a, b) \/ ~r(a, b) \/ ~s(x)])) :-
    clausal_form([(p(a, b) :- q(a, b), r(a, b), s(x))], Z).
test(multi_rule, all(Z = [p(a, b) /\ q(x, y) /\ r(1)])) :-
    clausal_form([p(a, b), q(x, y), r(1)], Z).
test(complex, all(Z = [Clause1 /\ Clause2 /\ Clause3 /\ Clause4])) :-
    Rule1 = (p(a, b) :- q(b, c), r(a, b), s(x)),
    Clause1 = p(a, b) \/ ~q(b, c) \/ ~r(a, b) \/ ~s(x),
    Rule2 = (m(f(X)) :- n(f(X), Y), X is 2*Y),
    Clause2 = m(f(X)) \/ ~n(f(X), Y) \/ ~(X is 2*Y),
    Rule3 = append([], Xs, Xs),
    Clause3 = append([], Xs, Xs),
    Rule4 = (append([A|As], Ys, [A|Zs]) :- append(As, Ys, Zs)),
    Clause4 = append([A|As], Ys, [A|Zs]) \/ ~append(As, Ys, Zs),
    clausal_form([Rule1, Rule2, Rule3, Rule4], Z).
:- end_tests(clausal_form).



