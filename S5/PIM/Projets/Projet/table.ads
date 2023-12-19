with Adresse_IP; use Adresse_IP;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

 package Table is
   type T_Table is limited private;

    -- Initialiser une table, elle est vide.
   procedure Initialiser (Table : out T_Table) with
     Post => Est_Vide_T (Table);

    -- Savoir si une table est vide ou non.
   function Est_Vide_T (Table : in T_Table) return Boolean;

    -- Connaitre la taille d'une table.
   function Taille (Table : in T_Table) return Integer with
     Post => Taille'Result >= 0
     and (Taille'Result = 0 ) = Est_Vide_T (Table);

    -- Enregistrer une route dans une table.
    -- Si une la destination renseign�e existe d�ja dans la table, son masque et ou son interface
    -- associ�(s) est modifi�(s).
   procedure Enregistrer (Table : in out T_Table ; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String) with
     Post => Route_Presente (Table, Destination) and (Le_Masque (Table, Destination) = Masque) and (L_Interface (Table, Destination) = Interf)
     and (not (Route_Presente (Table, Destination)'Old) or Taille (Table) = Taille (Table)'Old)
     and (Route_Presente (Table, Destination)'Old or Taille (Table) = Taille (Table)'Old + 1);

    -- Supprimer une route de la table de routage.
    -- Exception : Destination_Absente_Exception si Destination n'est pas p�sente dans la Table.
   procedure Supprimer (Table : in out T_Table ; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String) with
     Post => Taille (Table) = Taille (Table)'Old -1
     and not Route_Presente (Table, Destination);

    -- Vider totalement une table de routage.
    procedure Vider (Table : in out T_Table) with
      Post => Est_Vide_T(Table);

    -- V�rifier si une route est pr�sente dans la table de routage.
   function Route_Presente (Table : in T_Table ; Destination : in T_adresse_ip) return Boolean;

    -- Retourner le masque associ� � une destination
    -- Exception : Destination_Absente_Exception si Destination n'est pas p�sente dans la Table.
   function Le_Masque (Table : in T_Table ; Destination : in T_adresse_ip) return T_adresse_ip;

    -- Retourner l'interface associ� � une destination
    -- Exception : Destination_Absente_Exception si Destination n'est pas p�sente dans la Table.
   function L_Interface (Table : in T_Table ; Destination : in T_adresse_ip) return Unbounded_String;

	-- Renvoie l'interface de la route qui correspond le mieux � l'adresse du paquet selon les crit�res.
    function Chercher_Route (Table : in T_Table ; Paquet : in T_adresse_ip) return Unbounded_String;


private

   type T_Route;
   type T_Table is access T_Route;
   type T_Route is
      record
         Destination: T_adresse_ip;
         Masque : T_adresse_ip;
         Interf : Unbounded_String;
         Suivant : T_Table;
      end record;

end Table;
