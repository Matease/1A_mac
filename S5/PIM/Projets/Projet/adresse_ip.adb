with Ada.Strings.Fixed; Use Ada.Strings.Fixed;
with Ada.Long_Integer_Text_IO; use Ada.Long_Integer_Text_IO;

package body Adresse_IP is

    procedure Initialiser (Adresse : out T_adresse_ip ; Octet1 : in Integer ; Octet2 : in Integer; Octet3 : in Integer; Octet4 : in Integer) is
        Adresse2 : T_adresse_ip;
        O1, O2, O3, O4 : T_adresse_ip;
    begin
        -- On convertit les octets dans le type T_Adresse_IP
        O1 := T_adresse_ip(Octet1);
        O2 := T_adresse_ip(Octet2);
        O3 := T_adresse_ip(Octet3);
        O4 := T_adresse_ip(Octet4);

        -- On construit l'adresse l'adresse
        Adresse2 := O1;
        Adresse2 := Adresse2 * UN_OCTET + O2;
        Adresse2 := Adresse2 * UN_OCTET + O3;
        Adresse2 := Adresse2 * UN_OCTET + O4;

        Adresse := Adresse2;
    end Initialiser;

    procedure Lire_Adresse (Adresse : out T_adresse_ip ; Fichier : in out File_Type) is
        Octet1, Octet2, Octet3, Octet4 : Integer;
        Corbeille : Character;
    begin
        Get(Fichier, Octet1);
        Get(Fichier, Corbeille); -- Supprime le point entre 2 octets
        Get(Fichier, Octet2);
        Get(Fichier, Corbeille);
        Get(Fichier, Octet3);
        Get(Fichier, Corbeille);
        Get(Fichier, Octet4);
        Get(Fichier, Corbeille);
        Initialiser(Adresse, Octet1, Octet2, Octet3, Octet4);
    end Lire_Adresse;

    --procedure Lire_Adresse2 (Adresse : out T_adresse_ip ; Fichier : in out File_Type) is
    --    Octet1, Octet2, Octet3, Octet4 : Integer;
    --    Corbeille : Character;
    --    Ligne : Unbounded_String;
    --    cOctet1, cOctet2, cOctet3, cOctet4 : Unbounded_String;
    --begin
    --    Ligne := To_Unbounded_String(Get_Line(Fichier));
     --   Trim(Ligne, Both);

    --end Lire_Adresse2;


    function Convertir_Adresse (Adresse : in T_adresse_ip) return Unbounded_String is
        Octet1 : T_Adresse_IP;
        Octet2 : T_Adresse_IP;
        Octet3 : T_Adresse_IP;
        Octet4 : T_Adresse_IP;
        Resultat : Unbounded_String := To_Unbounded_String("");
    begin

        Octet1 := Adresse;
        Octet2 := Octet1 / UN_OCTET;
        Octet3 := Octet2 / UN_OCTET;
        Octet4 := Octet3 / UN_OCTET;


        -- La fonction Integer'image ajoute un espace blanc que l'on supprime avec trim
        Append(Resultat, Trim(Integer'Image (Integer(Octet4 mod UN_OCTET)), Left));
        Append(Resultat, ".");
        Append(Resultat, Trim(Integer'Image (Integer(Octet3 mod UN_OCTET)), Left));
        Append(Resultat, ".");
        Append(Resultat, Trim(Integer'Image (Integer(Octet2 mod UN_OCTET)), Left));
        Append(Resultat, ".");
        Append(Resultat, Trim(Integer'Image (Integer(Octet1 mod UN_OCTET)), Left));

        return Resultat;
    end Convertir_Adresse;

    function Compatible (Adresse : in T_adresse_ip; Masque : in T_adresse_ip; Destination : in T_adresse_ip) return Boolean is
    begin
        return ((Adresse and Masque) = Destination);
    end Compatible;

    function ">=" (Left : T_adresse_ip; Right : T_adresse_ip) return Boolean is
    begin
        return Long_Integer(Left)>=Long_Integer(Right);
    end ">=";

end Adresse_IP;
