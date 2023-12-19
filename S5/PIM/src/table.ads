with Adresse_IP; use Adresse_IP;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Complements_Cache_L; use Complements_Cache_L;

 package Table is
   type T_Table is limited private;

    -- Initialiser une table, elle est vide.
   procedure Initialiser (Table : out T_Table);

    -- Savoir si une table est vide ou non.
   function Est_Vide_T (Table : in T_Table) return Boolean;


    -- Enregistrer une route dans une table.
    -- Si une la destination renseignée existe déja dans la table, son masque et ou son interface
    -- associé(s) est modifié(s).
   procedure Enregistrer (Table : in out T_Table ; Route : in T_route);


    -- Vider totalement une table de routage.
    procedure Vider (Table : in out T_Table) ;

	-- Renvoie l'interface de la route qui correspond le mieux à l'adresse du paquet selon les critères.
    function Chercher_Route (Table : in T_Table ; Paquet : in T_adresse_ip) return T_Route;


private

   type T_Cellule;
   type T_Table is access T_Cellule;
   type T_Cellule is
      record
         Route : T_Route;
         Suivant : T_Table;
      end record;

end Table;
