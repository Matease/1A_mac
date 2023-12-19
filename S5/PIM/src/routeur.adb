with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Adresse_IP; use Adresse_IP;
with Table; use Table;
with Complements_Cache_L; use Complements_Cache_L;
with Cache_L; use Cache_L;

procedure routeur is

   procedure Initialiser_Options (taille_cache : out Integer; politique : out Unbounded_String ; afficher_stat : out Boolean ;
        fichier_table : out Unbounded_String ; fichier_paquet : out Unbounded_String ; fichier_resultat : out Unbounded_String ) is

        i : Integer := 1;
    begin
        while i <= Argument_Count loop

            if Argument(i) = "-c" or Argument(i) = "-P" or Argument(i) = "-t" or Argument(i) = "-p" or Argument(i) = "-r" then

                if i+1 <= Argument_Count then

                    if Argument(i) = "-c" then
                        begin
                            taille_cache := Integer'Value(Argument(i+1));
                            exception

                                when CONSTRAINT_ERROR =>
                                    Put("L'option -c prend un entier en Argument");
                        end;

                    elsif Argument(i) = "-P" then
                        politique := To_Unbounded_String((i+1));
                        if not (politique = To_Unbounded_String("FIFO") or politique = To_Unbounded_String("LFU") or politique = To_Unbounded_String("LRU")) then
                            Put("Politique choisie inconnue");
                        end if;

                    elsif Argument(i) = "-t" then
                        fichier_table := To_Unbounded_String((i+1));
                        if Tail(fichier_table, 4) /= ".txt" then
                            Put("Nom de fichier de table incorrect");
                        end if;

                    elsif Argument(i) = "-p" then
                        fichier_paquet := To_Unbounded_String((i+1));
                        if Tail(fichier_paquet, 4) /= ".txt" then
                            Put("Nom de fichier de paquet incorrect");
                        end if;

                    elsif Argument(i) = "-r" then
                        fichier_resultat := To_Unbounded_String((i+1));
                        if Tail(fichier_resultat, 4) /= ".txt" then
                            Put("Nom de fichier de resultat incorrect");
                        end if;
                    end if;

                    i := i + 2;

                else
                    Put("Mauvais nombre d'argument");
                end if;

            elsif Argument(i) = "-s" or Argument(i) = "-S" then
                afficher_stat := (Argument(i) = "-s");
                i := i + 1;
            else
                Put("Option non reconnue");
            end if;
        end loop;
    end Initialiser_Options;





    procedure Importer_Table (Table : in out T_Table ; fichier_table : in Unbounded_String) is
        FD_Table : File_Type;
        Route : T_route;
    begin
        Open(FD_Table, In_File, To_String(fichier_table));
        Initialiser (Table);

        while not End_Of_File(FD_Table) loop

            Lire_Adresse (Route.Adresse, FD_Table);
            Lire_Adresse (Route.Masque, FD_Table);
            Route.Interface_Associee := Get_line(FD_Table);
            Trim(Route.Interface_Associee, Both); -- On supprime les espaces blancs

            Enregistrer(Table, Route);

        end loop;

        Close(FD_Table);
   end Importer_Table;


   procedure Enregister_Resultat (Fichier : File_Type ; Route : T_Route) is
    begin
        Put(Fichier, Convertir_adresse(Route.Adresse));
        Put(Fichier, " ");
        Put(Fichier, Route.Interface_Associee);
        New_Line(Fichier);
    end Enregister_Resultat;


    fichier_table : Unbounded_String :=  To_Unbounded_String("table.txt");
    fichier_paquet : Unbounded_String := To_Unbounded_String("paquet.txt");
    fichier_resultat : Unbounded_String := To_Unbounded_String("resultats.txt");
    Table : T_Table;
    Paquets : File_Type;
    Paquet : T_adresse_ip;
   Resultat : File_Type;
   taille_cache : Integer := 10;
    politique : Unbounded_String := To_Unbounded_String("FIFO");
   afficher_stat : Boolean := True;
   Route : T_route;
   Cache : T_Cache_L;

begin



   Initialiser_Options(taille_cache, politique , afficher_stat , fichier_table, fichier_paquet ,fichier_resultat );
   Importer_Table(Table, fichier_table);

    -- On associe chaque paquet à une interface
    Open(Paquets, In_File, To_String(fichier_paquet));
    Create(Resultat, Out_File, To_String(fichier_resultat));
    begin
    while not End_Of_File(Paquets) loop

         Lire_Adresse (Paquet, Paquets);



         Route := Chercher(Cache, Paquet);

        if Route.Interface_Associee = To_Unbounded_String("null") then
            Route := Chercher_Route(Table, Paquet);
            Enregistrer(Cache, Route, To_String(politique),taille_cache);
        else
            Mettre_a_jour(Cache, Route, To_string(politique));
        end if;



        Enregister_Resultat (Resultat, Route);



    end loop;

    end;
    Close(Paquets);
    Close(Resultat);


end routeur;
