
package body TH is

    use LCAth;
    
    procedure Initialiser(Sda: out T_TH) is
    begin
        for i in 1..Capacite loop
            Initialiser(Sda(i));
        end loop;
    end Initialiser;

    function Est_Vide(Sda : in T_TH) return Boolean is
        test_vide : Boolean;
    begin
        test_vide:=true;
        for i in 1..Capacite loop
            if (Est_Vide(Sda(i)))=false then
                test_vide := false;
            end if;
        end loop;
        return(test_vide);
    end Est_Vide;

    function Taille (Sda : in T_TH) return Integer is
        TailleTH : Integer;
    begin
        TailleTH := 0;
        for i in 1..Capacite loop
            TailleTH:=TailleTH+Taille(Sda(i));
        end loop;
        return(TailleTH);
    end Taille;

    procedure Enregistrer(Sda : in out T_TH ; Cle : in T_Cle ; Donnee : in T_Donnee) is
        position : Integer;
    begin
        position := Hachage_modulo(Hachage(Cle));
        Enregistrer(Sda(position), Cle, Donnee);
    end Enregistrer;

    procedure Supprimer(Sda : in out T_TH ; Cle : in T_Cle) is
        position : Integer;
    begin
        position := Hachage_modulo(Hachage(Cle));
        Supprimer(Sda(position), Cle);
    end Supprimer;

    function Cle_Presente(Sda : in T_TH ; Cle : in T_Cle) return Boolean is
        test_present : Boolean;
    begin
        test_present := false;
        for i in 1..Capacite loop
            if Cle_Presente(Sda(i), Cle) then
                return true;
            end if;
        end loop;
        return(test_present);
    end Cle_Presente;

    function La_Donnee(Sda : in t_TH ; Cle : in T_Cle) return T_Donnee is
        position : Integer;
    begin
        position := Hachage_modulo(Hachage(Cle));
        return La_Donnee(Sda(position), Cle);
    end La_Donnee;

    procedure Vider(Sda : in out T_TH) is
    begin
        for i in 1..Capacite loop
            Vider(Sda(i));
        end loop;
    end Vider;
    
    function Hachage_modulo (module : in Integer) return Integer is
    begin
        return (module mod (Capacite+1));
    end Hachage_modulo;

    procedure Pour_Chaque (Sda : in T_TH) is
        procedure LCA_Pour_Chaque is new
            LCAth.Pour_Chaque(Traiter);

    begin
        for i in 1..Capacite loop
            LCA_Pour_Chaque(Sda(i));
        end loop;
    end Pour_Chaque;

end TH;
    
