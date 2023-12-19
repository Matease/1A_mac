with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Adresse_IP; use Adresse_IP;
with Complements_Cache_L; use Complements_Cache_L;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Cache_L; use Cache_L;

procedure Test_Cache_L is


    Cache : T_Cache_L;
    Paquet : T_adresse_ip;
    Route1, Route2, Route3 : T_Route;
    Route_Finale : T_Route;



    procedure Initialisation_cache is
    begin
        Initialiser(Cache);
    end Initialisation_cache;

    procedure Test_Enregistrer is
    begin
        Put_Line("Test de la fonction Enregistrer pour un Cache non plein");

        Initialiser(Route1.Adresse, 10, 0, 0, 0);
        Initialiser(Route1.Masque, 255, 255, 255, 0);
        Route1.Interface_Associee := To_Unbounded_String("Interface1");
        Enregistrer(Cache, Route1, "LRU",3);

        Initialiser(Route2.Adresse, 212, 124, 0, 0);
        Initialiser(Route2.Masque, 255, 255, 0, 0);
        Route2.Interface_Associee := To_Unbounded_String("Interface2");
        Enregistrer(Cache, Route2, "LRU",3);

        Initialiser(Route3.Adresse, 172, 16, 0, 0);
        Initialiser(Route3.Masque, 255, 240, 0, 0);
        Route3.Interface_Associee := To_Unbounded_String("Interface3");
        Enregistrer(Cache, Route3, "LRU",3);

        Afficher_Cache(Cache);

        Put_Line("Fonction Enregistrer OK");
        New_Line;
    end Test_Enregistrer;


    procedure Test_Chercher is

    begin
        Put_Line("Test de la fonction Chercher ");

        Initialiser(Paquet, 10, 0, 0, 1);
        Route_Finale := Chercher(Cache, Paquet);
        Put_Line("Route trouvée pour l'adresse 10.0.0.1 : " &Route_Finale.Interface_Associee );
        pragma Assert (Route_Finale.Interface_Associee = "Interface1" );

        Initialiser(Paquet, 192, 168, 1, 0);
        Route_Finale := Chercher(Cache, Paquet);
        Put_Line("Route trouvée pour l'adresse 192.168.1.1 : " &Route_Finale.Interface_Associee );
        pragma Assert (Route_Finale.Interface_Associee = "Interface2" );

        Initialiser(Paquet, 100, 0, 1, 1);
        Route_Finale := Chercher(Cache, Paquet);
        Put_Line("Route trouvée pour l'adresse 100.0.1.1 : " &Route_Finale.Interface_Associee );
        pragma Assert (Route_Finale.Interface_Associee = "null" );

        New_Line;
        Put_Line("Fonction Chercher OK");
        New_Line;
    end Test_Chercher;


    procedure Test_Vider is
    begin
        Put_Line("Test de la fonction Vider :");
        New_Line;
        Vider(Cache);
        Put_Line("On Affiche le cache après l'avoir vidé :");
        Afficher_Cache(Cache);
        Put_Line("Le cache est bien vide.");
    end Test_Vider;


begin

    Initialisation_cache;
    New_Line;
    Put_Line("------------------------------------------------------------------------");
    New_Line;
    Test_Enregistrer;
    New_Line;
    Put_Line("------------------------------------------------------------------------");
    New_Line;
    Test_Chercher;
    New_Line;
    Put_Line("------------------------------------------------------------------------");
    New_Line;

    Test_Vider;

end Test_Cache_L;
