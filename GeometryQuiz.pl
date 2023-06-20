% �������
:- use_module(library(pce)).


border_color([red, green, blue]).
outer_fig(["square", "triangle", "circle"]).
inner_fig(["triangle", "circle", "square"]).

% number (E, N, L): N - ���������� ����� �������� E � ������ L
% ��������� �������� � � ������� ������ � ������� N
number(X, 1, [X | _]).
number(X, K, [_ | T]) :-
    number(X, K1, T), K is K1 + 1.
    
select_color(X, N) :- border_color(L), number(X, N, L).
select_out(X, N) :- outer_fig(L), number(X, N, L).
select_in(X, N) :- inner_fig(L), number(X, N, L).


% ������� ���� ������ �� �������� ���������� ����� ������� ������,
% ������� � ��������� ������
create_figure([B, O, I], Nb, No, Ni) :-
    select_color(B, Nb),
    select_out(O, No),
    select_in(I, Ni).
                          

% ������� ���� ��� �� 3 ����� � ������������� ���������, ��������� ��������� �������
create_row([F1, F2, F3]) :- random(1, 4, Const_dim),
      %print(Const_dim),
      % � ���� ���������� ���� �������
      (Const_dim == 1,
         random(1, 4, Nb),
         random(1, 4, No1),
         No2 is (No1 mod 3) + 1,
         No3 is ((No1 + 1) mod 3) + 1,
         random(1, 4, Ni1),
         Ni2 is (Ni1 mod 3) + 1,
         Ni3 is ((Ni1 + 1) mod 3) + 1,
         %print(Nb),
         create_figure(F1, Nb, No1, Ni1),
         create_figure(F2, Nb, No2, Ni2),
         create_figure(F3, Nb, No3, Ni3);
      % � ���� ���������� ������� ������
       Const_dim == 2,
         random(1, 4, No),
         random(1, 4, Nb1),
         Nb2 is (Nb1 mod 3) + 1,
         Nb3 is ((Nb1 + 1) mod 3) + 1,
         random(1, 4, Ni1),
         Ni2 is (Ni1 mod 3) + 1,
         Ni3 is ((Ni1 + 1) mod 3) + 1,
         %print(No),
         create_figure(F1, Nb1, No, Ni1),
         create_figure(F2, Nb2, No, Ni2),
         create_figure(F3, Nb3, No, Ni3);
      % � ���� ���������� ���������� ������
       Const_dim == 3,
         random(1, 4, Ni),
         random(1, 6, Nb1),
         Nb2 is (Nb1 mod 3) + 1,
         Nb3 is ((Nb1 + 1) mod 3) + 1,
         random(1, 4, No1),
         No2 is (No1 mod 3) + 1,
         No3 is ((No1 + 1) mod 3) + 1,
         %print(Ni),
         create_figure(F1, Nb1, No1, Ni),
         create_figure(F2, Nb2, No2, Ni),
         create_figure(F3, Nb3, No3, Ni)).

 create_matrix(R1, R2, R3) :-
      create_row(R1),
      create_row(R2),
      create_row(R3).
      

% �������� ��������� ��������� �������
create_random([F1, F2, F3]) :-
       random(1, 4, B1), random(1, 4, B2), random(1, 4, B3),
       random(1, 4, O1), random(1, 4, O2), random(1, 4, O3),
       random(1, 4, I1), random(1, 4, I2), random(1, 4, I3),
       create_figure(F1, B1, O1, I1),
       create_figure(F2, B2, O2, I2),
       create_figure(F3, B3, O3, I3).
       

% ��������� ���� �����
drow_row([], _, _, _).
drow_row([F | R], Where, ShiftX, ShiftY) :-
                                   drow_fig(F, Where, ShiftX, ShiftY),
                                   Shift1 is ShiftX + 130,
                                   drow_row(R, Where, Shift1, ShiftY).

