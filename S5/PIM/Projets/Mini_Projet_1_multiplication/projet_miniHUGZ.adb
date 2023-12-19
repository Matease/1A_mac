with Ada.Text_IO; use Ada.Text_IO;
With Ada.Integer_Text_IO ; use Ada.integer_text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Calendar; use Ada.Calendar;

		-- REVISONS LES MULTIPLICATIONS --
procedure projet_miniHUGZ is

   table, res, c, v: integer;
   rdom1, rdom2: integer;
   rejouer: Character;
   duree_tot: duration;
   duree_max: duration;
   Debut, Fin: time;

generic
  	 	Lower_Bound, Upper_Bound : Integer; -- bounds in which random numbers are generated
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

		package Generateur_P is
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
		new Alea (0, 10); -- gÈnÈrateur de nombre dans l'intervalle [5, 15]
	use Mon_Alea;

Begin

	rejouer := 'o';
	boucle_rejouer: loop --création de la boucle pour rejouer
		Put("Quelle table révisons nous?");
      		Get(table);
		while table > 10 or table < 0 loop --on vérifie que la table demandée est valide, sinon on la redemande
			Put("Impossible, la table doit être entre 0 et 10.");
			Put_line(" Quelle table révisons nous?");
         		get(table);
         		New_Line;
      		end loop;

		v := 0; -- variable qui va stocker la table où la réponse est la plus hésitante
		c := 0; -- initialisation du compteur du nombre de multipliication posÈes
		duree_max := 0.0;
		duree_tot := 0.0;
		for i in 1..10 loop
			Get_Random_Number (rdom1);
			if i /=1 then
				while rdom1=rdom2 loop		--on s'assure ici que la même multiplication ne soit pas posée deux fois
					Get_Random_Number (rdom1);
				end loop;
			end if;
			rdom2 := rdom1;
			Put("(M" & integer'image(i) & ")" & integer'image(table) & "*" & integer'image(rdom1) & "?");
			Debut := Clock;
			Get(res);
			Fin := Clock;
			duree_tot := duree_tot + Fin - Debut;
			if Fin - Debut >= duree_max then
				duree_max := Fin - Debut;
				v := rdom1;
			end if;
			if rdom1 * table = res then
				c := c +1; -- La réponse est bonne, on ajoute des points au résultat final
     				Put_line("Bravo!");
            			New_Line;
			else
            			Put_line("Mauvaise réponse!");
            			New_Line;
			end if;
			end loop;
			case c is
				when 10 => Put_line("Aucune erreur. Excellent!");
				when 9 => Put_line("Une seule erreur. Très bien.");
				when 0 => Put_line("Tout est faux! Volontaire?");
				when 1 .. 5 => Put_line("Seulement" & integer'image(c) & "bonnes rÈponses. Il faut apprendre la table de" & integer'image(table));
				when 6 .. 8 => Put_line(integer'image(10-c) & " erreurs. Il faut encore travailler la table de:" & integer'image(table));
				when others => Null;
			end case;
			if duree_max >= duration(1)+duree_tot/10 then
				New_line;
				Put("Des hésitations sur la table de" & integer'image(v) & " : " & duration'image(duree_max) & "secondes contre " &
duration'image(duree_tot/10) & " en moyenne. Il faut certainement la réviser.");
			end if;
			New_line;
			Put(" Souhaitez-vous vous entraîner de nouveau? (o/n)");
			get(rejouer);
		exit boucle_rejouer when rejouer /= 'o' and rejouer /= 'O';
		end loop boucle_rejouer;
end projet_miniHUGZ;
