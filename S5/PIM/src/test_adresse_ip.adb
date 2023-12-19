with Adresse_IP; use Adresse_IP;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;

procedure Test_Adresse_IP is

    Adresse1, Adresse2 : T_adresse_ip;
    Masque : T_adresse_ip;
    Route_Compatible : Boolean;
    Adresse_String : Unbounded_String;
    Fichier : File_Type;

    procedure Test_de_la_fonction_Initialiser is
    begin

        Initialiser(Adresse1, 0, 0, 0, 0);
        Adresse_String := Convertir_Adresse(Adresse1);
        Put_Line("Test de la fonction Initialiser avec un octet de valeur minimale : " & Adresse_String);
        pragma Assert (Adresse_String = "0.0.0.0");


        Initialiser(Adresse1, 255, 255, 255, 255);
        Adresse_String := Convertir_Adresse(Adresse1);
        Put_Line("Test de la fonction Initialiser avec un octet de valeur maximale : " & Adresse_String);
      pragma Assert (Adresse_String = "255.255.255.255");

      Initialiser(Adresse1, 212, 124, 0, 0);
        Adresse_String := Convertir_Adresse(Adresse1);
        Put_Line("Test de la fonction Initialiser avec octets quelconques : " & Adresse_String);
        pragma Assert (Adresse_String = "212.124.0.0");

        Put_Line("Fonction Initialiser OK");
    end Test_de_la_fonction_Initialiser;

    procedure Test_de_la_fonction_Lire_Adresse is
    begin
        Open(Fichier, In_File, "test_adresse.txt");
        Lire_Adresse(Adresse2, Fichier);
        Adresse_String := Convertir_Adresse(Adresse2);
        Put_Line("Test de la fonction Lire_Adresse : " & Adresse_String);
        pragma Assert (Adresse_String = "192.168.0.1");

        Lire_Adresse(Adresse1, Fichier);
        Adresse_String := Convertir_Adresse(Adresse1);
        Put_Line("Test avec une adresse IP trop longue dans le fichier : " & Adresse_String);

        Close(Fichier);

        Put_Line("Fonction Lire_Adresse OK");
    end Test_de_la_fonction_Lire_Adresse;

    procedure Test_Convertir_Adresse is
    begin

        Initialiser(Adresse1, 212, 124, 0, 0);
        Adresse_String := Convertir_Adresse(Adresse1);
        Put_Line("Test de la fonction Convertir_Adresse avec octets quelconques : " & Adresse_String);
        pragma Assert (Adresse_String = "212.124.0.0");

        Put_Line("Fonction Convertir_Adresse OK");
    end Test_Convertir_Adresse;

    procedure Test_Compatible is
    begin

        Initialiser(Adresse1, 212, 124, 0, 0);
        Initialiser(Masque, 255, 255, 255, 255);
        Initialiser(Adresse2, 212, 124, 24, 1);
        Route_Compatible := Compatible(Adresse2, Masque, Adresse1);
        Put_Line("Test avec deux adresses partiellement différentes et un masque long : " & Boolean'Image(Route_Compatible));
        pragma Assert (not Route_Compatible);

        Initialiser(Masque, 255, 255, 0, 0);
        Route_Compatible := Compatible(Adresse2, Masque, Adresse1);
        Put_Line("Test avec deux adresses partiellement différentes et un masque court : " & Boolean'Image(Route_Compatible));
        pragma Assert (Route_Compatible);

        Put_Line("Fonction Est_Compatible OK");
    end Test_Compatible;

begin

    Put_Line("Test de la fonction Initialiser :");
    Test_de_la_fonction_Initialiser;
    New_Line;
    Put_Line("------------------------------------------------------------------------");
    New_Line;
    Put_Line("Test de la fonction Lire_Adresse :");
    Test_de_la_fonction_Lire_Adresse;
    New_Line;
    Put_Line("------------------------------------------------------------------------");
    New_Line;
    Put_Line("Test de la fonction Compatible :");
    Test_Compatible;
    New_Line;
    Put_Line("------------------------------------------------------------------------");
    New_Line;
    Put_Line("Test de la fonction Convertir_Adresse :");
    Test_Convertir_Adresse;

end Test_Adresse_IP;
