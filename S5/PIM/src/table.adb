with Ada.Unchecked_Deallocation;
with Table_Exceptions;         use Table_Exceptions;
with Ada.Text_IO;            use Ada.Text_IO;

package body Table is

    procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Table);

    -- Initialiser une Table. La table est vide
    procedure Initialiser(Table : out T_Table) is
    begin
        Table := null;
    end Initialiser;

    function Est_Vide_T (Table : T_Table) return Boolean is
    begin
        return Table = null;
    end Est_Vide_T;



   procedure Enregistrer (Table : in out T_Table; Route : in T_route) is

    begin
        if Est_Vide_T(Table) then
            Table := new T_Cellule'(Route,Table);
        elsif Table.all.Route.Adresse = Route.Adresse then
            Table.all.Route.Masque := Route.Masque;
         Table.all.Route.Interface_Associee := Route.Interface_Associee;

        else
            Enregistrer(Table.all.Suivant,Route);
        end if;
    end Enregistrer;



    procedure Vider (Table : in out T_Table) is
    begin
        if not(Est_Vide_T(Table)) then
            Vider(Table.all.Suivant);
            Free(Table);
        else
            null;
        end if;
   end Vider;


   function Chercher_Route (Table : in T_Table ; Paquet : in T_adresse_ip) return T_Route is
        Table2 : T_Table := Table;
        Route_Finale : T_Route;
    begin
        Initialiser(Route_Finale.Masque, 0, 0, 0, 0);
        while Table2 /= null loop
            if Compatible(Paquet, Table2.all.Route.Masque, Table2.all.Route.Adresse) and Table2.all.Route.Masque >= Route_Finale.Masque then
                Route_Finale.Adresse := Paquet;
                Route_Finale.Masque := Table2.all.Route.Masque;
                Route_Finale.Interface_Associee := Table2.all.Route.Interface_Associee;
            end if;
            Table2 := Table2.all.Suivant;
        end loop;
        return Route_Finale;
    end Chercher_Route;
end Table;
