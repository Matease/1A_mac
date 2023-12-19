with Adresse_IP; use Adresse_IP;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Complements_Cache_L is

    Option_Error : Exception;
    Route_Absente_Error : Exception;
    Cache_vide_Error : Exception;

    type T_route is record
        Adresse : T_adresse_IP;
        Masque : T_adresse_IP;
        Interface_Associee : Unbounded_String;
   end record;


 end Complements_Cache_L;
