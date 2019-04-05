:- [taquin].
:- [avl].

main(S0):-
	%* calculer F H G
	heuristique(S0,H0),
	G0 is 0,
	F0 is H0+G0,
	empty(P),
	empty(Q),
	Ef = [[F0,H0,G0], S0],
	insert(Ef,P,Pf),
	Eu = [S0,[F0,H0,G0], nil, nil],
	insert(Eu,P,Pu),
	aetoile(Pf,Pu,Q).

aetoile([],[],_):- write("PAS de SOLUTION: L’ETAT FINAL N’EST PAS ATTEIGNABLE!").

aetoile(Pf,Pu,Q):-
	suppress_min([V,U],Pf,_),
	(
	final_state(U) ->
		belongs([U,V,Pere,A],Pu),
		insert([U,V,Pere,A],Q,Qf),
		afficher_solution(Qf,[U,V,Pere,A])
	;
		suppress_min([[Ff,Hf,Gf],Uf],Pf,IntermPf),
		belongs([Uf,[Ff,Hf,Gf],Pere,Action],Pu),
		suppress([Uf,[Ff,Hf,Gf],Pere,Action],Pu,IntermPu),
		% developper U.
		find_successors(Uf,L),
		expand(Uf,Gf,L,Val),
			%developper S
			loop_successors(Val,Q,IntermPu,IntermPf,NewPu,NewPf),
			%developper S
		
		% developper U.
		insert([Uf,[Ff,Hf,Gf],Pere,Action], Q, NewQ),
		aetoile(NewPf, NewPu, NewQ)
	).


find_successors(E,L):-
	findall([A,X], rule(A,1,E,X), L).

  /************************************** EXPAND ************************************************/
 /* ( +Etat_à_Developper, +Somme_Jusqua_Maintenant, +Succeseurs_Possibles, ?Noeud_Succeseur )  */
/**********************************************************************************************/
expand(_,_,[],[]).
expand(U, Gf, [[Action,Etat]|R], [[Etat,[F,H,Gs],U,Action]|Reste]):-
	heuristique(Etat, H),
	Gs is Gf + 1,
	F is H+Gs,
	expand(U,Gf,R,Reste).

  /********************************* LOOP SUCCESORS ******************************/
 /* ( +[Succeur_Actuel | R], +Q, +Pu, +Pf, +ValeursPu, ?Pu_Finale, ?Pf_Finale ) */
/*******************************************************************************/
loop_successors([],_,Final_Pu, Final_Pf,Final_Pu, Final_Pf).
loop_successors([[Etat,[F,H,G],U,Action]|R],Q,Pu,Pf, Final_Pu, Final_Pf):-
	((belongs([Etat,_,_,_],Q)) ->
		loop_successors(R,Q,Pu,Pf,Final_Pu,Final_Pf)
	;
		(
			(belongs([Etat,[Fp,Hp,Gp],_,_],Pu)) ->
				part2([[Etat,[F,H,G],U,Action]|R],Q,Pu,Pf,[Fp,Hp,Gp], Final_Pu, Final_Pf )
			;
				insert([Etat,[F,H,G],U,Action],Pu,NewPu),
				insert([[F,H,G],Etat],Pf,NewPf),
				loop_successors(R,Q,NewPu,NewPf, Final_Pu, Final_Pf)
			)
		).

  /***************************** NOEUD ACTUEL VS PU ******************************/
 /* ( +[Succeur_Actuel | R], +Q, +Pu, +Pf, +ValeursPu, ?Pu_Finale, ?Pf_Finale ) */
/*******************************************************************************/
part2([[Etat,[F,H,G],U,Action]|R],Q,Pu,Pf,[Fp,Hp,Gp], Final_Pu, Final_Pf):-
	(([F,H,G]@<[Fp,Hp,Gp])->
		suppress([Etat,_,_,_],Pu,IntermPu),
		insert([Etat,[F,H,G],U,Action],IntermPu,NewPu),
		suppress([[Fp,Hp,Gp],Etat],Pf, IntermPf),
		insert([[F,H,G],Etat],IntermPf, NewPf),
		loop_successors(R,Q,NewPu,NewPf, Final_Pu, Final_Pf)
	;
		loop_successors(R,Q,Pu,Pf, Final_Pu, Final_Pf)
	).


  /************ AFFICHER ***************/
 /* ( +Q, +[U,Valeurs,Pere,Action] )  */
/*************************************/



%Enfin Q permet de reconstruire la solution lorsque l’algorithme atteint l’état terminal F : 
%pour reconstruire le chemin optimal il suffit deremonter depuis l’état final F vers l’état initial (à l’envers)
%en parcourant les liens pere(F), pere(pere(F)),  ... etc ... jusqu’à I.

afficher_solution(Q,[Actuel,V,Pere,A]):-
	suppress([Actuel,V,Pere,A],Q,Qp),

	(
		belongs([Pere,Vp,Perep,Ap],Qp) -> 
		afficher_solution(Qp,[Pere, Vp, Perep, Ap]),
		writeln(A)
	;
		writeln("Debut")
	).