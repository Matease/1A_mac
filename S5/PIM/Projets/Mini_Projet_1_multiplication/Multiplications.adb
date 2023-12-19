--------------------------------------------------------------------------------
--  Auteur   : Mathis Sigier
--  Objectif : Permettre de faire réviser la ou les table(s) de multiplications d'entier(s) entre 1 et 10

--------------------------------------------------------------------------------

with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Calendar;          use Ada.Calendar;
with Ada.Numerics.Discrete_Random;
with Ada.Calendar; use Ada.Calendar;


procedure Multiplications is
	Rejouer: Character; --- variable pour continuer à réviser ou non
	t, nb1, nb2: integer; --- t: total de bonnes réponses, nb1,nb2: variables pour la multiplication posée
	res,n, z: integer; --- res stocke le résultat donné par l'utilisateur, n est la table révisée
	duree_tot: duration;
	duree_max: duration;
	Debut, Fin: time;



	generic
		Lower_Bound, Upper_Bound  : Integer;	-- bounds in which random numbers are generated
		-- { Lower_Bound <= Upper_Bound }
	
	package Alea is
	
		-- Compute a random number in the range Lower_Bound..Upper_Bound.
		--
		-- Notice that Ada advocates the definition of a range type in such a case
		-- to ensure that the type reflects the real possible values.
		procedure Get_Random_Number (Resultat : out Integer);
	
	end Alea;

	
	package body Alea is
	
		subtype Intervalle is Integer range Lower_Bound..Upper_Bound;
	
		package  Generateur_P is
			new Ada.Numerics.Discrete_Random (Intervalle);
		use Generateur_P;
	
		Generateur : Generateur_P.Generator;
	
		procedure Get_Random_Number (Resultat : out Integer) is
		begin
			Resultat := Random (Generateur);
		end Get_Random_Number;
	
	begin
		Reset(Generateur);
	end Alea;
    
    package Mon_Alea is
		new Alea (0, 10);  -- generateur de nombre dans l'intervalle [0, 10]
	use Mon_Alea;

	

    begin
        Rejouer:='o';
        --- Réviser la ou les table(s) de multiplications
        loop
            --- Demande d'un entier n adequate
            Put("Table à réviser : ");
            Get(n);
            While n<0 or n>10 loop
                put("Impossible. La table doit être entre 0 et 10.");
                put("Table à réviser : ");
                get(n);
            end loop;
            --- Questionner sur 10 multiplications de la table de n
            t:=0;
		
		duree_tot := 0.0; --- variable de la durée totale d'execution de la revision
		duree_max := 0.0; --- variable stockant la réponse obtenue après le plus de temps
		
           for k in 1..10 loop
                --- Poser une multiplication de la table de n
		Get_Random_Number (nb1);
		if k /=1 then
			while nb1=nb2 loop		--on s'assure ici que la même multiplication ne soit pas posée deux fois
				Get_Random_Number(nb1);
			end loop;
		end if;
		nb2 := nb1;
                put("(M" & integer'image(k) & ") " & integer'image(n) & '*' & integer'image(nb1) & " ?");
		Debut := Clock; --- debut de la réponse
                get(res);
		Fin := Clock; --- fin de la réponse
		duree_tot := duree_tot + Fin - Debut;
		if Fin - Debut >= duree_max then
			duree_max := Fin - Debut;
			z := nb1; --- on stocke la multiplication la plus hésitante

		end if;
                --- Vérifier la réponse
                if n*nb1=res then
                    t:=t+1; --- on ajoute une bonne réponse
                    Put("Bravo!");
                else
                    put("Mauvaise réponse");
                end if;
            end loop;
	    --- donner la reponse la plus hésitante
		put("la réponse la plus hésitante est pour" & integer'image(n) & '*' & integer'image(z) & ' ');
            --- Commenter le total
            case t is
                when 10 => put("Aucune erreur. Excellent !");
                when 9 => put("Une seule erreur. Très bien.");
                when 0 => put("Tout est faux ! Volontaire ?");
                when 6|7|8 => put(integer'image(10-t) & " erreurs. Il faut encore travailler la table de " & integer'image(n) & '.');
                when 1|2|3|4|5 => put("Seulement " & integer'image(t) & "bonnes réponses. Il faut apprendre la table de " & integer'image(n) & " !");
		when others => Null;
            end case;
            Put("On continue (o/n) ?");
            Get(Rejouer);    
            exit when not(Rejouer='o' or Rejouer ='O');
        end loop;
end Multiplications;

