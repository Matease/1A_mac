with Ada.Unchecked_Deallocation;
with Ada.Text_IO;            use Ada.Text_IO;
with adresse_ip;	use adresse_ip;


package body cache_arbre is
    Taille_Arbre : constant Integer := 10 ;
    procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Arbre);

    -- Initialiser une Table. La table est vide
    procedure Initialiser_Arbre(Arbre : out T_Arbre) is
    begin
        Arbre := null;
    end Initialiser_Arbre;

    function Est_Vide_Arbre (Arbre : T_Arbre) return Boolean is
    begin
        return Arbre = null;
    end Est_Vide_Arbre;
                         
          
   Procedure Supprimer_LRU (Arbre : in out T_arbre) is

      function Date_min(Arbre:T_arbre) return integer is
      begin
         if Est_Vide_Arbre(Arbre) then
            return 0;
         elsif Est_Vide_Arbre(Arbre.all.Droite) and Est_Vide_Arbre(Arbre.all.Gauche) then
            return Arbre.all.Date_use;
         else
             if date_min(Arbre.all.Droite) < date_min(Arbre.all.Gauche) then
                return date_min(Arbre.all.Droite);
            else
                return date_min(Arbre.all.Gauche);
            end if;
         end if;
      end Date_min;

      procedure Destination_date(arbre:T_arbre;date:Integer;rep:in out T_adresse_IP) is
      begin
         if Est_Vide_Arbre(arbre) then
            null;
         elsif Est_Vide_Arbre(Arbre.all.Droite) and Est_Vide_Arbre(Arbre.all.Gauche) then
            if Arbre.all.Date_use = date then
               rep := Arbre.all.Destination;
            else
                  null;
            end if;
         else
            Destination_date(Arbre.all.Gauche,date,rep);
            Destination_date(Arbre.all.Droite,date,rep);
         end if;
      end Destination_date;

      procedure Supprimer_destination(arbre:in out T_arbre;Destination:T_adresse_IP) is
        begin
         if Est_Vide_Arbre(arbre) then
            null;
         elsif Est_Vide_Arbre(Arbre.all.Droite) and Est_Vide_Arbre(Arbre.all.Gauche) then
            if arbre.all.Destination = Destination then
               Vider_Arbre(arbre);
            else
               null;
            end if;
         else
            Supprimer_destination(arbre.all.Droite,Destination);
            Supprimer_destination(arbre.all.Gauche,Destination);
         end if;
      end Supprimer_destination;

        rep:T_adresse_IP;
        date:Integer;
    begin
      if Est_Vide_Arbre(arbre) then
         null;
      else
         rep:=00000000000000000000000000000000;
         Date:=date_min(arbre);
         Destination_date(arbre,date,rep);
         Supprimer_destination(arbre,rep);
      end if;
