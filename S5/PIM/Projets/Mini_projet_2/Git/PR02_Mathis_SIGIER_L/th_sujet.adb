with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with TH;

procedure th_sujet is
    
    function FHachage (Cle : in Unbounded_String) return Integer is
    begin
        return (length(Cle));
    end FHachage;
    
    package TH_string is
        new TH (T_Cle=>Unbounded_String, T_Donnee=>Integer, Capacite=>11, Hachage=>FHachage);
    use TH_string;
    
    procedure afficher (Cle : in Unbounded_String ; Donnee : in Integer) is
    begin
        Put("[");
        Put(To_String(Cle));
        Put(" : ");
        Put(Donnee,1);
        Put("]");
        New_Line;
    end afficher;
    
    procedure afficher_th is
        new TH_string.Pour_Chaque(Traiter=>afficher);
    
    TH : T_TH;

begin
    Initialiser(TH);
    Enregistrer(TH, To_Unbounded_String("un"), 1);
    Enregistrer(TH, To_Unbounded_String("deux"), 2);
    Enregistrer(TH, To_Unbounded_String("trois"), 3);
    Enregistrer(TH, To_Unbounded_String("quatre"), 4);
    Enregistrer(TH, To_Unbounded_String("cinq"), 5);
    Enregistrer(TH, To_Unbounded_String("quatre-vingt-dix-neuf"), 99);
    Enregistrer(TH, To_Unbounded_String("vingt-et-un"), 21);
    afficher_th(TH);
end th_sujet;

