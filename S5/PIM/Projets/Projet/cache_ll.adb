with Ada.Unchecked_Deallocation;
with Cache_Exceptions;         use Cache_Exceptions;
with Ada.Text_IO;            use Ada.Text_IO;
with Adresse_IP;            use Adresse_IP;
with Cache,                 use Cache;

package body cache_ll is
   type T_Cache is limited private;

    -- Initialiser un cache, elle est vide.
   procedure Initialiser (Cache : out T_Cache) with
     Post => Est_Vide_T (Cache);

    -- Savoir si une Cache est vide ou non.
   function Est_Vide_T (Cache : in T_Cache) return Boolean;

    -- Connaitre le taille d'un Cache.
   function Taille (Cache : in T_Cache) return Integer with
     Post => Taille'Result >= 0
     and (Taille'Result = 0 ) = Est_Vide_T (Cache);

    -- Enregistrer une route dans un Cache.
    -- Si une le destination renseign�e existe d�ja dans le Cache, son masque et ou son interface
    -- associ�(s) est modifi�(s).
   procedure Enregistrer (Cache : in out T_Cache ; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String) with
     Post => Route_Presente (Cache, Destination) and (Le_Masque (Cache, Destination) = Masque) and (L_Interface (Cache, Destination) = Interf)
     and (not (Route_Presente (Cache, Destination)'Old) or Taille (Cache) = Taille (Cache)'Old)
     and (Route_Presente (Cache, Destination)'Old or Taille (Cache) = Taille (Cache)'Old + 1);

    -- Supprimer une route de le Cache.
    -- Exception : Destination_Absente_Exception si Destination n'est pas p�sente dans le Cache.
   procedure Supprimer (Cache : in out T_Cache ; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String) with
     Post => Taille (Cache) = Taille (Cache)'Old -1
     and not Route_Presente (Cache, Destination);

    -- Vider totalement une Cache.
    procedure Vider (Cache : in out T_Cache) with
      Post => Est_Vide_T(Cache);

    -- V�rifier si une route est pr�sente dans le Cache.
   function Route_Presente (Cache : in T_Cache ; Destination : in T_adresse_ip) return Boolean;

    -- Retourner le masque associ� � une destination
    -- Exception : Destination_Absente_Exception si Destination n'est pas p�sente dans le Cache.
   function Le_Masque (Cache : in T_Cache ; Destination : in T_adresse_ip) return T_adresse_ip;

    -- Retourner l'interface associ� � une destination
    -- Exception : Destination_Absente_Exception si Destination n'est pas p�sente dans le Cache.
   function L_Interface (Cache : in T_Cache ; Destination : in T_adresse_ip) return Unbounded_String;

	-- Renvoie l'interface de la route qui correspond le mieux � l'adresse du paquet selon les crit�res.
    function Chercher_Route (Cache : in T_Cache ; Paquet : in T_adresse_ip) return Unbounded_String;

    function Le_age (Cache : in T_Cache ; Destination)