% ��������� ��������� ������ �� �������� ����������
drow_fig([B, O, I], Where, ShiftX, ShiftY) :-
       (O == "square",
        new(Outer, box(100, 100));
       
        O == "circle",
        new(Outer, circle(100));
        
        O == "triangle",
        new(Outer, path),
        send_list(Outer, append, [point(0,0),point(100,0),point(50,100), point(0, 0)])
       ),
       
       send(Outer, colour, colour(B)),
       
       (I == "square",
        new(Inner, box(30, 30));
        
        I == "circle",
        new(Inner, circle(30));

        I == "triangle",
        new(Inner, path),
        send_list(Inner, append, [point(0,0),point(30,0),point(15,30), point(0, 0)])
        ),
        
        send(Where, display, Outer, point(ShiftX, ShiftY)),
        InShiftX is ShiftX + 35,
        InShiftY is ShiftY + 32,
        send(Where, display, Inner, point(InShiftX, InShiftY)).



%-------------------------------------------------------------------------------
% �������� �������, ��������� ��������� ?- graph.
graph :-
      new(Pict, picture("�����������")),
      send(Pict, width(960)),
      send(Pict, height(400)),
      
      new(DW, dialog("Testing")),
      send(DW, append, Pict),
      
      % chain - ������ ������ � XPCE
      new(TrueAns, chain),
      
      send(DW, append, new(label)),
      send(DW, append, new(Answer, text_item("Answer", "your guess here"))),
      send(Answer, type, int),

      new(Button, button("Generate", message(@prolog, create_mat, Answer, Pict, TrueAns))),
      send(DW, append, Button),

      new(Check, button("Check answer", message(@prolog, check_ans, Pict, Answer, Answer?selection, TrueAns))),
      send(DW, append, Check),
      
      
      new(Show, button("Show answer", message(@prolog, show_ans))),
      send(DW, append, Show),

      send(DW, open).




 % �������� �������
create_mat(Answer, Pict, TrueAns) :-
      send(Answer, value, "your guess here"),
      send(TrueAns, clear),
      
      create_matrix(R1, R2, R3),
      writeln(R1),
      writeln(R2),
      writeln(R3),

      
      %��������� ������

      create_random(Rand1),
      number(TrueAnsVal, 3, R3),
      append(Rand1, [TrueAnsVal], AllAns),
      random_permutation(AllAns, AllAnsRand),
      writeln(AllAnsRand),
      
      number(TrueAnsVal, TrueAnsN, AllAnsRand),
      writeln(TrueAnsN),
      send(TrueAns, append, TrueAnsN),
      
      send(Pict, clear),

      % ��������� ����� �� ������� � ���� ���������
      drow_row(R1, Pict, 10, 30),
      drow_row(R2, Pict, 10, 140),
      drow_row(R3, Pict, 10, 250),
      drow_row(AllAnsRand, Pict, 450, 140),
      
      % ��������� ����
      new(T1, text("1")),
      new(T2, text("2")),
      new(T3, text("3")),
      new(T4, text("4")),
      
      send(Pict, display, T1, point(500, 250)),
      send(Pict, display, T2, point(630, 250)),
      send(Pict, display, T3, point(760, 250)),
      send(Pict, display, T4, point(890, 250)),

      % �������� ������
      new(@blank, box(101, 101)),
      send(@blank, colour, colour(white)),
      send(@blank, fill_pattern, colour(white)),
      send(Pict, display, @blank, point(270, 250)),
      new(@qMark, text("?")),
      send(Pict, display, @qMark, point(300, 280)).
      
show_ans :- send(@blank, destroy), send(@qMark, destroy).

check_ans(Pict, Answer, Ans, TrueAns) :-
        %�������������� XPCE ������ � ������ �������
        chain_list(TrueAns, List_True),
        %writeln(List_True),
        
       ([Ans] = List_True,
        send(Answer, clear),
        send(Answer, value, "Correct, generate new"),
        send(TrueAns, clear),
        send(Pict, clear),
        writeln("Right");
        
        send(Answer, clear),
        send(Answer, value, "Wrong, come again"),
        writeln("Wrong")).

