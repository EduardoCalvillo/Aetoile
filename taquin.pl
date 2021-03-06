:- lib(listut).       % a placer en commentaire si on utilise Swi-Prolog
                      % (le predicat delete/3 est predefini)
                      
                      % Indispensable dans le cas de ECLiPSe Prolog
                      % (le predicat delete/3 fait partie de la librairie listut)
                      
%***************************
%DESCRIPTION DU JEU DU TAKIN
%***************************

   %********************
   % ETAT INITIAL DU JEU
   %********************   

initial_state([ [a, b, c],
                [g, h, d],
                [vide,f,e] ]). % h=2, f*=2

initial_state1([ [b, h, c],     % EXEMPLE
                [a, f, d],     % DU COURS
                [g,vide,e] ]). % h=5 = f* = 5actions

initial_state2([ [b, c, d],
                [a,vide,g],
                [f, h, e]  ]). % h=10 f*=10
			
initial_state3([ [f, g, a],
                [h,vide,b],
                [d, c, e]  ]). % h=16, f*=20
		
initial_state4([ [e, f, g],
                [d,vide,h],
                [c, b, a]  ]). % h=24, f*=30 

  

   %******************
   % ETAT FINAL DU JEU
   %******************
   
final_state([[a, b,  c],
             [h,vide,d],
             [g, f,  e]]).

   %********************
   % AFFICHAGE D'UN ETAT
   %********************

write_state([]).
write_state([Line|Rest]) :-
   writeln(Line),
   write_state(Rest).
   

%**********************************************
% REGLES DE DEPLACEMENT (up, down, left, right)             
%**********************************************
   % format :   rule(+Rule_Name, ?Rule_Cost, +Current_State, ?Next_State)
   
rule(up,   1, S1, S2) :-
   vertical_permutation(_X,vide,S1,S2).

rule(down, 1, S1, S2) :-
   vertical_permutation(vide,_X,S1,S2).

rule(left, 1, S1, S2) :-
   horizontal_permutation(_X,vide,S1,S2).

rule(right,1, S1, S2) :-
   horizontal_permutation(vide,_X,S1,S2).

   %***********************
   % Deplacement horizontal            
   %***********************
   
horizontal_permutation(X,Y,S1,S2) :-
   append(Above,[Line1|Rest], S1),
   exchange(X,Y,Line1,Line2),
   append(Above,[Line2|Rest], S2).

   %***********************************************
   % Echange de 2 objets consecutifs dans une liste             
   %***********************************************
   
exchange(X,Y,[X,Y|List], [Y,X|List]).
exchange(X,Y,[Z|List1],  [Z|List2] ):-
   exchange(X,Y,List1,List2).

   %*********************
   % Deplacement vertical            
   %*********************
   
vertical_permutation(X,Y,S1,S2) :-
   append(Above, [Line1,Line2|Below], S1), % decompose S1
   delete(N,X,Line1,Rest1),    % enleve X en position N a Line1,   donne Rest1
   delete(N,Y,Line2,Rest2),    % enleve Y en position N a Line2,   donne Rest2
   delete(N,Y,Line3,Rest1),    % insere Y en position N dans Rest1 donne Line3
   delete(N,X,Line4,Rest2),    % insere X en position N dans Rest2 donne Line4
   append(Above, [Line3,Line4|Below], S2). % recompose S2 

   %***********************************************************************
   % Retrait d'une occurrence X en position N dans une liste L (resultat R) 
   %***********************************************************************
   % use case 1 :   delete(?N,?X,+L,?R)
   % use case 2 :   delete(?N,?X,?L,+R)   
   
delete(1,X,[X|L], L).
delete(N,X,[Y|L], [Y|R]) :-
   delete(N1,X,L,R),
   N is N1 + 1.

   %**********************************
   % HEURISTIQUES (PARTIE A COMPLETER)
   %**********************************


heuristique(U,H) :-
    heuristique2(U, H).  % utilisee ( 1 ou 2)  
   
   %****************
   %HEURISTIQUE no 1
   %****************
   
   % Calcul du nombre de pieces mal placees dans l'etat courant U
   % par rapport a l'etat final F
   
      
diff_l([],[],0).
diff_l([Deb1|Rest1],[Deb2|Rest2], Somme):-
   ((Deb1=Deb2;Deb1=vide)->
         diff_l(Rest1, Rest2, Somme);
         diff_l(Rest1, Rest2, Nsomme), Somme is Nsomme+1
   ).
  
diff_m([],[], 0).
diff_m([L1|Rest1],[L2|Rest2],S):-
    diff_l(L1,L2,S2),
    diff_m(Rest1, Rest2, S1),
    S is S1 + S2.

heuristique1(U, H) :- 
   final_state(F),
   diff_m(U,F,H).               
      
      %****************
      %HEURISTIQUE no 2
      %****************
      
      % Somme sur l'ensemble des pieces des distances de Manhattan
      % entre la position courante de la piece et sa positon dans l'etat final
      
coordonnee([A|_],Find,X,1):-
   nth1(X, A,Find),!.

coordonnee([_|Z],Find,X,Y):-
   coordonnee(Z, Find, X, Yi),
   Y is Yi+1.

heuristique2(U, H) :-      
   final_state(F),
   diff_m2(U,U,F,H).             

diff_l2([], _, _,0).
diff_l2([Deb1|Rest1],I, F, Somme):-
   ((Deb1=vide)->
   diff_l2(Rest1, I, F, Somme)
   ;
   coordonnee(I, Deb1, X1, Y1),
   coordonnee(F, Deb1, X2, Y2),
   Distance is abs(X1-X2)+ abs(Y1-Y2),
   diff_l2(Rest1, I, F, SommeF),
   Somme is SommeF + Distance
      ).

diff_m2([], _, _, 0).
diff_m2([L1|Rest1], I, F, S):-
   diff_l2(L1,I,F,S2),
   diff_m2(Rest1,I,F, S1),
   S is S1 + S2.