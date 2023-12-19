with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with LCA;



procedure lca_sujet is

    package LCA_string is
         new LCA (T_Cle=>Unbounded_String, T_Donnee=>Integer);
    use LCA_string;

    procedure afficher (Cle : in Unbounded_String; Donnee : in Integer) is
    begin
        Put(To_String(Cle));
        Put(" : ");
        Put(Donnee);
        New_Line;
    end afficher;


    procedure Affichage is new Pour_Chaque (afficher);

    L : LCA_string.T_LCA;
begin
    Initialiser(L);
    Enregistrer (L, To_Unbounded_String("un"), 1);
    Enregistrer (L, To_Unbounded_String("deux"), 2);
    Affichage(L);
end lca_sujet;