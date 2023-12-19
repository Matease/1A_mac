with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Adresse_IP; use Adresse_IP;
with Table; use Table;
with Ada.Command_Line; use Ada.Command_Line;

procedure routeur is


    procedure Importer_Table (Table : in out T_Table ; fichier_table : in Unbounded_String) is
        FD_Table : File_Type;
        Interf : Unbounded_String;
        Destination, Masque : T_adresse_ip;
    begin
        Open(FD_Table, In_File, To_String(fichier_table));
        
        Initialiser (Table);

        while not End_Of_File(FD_Table) loop

            Lire_Adresse (Destination, FD_Table);
            Lire_Adresse (Masque, FD_Table);
            Interf := Get_line(FD_Table);
            Trim(Interf, Both); -- On supprime les espaces blancs

            Enregistrer(Table, Destination, Masque, Interf);

        end loop;

        Close(FD_Table);
    end Importer_Table;


    fichier_table : Unbounded_String;
    fichier_paquet : Unbounded_String;
    fichier_resultat : Unbounded_String; 
    politique : Unbounded_String;
    Table : T_Table;
    Paquets : File_Type;
    Paquet : T_adresse_ip;
    Resultat : File_Type;
    Stat : Boolean;
    Indice_arg : Integer;
    TailleC : Integer; -- Taille du cache

begin

    -- Valeurs par défaut
    fichier_table :=  To_Unbounded_String("table.txt");
    fichier_paquet := To_Unbounded_String("paquet.txt");
    fichier_resultat := To_Unbounded_String("resultats.txt");
    TailleC := 10;


    -- Traitement de la ligne de commande
    if Argument_Count /=1 then
      Put("usage : " & Command_Name & "-t <fichier de la table>" & "-p <fichier des paquets" & "-r <fichier bilan>");
    else
      Indice_arg := 0;
      while (Indice_arg <= Argument_Count) loop
        if Argument(Indice_arg) = "-p" then
			      politique := To_Unbounded_String(argument(Indice_arg+1));
        elsif Argument(Indice_arg) = "-s" then
			      Stat := True;
        elsif Argument(Indice_arg) = "-S" then
			      Stat := False;
        elsif Argument(Indice_arg) = "-r" then
			      fichier_resultat := To_Unbounded_String(Argument(Indice_arg+1));
        elsif Argument(Indice_arg) = "-t" then
               fichier_table := To_Unbounded_String(Argument(Indice_arg+1));
        elsif Argument(Indice_arg) = "-p" then       
               fichier_paquet := To_Unbounded_String(Argument(Indice_arg+1));
        elsif Argument(Indice_arg) = "-c" then
                TailleC := Argument(Indice_arg+1);
        elsif Argument(Indice_arg) = "-c" then
		end if;
        Indice_arg := Indice_arg +1;
      end loop;
    end if;

    -- On associe chaque paquet � une interface
    Open(Paquets, In_File, To_String(fichier_paquet));
    Create(Resultat, Out_File, To_String(fichier_resultat));
    begin
    while not End_Of_File(Paquets) loop

        Lire_Adresse (Paquet, Paquets);

        -- On enregistre dans Resultat
        Put(Resultat, Convertir_Adresse(Paquet));
        Put(Resultat, " ");
        Put(Resultat, Chercher_Route(Table, Paquet));
        New_Line(Resultat);

        -- mettre à jour le cache en fonction de la politique



    end loop;

    end;
    Close(Paquets);
    Close(Resultat);

end routeur_ll;
