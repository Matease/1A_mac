with adresse_IP; use adresse_IP;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with adresse_ip;	use adresse_ip;


package cache_arbre is
   type T_Arbre is limited private;


	-- Vérifie si l'arbre est vide?
    function Est_Vide_Arbre (arbre : T_arbre) return Boolean;

    -- Initialise un arbre vide
    procedure Initialiser_Arbre(arbre: out T_arbre) with
		Post => Est_Vide_Arbre (arbre);

    
    function Taille_Arbre (arbre : in T_arbre) return Integer with
      Post => Taille_Arbre'Result >= 0
      and (Taille_Arbre'Result = 0) = Est_Vide_Arbre (arbre);
    
    -- Supprime la donnée la moins récement utilisé
    procedure Supprimer_LRU_Arbre (arbre : in out T_arbre ) ;
    
    -- Supprime tous les éléments de l'arbre
    procedure Vider_Arbre (Arbre : in out T_Arbre);
  
    
    -- Ajoute l'adresse IP
    procedure Ajouter_IP_Arbre (Arbre : in out T_Arbre; Precision_Cache : in Integer; Destination : in out T_adresse_ip; Masque : in T_adresse_ip; Interf : in Unbounded_String ;Date:in out Integer;Politique:in Unbounded_String);

    
    -- Ajoute un élément dans l'arbre
    procedure Enregistrer_Arbre((Arbre : in out T_Arbre; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String; Date: in Integer);

    
private

    type T_Cellule;        
    type T_Arbre is access T_Cellule;    
    type T_Cellule is    
       record           
           Destination: T_adresse_ip;           
           Masque : T_adresse_ip;           
           Interf : Unbounded_String;           
           Droite : T_Arbre;
           Gauche : T_Arbre;
           Date_use : Integer;  --LRU on cherche le minimum
       end record;

    

end Cache_Arbre;
