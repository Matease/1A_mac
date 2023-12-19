with Adresse_IP; use Adresse_IP;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Complements_Cache_L; use Complements_Cache_L;

package Cache_L is

   type T_Cache_L is limited private;

   procedure Initialiser(Cache : out T_Cache_L);

   procedure Enregistrer(Cache : in out T_Cache_L; Route : in T_route; politique : in String ; Taille_Cache : in Integer);

   procedure Vider(Cache : in out T_Cache_L);

   procedure Afficher_Cache(Cache : in out T_Cache_L);

   procedure Mettre_a_jour(Cache : in out T_Cache_L; Route : in T_route ; politique : in String);

   function Chercher(Cache : in T_Cache_L; adresse_a_comparer : in T_adresse_ip) return T_route;



private

   type T_Cellule;

   type T_Cache_L is access T_Cellule;

   type T_Cellule is record
      Route : T_route;
      Frequence : Integer;
      Suivant : T_Cache_L;
   end record;

end Cache_L;
