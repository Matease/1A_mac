with Ada.Unchecked_Deallocation;
with Table_Exceptions;         use Table_Exceptions;
with Ada.Text_IO;            use Ada.Text_IO;

package body Table is

    procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Route, Name => T_Table);

    -- Initialiser_Table une Table. La table est vide
    procedure Initialiser_Table(Table : out T_Table) is
    begin
        Table := null;
    end Initialiser_Table;

    function Est_Vide_T (Table : T_Table) return Boolean is
    begin
        return Table = null;
    end Est_Vide_T;

    function Taille (Table : in T_Table) return Integer is
    begin
        if Est_Vide_T(Table) then
            return 0;
        else
            return(1+Taille(Table.all.Suivant));
        end if;
    end Taille;

    procedure Enregistrer (Table : in out T_Table; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String) is
    begin
        if Est_Vide_T(Table) then
            Table.all.Destination := Destination;
            Table.all.Masque := Masque;
            Table.all.Interf := Interf;
            Table.all.Suivant := null;
        elsif Table.all.Destination = Destination then
            Table.all.Masque := Masque;
            Table.all.Interf := Interf;
        else
            Enregistrer(Table.all.Suivant, Destination, Masque, Interf);
        end if;
    end Enregistrer;

    function Route_Presente (Table : in T_Table ; Destination : in T_adresse_ip) return Boolean is
    begin
        if Est_Vide_T(Table) then
            return False;
        elsif Table.all.Destination = Destination then
            return True;
        else
            return Route_Presente (Table.all.Suivant, Destination);
        end if;
    end Route_Presente;

    function Le_Masque (Table : in T_Table ; Destination : in T_adresse_ip) return T_adresse_ip is
    begin
        if Est_Vide_T(Table) then
            raise Destination_Absente_Exception;
        elsif Table.all.Destination = Destination then
            return Table.all.Masque;
        else
            return Le_Masque (Table.all.Suivant, Destination);
        end if;
    end Le_Masque;

    function L_Interface (Table : in T_Table ; Destination : in T_adresse_ip) return Unbounded_String is
    begin
       if Est_Vide_T(Table) then
            raise Destination_Absente_Exception;
        elsif Table.all.Destination = Destination then
            return Table.all.Interf;
        else
            return L_Interface (Table.all.Suivant, Destination);
        end if;
    end L_Interface;

    procedure Supprimer (Table : in out T_Table ; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String) is
    begin
        if not(Route_Presente(Table, Destination)) then
            raise Destination_Absente_Exception;
        elsif Table.all.Destination = Destination then
            Table := Table.all.Suivant;
        else
            Supprimer(Table, Destination, Masque, Interf);
        end if;
    end Supprimer;

    procedure Vider (Table : in out T_Table) is
    begin
        if not(Est_Vide_T(Table)) then
            Vider(Table.all.Suivant);
            Free(Table);
        else
            null;
        end if;
   end Vider;


   function Chercher_Route (Table : in T_Table ; Paquet : in T_adresse_ip) return Unbounded_String is
        Table2 : T_Table := Table;
        Masque : T_adresse_ip;
        Interface_Finale : Unbounded_String;
    begin
        Initialiser_Table(Masque, 0, 0, 0, 0);
        while Table2 /= null loop
            if Compatible(Paquet, Table2.all.Masque, Table2.all.Destination) and Table2.all.Masque >= Masque then
                Masque := Table2.all.Masque;
                Interface_Finale := Table2.all.Interf;
            end if;
            Table2 := Table2.all.Suivant;
        end loop;
        return Interface_Finale;
    end Chercher_Route;
end Table;
