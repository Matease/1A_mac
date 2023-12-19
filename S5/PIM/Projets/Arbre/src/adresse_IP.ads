with Ada.Strings.Unbounded; Use Ada.Strings.Unbounded;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

package Adresse_IP is

    type T_adresse_ip is private;

    -- Permet d'initaliser une adresse à partir des valeur entiere de chaque octets
    procedure Initialiser (Adresse : out T_adresse_ip ; Octet1 : in Integer ;
             Octet2 : in Integer; Octet3 : in Integer; Octet4 : in Integer) with

        Pre => 0 <= Octet1 and Octet1 <= 255 and 0 <= Octet2 and Octet2 <= 255
        and 0 <= Octet3 and Octet3 <= 255 and 0 <= Octet4 and Octet4 <= 255;

    -- Permet de lire une adresse dans un fichier et de l'initialiser
    procedure Lire_Adresse (Adresse : out T_adresse_ip ; Fichier : in out File_Type);

    -- Permet de convertir une adresse en Unbounded_String
    function Convertir_Adresse (Adresse : in T_adresse_ip) return Unbounded_String;

    -- Permet de comparer si une adresse avec un masque est compatible avec une destination
    function Compatible (Adresse : in T_adresse_ip; Masque : in T_adresse_ip;
             Destination : in T_adresse_ip) return Boolean;

    -- Surcharge de l'operateur pour le type T_adresse_ip
    function ">=" (Left : T_adresse_ip; Right : T_adresse_ip) return Boolean;


private
    type T_adresse_ip is mod 2 ** 32;

    UN_OCTET: constant T_Adresse_IP := 2 ** 8;       -- 256
	POIDS_FORT : constant T_Adresse_IP  := 2 ** 31;	 -- 10000000.00000000.00000000.00000000

end Adresse_IP;
