with LCA;

generic
    type T_Cle is private;
    type T_Donnee is private;
    Capacite : integer;
    with function Hachage (Cle : in T_Cle) return Integer;


package TH is

    type T_TH is limited private;

    -- Initialiser une table de hachage
    procedure Initialiser (Sda : out T_TH) with
                Post => Est_Vide(Sda);

    -- Savoir si une table de hachage est vide
    function Est_Vide (Sda : in T_TH) return Boolean;
                
    -- Obtenir le nombre d éléments d une table de hachage
    function Taille (Sda : in T_TH) return Integer with
            Post => Taille'Result >= 0 and Est_Vide(Sda)=(Taille'Result = 0);

    -- Enregistrer une table de hachage
    procedure Enregistrer(Sda : in out T_TH ; Cle : in T_Cle ; Donnee : in T_Donnee) with
            Post => Cle_Presente (Sda, Cle) and (La_Donnee(Sda, Cle)= Donnee) -- vérification si la clé est présente et que la donnée insérée correspond bien
                        and (not (Cle_Presente (Sda, Cle)'Old) or Taille(Sda)=Taille(Sda)'Old + 1)
                        and (Cle_Presente (Sda, Cle)'old or Taille (Sda) = Taille(Sda)'Old);
    -- Supprimer Une donnee dans une table de hachage
    procedure Supprimer(Sda : in out T_TH ; Cle : in T_Cle) with
            Post => Taille(Sda) = Taille(Sda)'Old -1 -- le tableau a un élément de moins
                    and not(Cle_Presente(Sda, Cle)); -- La clé e été supprimée du tableau

    -- Savoir si une cle est présente dans la table de hachage
    function Cle_Presente (Sda : in T_TH ; Cle : in T_Cle) return Boolean;
    
    -- Obtenir la donnée associée à la clé
    --Exception : Cle_Absente_Exception si la Clé n'est pas présente dans la SDA

    function La_Donnee(Sda : in T_TH ; Cle : in T_Cle) return T_Donnee;

    -- supprimer tous les éléments d'une table de hachage
    procedure Vider (Sda : in out T_TH) with
        Post => Est_Vide(Sda);
    
    function Hachage_modulo (module : in Integer) return Integer;

    generic
        with procedure Traiter (Cle : in T_Cle ; Donne : in T_Donnee);
    procedure Pour_Chaque (Sda : in T_TH);

private
    
    package LCAth is new LCA(T_Cle=>T_Cle, T_Donnee=>T_Donnee);
    type T_TH is array (1..Capacite) of LCAth.T_LCA;

end TH;
