-- with Ada.Text_IO;            use Ada.Text_IO;
with SDA_Exceptions;         use SDA_Exceptions;
with Ada.Unchecked_Deallocation;

package body LCA is

	procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);


	procedure Initialiser(Sda: out T_LCA) is
	begin
		Sda := null;
	end Initialiser;


	function Est_Vide (Sda : T_LCA) return Boolean is
	begin
		return Sda = null;
	end;


	function Taille (Sda : in T_LCA) return Integer is
	begin
		if Sda = Null then
            return 0;
        else
            return(1+Taille(Sda.all.suivant));
        end if;
	end Taille;


	procedure Enregistrer (Sda : in out T_LCA ; Cle : in T_Cle ; Donnee : in T_Donnee) is
	begin
		if Sda = Null then
            Sda:=New T_Cellule;
            Sda.all.Cle := Cle;
            Sda.all.Donnee := Donnee;
            Sda.all.suivant := Null;
        elsif Sda.all.Cle=cle then
            Sda.all.Donnee := Donnee;
        else
            Enregistrer(Sda.all.suivant,Cle,Donnee);
        end if;
	end Enregistrer;


	function Cle_Presente (Sda : in T_LCA ; Cle : in T_Cle) return Boolean is
	begin
		if Sda=Null then
            return False;
        elsif Sda.all.Cle=Cle then
            return True;
        else
            return Cle_Presente(Sda.all.Suivant,Cle);
        end if;
	end;


	function La_Donnee (Sda : in T_LCA ; Cle : in T_Cle) return T_Donnee is
	begin
		if Sda=Null then
            raise Cle_Absente_Exception;
        elsif Sda.all.Cle=Cle then
            return Sda.all.Donnee;
        else
            return La_Donnee(Sda.all.Suivant,Cle);
        end if;
	end La_Donnee;


	procedure Supprimer (Sda : in out T_LCA ; Cle : in T_Cle) is
	begin
		if not(Cle_Presente(Sda,Cle)) then
            raise Cle_Absente_Exception;
        elsif Sda.all.Cle=Cle then
            Sda := Sda.all.suivant;
        end if;
	end Supprimer;


	procedure Vider (Sda : in out T_LCA) is
	begin
		if Sda=Null then
            Null;
        else
            Vider(Sda.all.Suivant);
            Free(Sda);
        end if;
	end Vider;


	procedure Pour_Chaque (Sda : in T_LCA) is
	begin
        if Sda = Null then
            Null;
        else
            Traiter(Sda.all.Cle, Sda.all.Donnee);
            Pour_Chaque(Sda.all.Suivant);
        end if;
        exception
            when others => Pour_Chaque(Sda.all.Suivant);
    end Pour_Chaque;


end LCA;
