-module(prj5_sol).
-include_lib("eunit/include/eunit.hrl").
-compile([nowarn_export_all, export_all]).

%---------------------------- Test Control ------------------------------
%% Enabled Tests
%%   comment out -define to deactivate test.
%%   alternatively, enclose deactivated tests within
%%   -if(false). and -endif. lines
%% enable all tests before submission.
%% the skeleton file is distributed with all tests are deactivated

  %move this down to just before -endif when project completed
-define(test_dept_employees1, enabled).
-define(test_dept_employees2, enabled).

-define(test_dept_employees3, enabled).

-define(test_delete_employee, enabled).

-define(test_upsert_employee, enabled).

-define(test_find_employees, enabled).
-define(test_employees_req, enabled).
-if(false).
-define(test_employees_req_with_sort, enabled).
-define(test_employees_client_no_sort, enabled).
-define(test_employees_client_with_sort_dosort, enabled).
-define(test_employees_client_with_sort, enabled).
-define(test_employees_client_no_sort_mutate, enabled).
-define(test_employees_client_with_sort_mutate, enabled).
-define(test_employees_client_hot_reload, enabled).
-endif.


%% Tracing Tests: set trace_level as desired.
% trace_level == 0:  no tracing
% trace_level == 1:  function + test-name 
% trace_level == 2:  function + test-name + args + result
-define(trace_level, 0).
-if(?trace_level == 2).
  -define(test_trace(Test, F, Args, Result),
	  io:format(standard_error, "~p:~p: ~p =~n~p~n",
		    [ element(2, erlang:fun_info(F, name)), Test,
		      Args, Result])).
-elif(?trace_level == 1).
  -define(test_trace(Test, F, _Args, _Result),
	  io:format(standard_error, "~p:~p~n",
		    [ element(2, erlang:fun_info(F, name)), Test])).
-else.
  -define(test_trace(_Test, _F, _Args, _Result), true).
-endif.

%% A TestSpec is either a triple of the form { Test, Args, Result }
%% where Test is an atom describing the test, Args gives the list of
%% arguments to the function under test and Result is the expected
%% result, or a quadruple of the form { Test, Args, Result, Fn },
%% where Fn is applied to the actual Result before being compared with
%% the expected result Result.

make_tests(F, TestSpecs) ->   
    MapFn = fun (Spec) ->
		    case Spec of
			{ _Test, Args, Result } ->
			   fun () ->  
				   FResult = apply(F, Args),
				   ?test_trace(_Test, F, Args, FResult),
				   ?assertEqual(Result, FResult) 
			   end;
			{ _Test, Args, Result, Fn } ->
			    fun () ->  
				    FResult = apply(F, Args),
				    ?test_trace(_Test, F, Args, FResult),
				    ?assertEqual(Result, Fn(FResult)) 
			    end;
			_ -> 
			    Msg = io_lib:format("unknown spec ~p", [Spec]),
			    error(lists:flatten(Msg))
		    end				
	    end,
    lists:map(MapFn, TestSpecs).


%---------------------- employee Type and Data --------------------------

% we use name as a primary key for an employee.
% code can assume that any collection of employee will have most one
% having a specific name.
-record(employee, {name, age, dept, salary}).

% given a variable E which is an employee, use E#employee.dept to
% access the employee dept field.

% employee predicates
employee_has_name(Name) -> fun (E) -> E#employee.name == Name end.
employee_has_age(Age) -> fun (E) -> E#employee.age == Age end. 
employee_has_dept(Dept) -> fun (E) -> E#employee.dept == Dept end.
employee_has_salary(Salary) -> fun (E) -> E#employee.salary == Salary end.
     
% test data

