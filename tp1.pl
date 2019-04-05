%comment sont modélisées la situation initiale et la situation finale du système ?
initial_state(I),
final_state(F).

% quelle structure de données (quel type de terme Prolog) permettrait de représenter une situation du Taquin 4x4, par exemple la situation finale suivante 
[[1, 2, 3, 4],
[5, 6, 7, 8],
[9, 10, 11, 12],
[13, 14, 15, vide]]

%c. quelle requête permet de déterminer chaque situation suivante (successeur) S de l'état initial du Taquin 3×3 ? Il doit y avoir 3 réponses possibles. 
initial_state(I), rule(Rule,C,I,Next),write_state(Next)

% quelle requête permet d'avoir les 3 réponses d'un coup regroupées dans une liste ? (cf. findall/3 en Annexe). 
initial_state(I), findall(Next,rule(Rule,C,I,Next), Possibilities), write_state(Possibilities)

% quelle requête permet d'avoir la liste de tous les couples [A, S] tels que S est la situation qui résulte de l'action A appliquée dans l'état initial 
initial_state(I), findall([Rule,Next],rule(Rule,_,I,Next), Possibilities), write_state(Possibilities)