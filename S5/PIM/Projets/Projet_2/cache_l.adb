with Ada.Unchecked_Deallocation;
with Complements_Cache_L; use Complements_Cache_L;

package body Cache_L is

   procedure Free is
     new Ada.Unchecked_Deallocation(Object => T_Cellule, Name => T_Cache_L);

   procedure Initialiser_Cache(Cache : out T_Cache_L) is
   begin
      Cache := Null;
   end Initialiser_Cache;


   -- fonction servant a savoir si le cache est plein avec Taille_Cache representant la taile maximale du cache fix�e par l'utilisateur (constante tout au long de l'utilisation du routeur).
   function Cache_plein (Cache : in T_Cache_L ) return Boolean is
        Cache2 : T_Cache_L := Cache;
        i : Integer := 0;
    begin
        while Cache2 /= null loop
            i := i + 1;
            Cache2 := Cache2.all.Suivant;
        end loop;
        return (i = Taille_Cache);
   end Cache_plein;


   -- procedure servant a supprimer une route choisie du cache.
   procedure Supprimer (Cache : in out T_Cache_L; Route : in T_Route) is
        Cache2 : T_Cache_L;
    begin
        if Cache /= null then
            if Cache.All.Route = Route then
                Cache2 := Cache;
                Cache := Cache.all.Suivant;
                Free (Cache2);
            else
                Supprimer (Cache.all.Suivant, Route);
            end if;
        else
            raise Route_Absente_Error;
        end if;
   end Supprimer;

    -- procedure servant à supprimer la derniere route utilisée.
   procedure Supprimer_Derniere_Route (Cache : in out T_Cache_L) is
        Cache2 : T_Cache_L;
    begin
        if Cache /= null then
            if Cache.Suivant = null then
                Cache2 := Cache;
                Cache := null;
                Free (Cache2);
            else
                Supprimer_Derniere_Route (Cache.Suivant);
            end if;
        else
            raise Cache_Vide_Error;
        end if;
   end Supprimer_Fin;


  procedure Ajouter_Route_Debut (Cache : in out T_Cache_L; Route : in T_Route) is
        Frequence : Integer := 1;
    begin
        Cache := new T_Cellule'(Route, Frequence, Cache);
   end Ajouter_Route_Debut;


   procedure Ajouter_Route_Fin (Cache : in out T_Cache_L; Route : in T_Route) is
        Frequence : Integer := 1;
    begin
        if Cache /= null then
            Ajouter_Fin (Cache.Suivant, Route);
        else
            Cache := new T_Cellule'(Route, Frequence, null);
        end if;
   end Ajouter_Route_Fin;


   procedure Augmenter_Frequence (Cache : in out T_Cache_L; Route : in T_Route) is
    begin
        if Cache /= null then
            if Cache.All.Route = Route then
                Cache.All.Frequence := Cache.All.Frequence + 1;
            else
                Augmenter_Frequence (Cache.Suivant, Route);
            end if;
        else
            raise Route_Absente_Error;
        end if;
   end Augmenter_Frequence;


   procedure Supprimer_Minimum_Frequence(Cache : in out T_Cache_L) is
      Cache2 : T_Cache_L := Cache;
      Cache_Minimum : T_Cache_L := Cache;

   begin
      while Cache2 /= null loop
         if Cache2.all.Frequence < Cache_Minimum.all.Frequence then
            Cache_Minimum := Cache2;
         else
            null;
         end if;
         Cache2 := Cache2.Suivant;
      end loop;
      Supprimer(Cache,Cache_Minimum.all.Route);
   end Supprimer_Minimum_Frequence;



   function Chercher (Cache : in T_Cache_L; adresse_a_comparer : in T_Adresse_IP) return T_Route is
        Cache2 : T_Cache_L := Cache;
        Route_non_trouvee : T_Route;
        Adresse_non_trouvee : T_Adresse_IP;
    begin
        Initialiser_Cache (Adresse_non_trouvee, 0, 0, 0, 0);
        Route_non_trouvee := T_Route'(Adresse_non_trouvee, Adresse_non_trouvee, To_Unbounded_String("null"));

        while Cache2 /= null and then not Compatible(Cache2.All.Route.Adresse,Cache2.All.Route.Masque, adresse_a_comparer) loop
            Cache2 := Cache2.Suivant;
        end loop;
        if Cache2 = null then
            return Route_non_trouvee;
        else
            return Cache2.All.Route;
      end if;
    end Chercher;

    procedure Mettre_a_jour (Cache : in out T_Cache_L; Route : in T_Route; politique : in String) is
    begin
        if politique = "LRU" then
            Supprimer(Cache, Route);
            Ajouter_Route_Debut(Cache, Route);

        elsif politique = "LFU" then
            Augmenter_Frequence(Cache, Route);
            Supprimer_Minimum_Frequence(Cache);

        else
            Pragma Assert(politique = "FIFO");
            Supprimer_Derniere_Route(Cache);

        end if;
      end Mettre_a_jour;


     procedure Enregistrer (Cache : in out T_Cache_L; Route : in T_Route ; politique : in String) is
    begin
        if Cache_plein(Cache) then
            Supprimer_Derniere_Route(Cache);
        end if;

        if politique = "LRU" or politique = "FIFO" then
            Ajouter_Route_Debut(Cache, Route);
        else
            Pragma Assert(politique = "LFU");
            Ajouter_Route_Fin(Cache, Route);
        end if;
    end Enregistrer;


   procedure Afficher_Cache (Cache : in T_Cache_L) is
        Cache2 : T_Cache_L := Cache;
    begin
        Put_Line("Cache");
        while Cache2 /= null loop
            Put(Convertir_Adresse(Cache2.all.Route.Adresse));
            Put(" ");
            Put(Convertir_Adresse(Cache2.all.Route.Masque));
            Put(" ");
            Put(Cache2.all.Route.Destination);
            New_Line;
            Cache2 := Cache2.Suivant;
        end loop;
        New_Line;
      end Afficher_Cache;


      procedure Vider (Cache : in out T_Cache_L) is
        Cache2 : T_Cache_L;
    begin
        while Cache /= null loop
            Cache2 := Cache;
            Cache := Cache.Suivant;
            Free(Cache2);
        end loop;
      end Vider;


end Cache_L;