-define(Tom, #employee{name=tom, age=33, dept=cs, salary=85000.00}).
-define(Joan, #employee{name=joan, age=23, dept=ece, salary=110000.00}).
-define(Bill, #employee{name=bill, age=29, dept=cs, salary=69500.00}).
-define(John, #employee{name=john, age=28, dept=me, salary=58200.00}).
-define(Sue,  #employee{name=sue, age=19, dept=cs, salary=22000.00}).
-define(Alice, #employee{name=alice, age=33, dept=cs, salary=85000.00}).
-define(Harry, #employee{name=harry, age=23, dept=ece, salary=110000.00}).
-define(Larry, #employee{name=larry, age=33, dept=cs, salary=69500.00}).
-define(Erwin, #employee{name=erwin, age=28, dept=me, salary=58200.00}).
-define(Jane, #employee{name=jane, age=19, dept=cs, salary=22000.00}).

% data used for upserts
-define(Tom1, #employee{name=tom, age=44, dept=ece, salary=185000.00}).
-define(Jane1, #employee{name=jane, age=33, dept=ece, salary=44000.00}).
-define(Joe1, #employee{name=joe, age=33, dept=me, salary=85000.00}).

-define(Employees, 
	[ ?Tom, ?Joan, ?Bill, ?John, ?Sue, ?Alice, ?Harry, ?Larry, 
	  ?Erwin, ?Jane]).
-define(SortedEmployees, 
	[ ?Alice, ?Bill, ?Erwin, ?Harry, ?Jane, ?Joan, ?John, 
	  ?Larry, ?Sue, ?Tom ]).

employees() -> ?Employees.
upsert_employees() -> [ ?Tom1, ?Jane1, ?Joe1 ].
% #1: "10-points"
% dept_employees1(Dept, Employees): return sub-list of Employees
% having dept = Dept.
% Restriction: must be implemented using recursion without using any library 
% functions.
dept_employees1(_,[]) -> [] ;
dept_employees1(Dept, [I|J]) -> 
    if I#employee.dept == Dept -> [I | dept_employees1(Dept,J)];
        true -> dept_employees1(Dept,J)
    end.

dept_employees_test_specs() -> 
    Es = ?Employees,
    [ { cs_empty, [cs, []], [] },
      { cs_employees, [cs, Es], [ ?Tom, ?Bill, ?Sue, ?Alice, ?Larry, ?Jane ] },
      { ece_employees, [ece, Es], [ ?Joan, ?Harry ] },
      { me_employees, [me, Es], [ ?John, ?Erwin ] },
      { ce_employees, [ce, Es], [] }				
    ].

-ifdef(test_dept_employees1).
dept_employees1_test_() ->
    make_tests(fun dept_employees1/2, dept_employees_test_specs()).
-endif. %test_dept_employees1 

%-------------------------- dept_employees2/2 ---------------------------

% #2: "5-points"
% dept_employees2(Dept, Employees): return sub-list of Employees
% having dept = Dept.
% Restriction: must be implemented using a single call to lists:filter().
dept_employees2(Dept, []) -> [];
dept_employees2(Dept, [I|J]) -> 
    if I#employee.dept == Dept -> [I|dept_employees2(Dept, J)]; true -> dept_employees2(Dept, J) end.

-ifdef(test_dept_employees2).
dept_employees2_test_() ->
    make_tests(fun dept_employees2/2, dept_employees_test_specs()).
-endif. %test_dept_employees2

%-------------------------- dept_employees3/2 ---------------------------

% #3: "5-points"
% dept_employees3(Dept, Employees): return sub-list of Employees
% having dept = Dept.
% Restriction: must be implemented using a list comprehension.
dept_employees3(Dept, Employees) ->
  I = [Z || Z <- Employees, Dept == Z#employee.dept], I.

-ifdef(test_dept_employees3).
dept_employees3_test_() ->
    make_tests(fun dept_employees3/2, dept_employees_test_specs()).
-endif. %test_dept_employees3

%------------------------- delete_employee/2 ----------------------------
% #4: "10-points"
% Given a list Employees of employees, return sublist of Employees
% with employee with name=Name removed.  It is ok if Name does not exist.
% Hint: use a list comprehension 
delete_employee(Name, Employees) -> 
  I = [Z || Z <- Employees, Name =/= Z#employee.name], I.

%% returns list of pairs: { Args, Result }, where Args is list of
%% arguments to function and Result should be the value returned
%% by the function.
delete_employee_test_specs() -> 
    Es = ?Employees,
    [
     { delete_last, 
       [ jane, Es ], 
       [ ?Tom, ?Joan, ?Bill, ?John, ?Sue, ?Alice, ?Harry, ?Larry, ?Erwin] }, 
     { delete_intermediate,
       [ joan, Es ], 
       [ ?Tom, ?Bill, ?John, ?Sue, ?Alice, ?Harry, ?Larry, ?Erwin, ?Jane] }, 
     { delete_nonexisting, [ joe, Es ], Es }
    ].

-ifdef(test_delete_employee).
delete_employee_test_() ->
    make_tests(fun delete_employee/2, delete_employee_test_specs()).
-endif. %test_delete_employee

%--------------------------- upsert_employee/2 --------------------------

% #5: "10-points"
% Given a list Employees of employees, if Employees contains 
% an employee E1 with E1.name == E.name, then return Employees
% with E1 replaced by E, otherwise return Employees with
% [E] appended.
upsert_employee(E,[]) -> [E];
upsert_employee(E, [I|J]) ->
  if E#employee.name == I#employee.name -> [E | J];
    true-> [I|upsert_employee(E,J)]
  end.


%% returns list of pairs: { Args, Result }, where Args is list of
%% arguments to function and Result should be the value returned
%% by the function.
upsert_employee_test_specs() -> 
    Es = ?Employees,
    [ { upsert_existing_first, [?Tom1, Es], 
	[?Tom1, ?Joan, ?Bill, ?John, ?Sue, ?Alice, 
	 ?Harry, ?Larry, ?Erwin, ?Jane ] 
      },
      { upsert_existing_last, [?Jane1, Es], 
	[? Tom, ?Joan, ?Bill, ?John, ?Sue, ?Alice, 
	 ?Harry, ?Larry, ?Erwin, ?Jane1 ] 
      },
      { upsert_new, [?Joe1, Es], 
	[? Tom, ?Joan, ?Bill, ?John, ?Sue, ?Alice, 
	 ?Harry, ?Larry, ?Erwin, ?Jane, ?Joe1 ] 
      }
    ].

-ifdef(test_upsert_employee).
upsert_employee_test_() ->
    make_tests(fun upsert_employee/2, upsert_employee_test_specs()).
-endif. %test_upsert_employee

%--------------------------- find_employees/2 ---------------------------
% #6: "15-points"
% find_employees(Preds, Employees):
% Given a list Employees of employees and a list of predicates Preds
% where each predicate P in Preds has type Employee -> bool,
% return a sub-list of Employees containing those E in Employees
% for which all P in Preds return true.
% Restriction: may not use recursion.
% Hint: consider using a list comprehension with lists:all/2.
find_employees(Preds, Employees) ->[E || E <- Employees, lists:all(fun(P) -> P(E) end, Preds)].

find_employees_test_specs() -> 
  Es = ?Employees,
  [ { cs, [ [employee_has_dept(cs)], Es ], dept_employees3(cs, Es) },
    { cs_age, [ [employee_has_dept(cs), employee_has_age(33)], Es ],
      [ ?Tom, ?Alice, ?Larry ]
    },
    { cs_age_salary, 
      [ [ employee_has_dept(cs), 
	  employee_has_age(33), 
	  employee_has_salary(85000.00)
	], Es ],
      [ ?Tom, ?Alice ]
    },
    { name, [ [employee_has_name(erwin)], Es ], [ ?Erwin ] },
    { name_age, [ [employee_has_name(erwin), employee_has_age(33)], Es ], 
      [] 
    },
    { salary, [ [employee_has_salary(69500)], Es ], [?Bill, ?Larry] },
    { salary_none, [ [employee_has_salary(69501)], Es ], [] },
    { age, [ [employee_has_age(19)], Es ], [?Sue, ?Jane] },
    { age_none, [ [employee_has_age(20)], Es ], [] }
  ].

-ifdef(test_find_employees).
find_employees_test_() ->
    make_tests(fun find_employees/2, find_employees_test_specs()).
-endif. %test_find_employees


%--------------------------- employees_req/2 ----------------------------

% #7: "15-points"
% employees_req(Req, Employees):
% Return an ok-result of the form {ok, Result, EmployeesZ} or 
% an error-result of the form {err, ErrString, Employees}.
% Specifically, when Req matches:
%   { delete, Name }:     ok-result with Result = void and EmployeesZ =
%                         delete_employee(Employee, Employees).
%   { dump }:             ok-result with Result = Employees and 
%                         EmployeesZ = Employees.
%   { find, Preds }:      ok-result with Result = 
%                         find_employees(Preds, Employees)
%                         and EmployeesZ = Employees.
%   { read, Name }:       If Preds = [employee_has_name(Name)] and
%                         [Result] = find_employees(Preds, Employees), return
%                         an ok-result with EmployeesZ = Employees; otherwise
%                         return an error-result with a suitable ErrString.
%   { upsert, Employee }: ok-result with Result = void and 
%			  EmployeesZ = upsert_employee(Employee, Employees).
%   _:                    return an error-result with a suitable ErrString.
% Hint: use io_lib:format(Format, Args) to build suitable error strings,
% for example: lists:flatten(io_lib:format("bad Req ~p", [Req]))
employees_req(Req, Employees) -> 
  case Req of
    {Func , Name} when Func == delete ->
      {ok,void,delete_employee(Name,Employees)};
    {Func, Name} when Func == find -> 
      {ok,find_employees(Name,Employees),Employees};
    {Func, Employee} when Func == upsert ->
      {ok,void,upsert_employee(Employee,Employees)};
    {Func, Name} when Func == read ->
      case find_employees([employee_has_name(Name)],Employees) of
        [Result] -> {ok, Result, Employees};
              _ -> {err,lists:flatten(io_lib:format("bad Req ~p", [Req])),Employees}
            end;
    {Func} when Func == dump -> 
      {ok,Employees,Employees};
    _ ->
      {err,lists:flatten(io_lib:format("bad Req ~p",[Req])),Employees}
  end.

%% map upsert_employee_test_specs into args-result pairs suitable
%% for employees_req({upsert, _}, ...).
employees_req_upsert_test_specs() ->
  [ { Test, [ {upsert, Employee}, Employees ], { ok, void, Result } } ||
    { Test, [Employee, Employees], Result } <- upsert_employee_test_specs() ].


%% map delete_employee_test_specs into args-result pairs suitable
%% for employees_req({delete, _}, ...).
employees_req_delete_test_specs() ->
  [ { Test, [ {delete, Name}, Employees ], { ok, void, Result } } ||
    { Test, [Name, Employees], Result } <- delete_employee_test_specs() ].

%% map find_employees_test_specs into args-result pairs suitable
%% for employees_req({find, _}, ...).
employees_req_find_test_specs() ->
  [ { Test, [ {find, Preds}, Employees ], { ok, Result, Employees } } ||
    { Test, [Preds, Employees], Result } <- find_employees_test_specs() ].

ignore_err_message(Result) ->
    case Result of
      { Status, _Msg } -> { Status };
      { Status, _Msg, Rest } -> { Status, Rest }
    end.

employees_req_test_specs() ->
    % since these specs are used also by server, keep mutable tests last
    Es = ?Employees,
    [ { read_intermediate, [{ read, joan }, Es ], { ok, ?Joan, Es } },
      { read_last, [ { read, jane }, Es ], { ok, ?Jane, Es } },
      { dump, [ {dump}, Es ], { ok, Es, Es } },
      { read_nonexiting, [ { read, gary }, Es ], {err, Es}, 
	fun ignore_err_message/1 },
      { bad_req, [ { read1, joan }, Es ], {err, Es}, fun ignore_err_message/1 }
    ] ++
    employees_req_find_test_specs() ++
    employees_req_upsert_test_specs() ++
    employees_req_delete_test_specs().

-ifdef(test_employees_req).
employees_req_test_() ->
    make_tests(fun employees_req/2, employees_req_test_specs()).
-endif. %test_employees_req