end supprimer_lru;
    
    
    

    function Route_Presente_Arbre (Arbre : in T_Arbre ; Destination : in T_adresse_ip) return Boolean is
        
        
        function Sous_Route_Route_Presente_Arbre (Arbre : in T_Arbre ; Destination : in T_adresse_ip; Destination_bit_suivant : in T_adresse_ip) return Boolean is
            Bit_A_1 : Boolean;
        begin
            Bit_A_1 := (Destination_bit_suivant and POIDS_FORT) /= 0;
            if Est_Vide_Arbre(Arbre) then
                return False;
            elsif Est_Vide_Arbre(Arbre.all.Gauche)and Est_Vide_Arbre(Arbre.all.Droite) then
                if Arbre.all.Destination = Destination then
                    return True;
                else
                    return False;
                end if;
            else
                if Bit_A_1 then
                    return Sous_Route_Route_Presente_Arbre(Arbre.all.Droite, Destination, Destination_bit_suivant*2);
                else
                    return Sous_Route_Route_Presente_Arbre(Arbre.all.Gauche, Destination, Destination_bit_suivant*2);
                end if;
            end if;
        end Sous_Route_Route_Presente_Arbre;
        
        
    begin
        return Sous_Route_Presente_Arbre (Arbre, Destination, Destination);
    end Route_Presente_Arbre; 
    
    
    procedure Enregistrer_Arbre (Arbre : in out T_Arbre; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String; Date: in Integer) is
        
        
        procedure Sous_Enregistrer_Arbre (Arbre : in out T_Arbre; Destination : in T_adresse_ip ; Masque : in T_adresse_ip ; Interf : in Unbounded_String; Date: in out Integer; Destination_bit_suivant : in T_adresse_ip; Position :in out Integer) is
            Bit_A_1 : Boolean;
            Bit_A_1_route : Boolean;
        begin
            Bit_A_1 := (Position and POIDS_FORT) /= 0;
            Bit_A_1_route:=((arbre.all.Destination*(2**Position)) and POIDS_FORT) /= 0;
            if Est_Vide_Arbre(Arbre) then
                arbre := new T_Cellule'(Destination, Masque, Interf, Null, Null,Date);
                Date := Date + 1;
            elsif Est_Vide_Arbre(arbre.all.Droite) and Est_Vide_Arbre(arbre.all.Gauche) then
                if Bit_A_1 then
                    if Bit_A_1_route then
                        Arbre.all.Droite := new T_Cellule'(Arbre.all.Destination, Arbre.all.Masque, Arbre.all.Interf, Null, Null,Arbre.all.Date_use);
                        Position := Position + 1;
                        Sous_Enregistrer_Arbre (Arbre.all.Droite, Destination, Masque, Interf, Date, Destination_bit_suivant*2, Position);
                    else 
                        Arbre.all.Droite := new T_Cellule'(Destination, Masque, Interf, Null, Null,Date);
                        Arbre.all.Gauche := new T_Cellule'(Arbre.all.Destination, Arbre.all.Masque, Arbre.all.Interf, Null, Null,Arbre.all.Date_use);
                        Date := Date +1;
                    end if;
                else
                    if Bit_A_1_route then
                        Arbre.all.Gauche := new T_Cellule'(Destination, Masque, Interf, Null, Null,Date);
                        Arbre.all.Droite := new T_Cellule'(Arbre.all.Destination, Arbre.all.Masque, Arbre.all.Interf, Null, Null,Arbre.all.Date_use);
                        Date := Date +1;
                    else
                        Arbre.all.Gauche := new T_Cellule'(Arbre.all.Destination, Arbre.all.Masque, Arbre.all.Interf, Null, Null,Arbre.all.Date_use);
                        Position := Position + 1;
                        Sous_Enregistrer_Arbre (Arbre.all.Gauche, Destination, Masque, Interf, Date, Destination_bit_suivant*2, Position);
                    end if;
                end if;
            else
                if Bit_A_1_route then
                    Position := Position + 1;
                    Sous_Enregistrer_Arbre (Arbre.all.Droite, Destination, Masque, Interf, Date, Destination_bit_suivant*2, Position);
                else 
                    Position := Position + 1;
                    Sous_Enregistrer_Arbre (Arbre.all.Droite, Destination, Masque, Interf, Date, Destination_bit_suivant*2, Position);
                end if;
            end if;
        end Sous_Enregistrer_Arbre;
        
    begin
        if Est_Vide_Arbre(Arbre) then
            Sous_Enregistrer_Arbre(Arbre, 0, Masque, Interf, Date, 0, 0);
        else
            Sous_Enregistrer_Arbre(Arbre, Destination, Masque, Interf, Date, Destination, Enregistrer_Arbre);
        end if;
    end Enregistrer_Arbre;
    
    
    procedure Ajouter_IP_Arbre (Arbre : in out T_Arbre; Precision_Cache : in Integer; Destination : in out T_adresse_ip; Masque : in T_adresse_ip; Interf : in Unbounded_String ;Date:in out Integer;Politique:in Unbounded_String) is
        UN_OCTET : constant T_Adresse_IP := 2 ** 8;
    begin
        if Route_Presente_Arbre(Arbre ,Destination) then 
            Null;
        else
            Supprimer_LRU_Arbre(Arbre);
        end if;
        Enregistrer (arbre,Adresse,Masque,Interf,0,Date );

    end Ajouter_IP_Arbre;
    
    
    procedure Vider_Arbre (Arbre : in out T_Arbre ) is
    begin
        if Est_Vide_Arbre(Arbre) then
            Null;
        elsif Est_Vide_Arbre(arbre.all.Droite) and Est_Vide_Arbre(arbre.all.Gauche) then
            Vider_Arbre(arbre.all.Droite);
            Vider_Arbre(arbre.all.Gauche);
        else
            Null;
        end if;
    end Vider_Arbre;                               
      
end cache_arbre;      
      
      
      
      
      
