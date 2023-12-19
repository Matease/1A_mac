
% TP2 de Statistiques : fonctions a completer et rendre sur Moodle
% Nom : Sigier
% Prénom : Mathis
% Groupe : 1SN-L

function varargout = fonctions_TP2_stat(nom_fonction,varargin)

    switch nom_fonction
        case 'tirages_aleatoires_uniformes'
            [varargout{1},varargout{2}] = tirages_aleatoires_uniformes(varargin{:});
        case 'estimation_Dyx_MV'
            [varargout{1},varargout{2}] = estimation_Dyx_MV(varargin{:});
        case 'estimation_Dyx_MC'
            [varargout{1},varargout{2}] = estimation_Dyx_MC(varargin{:});
        case 'estimation_Dyx_MV_2droites'
            [varargout{1},varargout{2},varargout{3},varargout{4}] = estimation_Dyx_MV_2droites(varargin{:});
        case 'probabilites_classe'
            [varargout{1},varargout{2}] = probabilites_classe(varargin{:});
        case 'classification_points'
            [varargout{1},varargout{2},varargout{3},varargout{4}] = classification_points(varargin{:});
        case 'estimation_Dyx_MCP'
            [varargout{1},varargout{2}] = estimation_Dyx_MCP(varargin{:});
        case 'iteration_estimation_Dyx_EM'
            [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7},varargout{8}] = ...
            iteration_estimation_Dyx_EM(varargin{:});
    end

end

% Fonction centrage_des_donnees (exercice_1.m) ----------------------------
function [x_G, y_G, x_donnees_bruitees_centrees, y_donnees_bruitees_centrees] = ...
                centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees)
     x_G = mean(x_donnees_bruitees);
     y_G = mean(y_donnees_bruitees);
     x_donnees_bruitees_centrees = x_donnees_bruitees - x_G.*ones(1,length(x_donnees_bruitees));
     y_donnees_bruitees_centrees = y_donnees_bruitees - y_G.*ones(1,length(y_donnees_bruitees));
     
end

% Fonction tirages_aleatoires_uniformes (exercice_1.m) ------------------------
function [tirages_angles,tirages_G] = tirages_aleatoires_uniformes(n_tirages,taille)
    tirages_angles = (1-2*rand(n_tirages,1))*pi/2;
    tirages_G = (1-2*rand(n_tirages, 2))*taille;

    % Tirages aleatoires de points pour se trouver sur la droite (sur [-20,20])
    %tirages_G = 0; % A MODIFIER DANS L'EXERCICE 2

end

% Fonction estimation_Dyx_MV (exercice_1.m) -------------------------------
function [a_Dyx,b_Dyx] = ...
           estimation_Dyx_MV(x_donnees_bruitees,y_donnees_bruitees,tirages_psi)
    [x_G, y_G, x_donnees_bruitees_centrees, y_donnees_bruitees_centrees]=centrage_des_donnees(x_donnees_bruitees, y_donnees_bruitees);
    [~, indmin] = min(sum((y_donnees_bruitees_centrees-x_donnees_bruitees_centrees.*tan(tirages_psi)).^2));
    a_Dyx = tan(tirages_psi(indmin));
    b_Dyx = y_G - a_Dyx*x_G;


end

% Fonction estimation_Dyx_MC (exercice_1.m) -------------------------------
function [a_Dyx,b_Dyx] = ...
                   estimation_Dyx_MC(x_donnees_bruitees,y_donnees_bruitees)
    A = transpose([x_donnees_bruitees; ones(1,length(x_donnees_bruitees))]);
    B = transpose(y_donnees_bruitees);
    Xetoiles = A\B;
    a_Dyx = Xetoiles(1);
    b_Dyx = Xetoiles(2);


end

% Fonction estimation_Dyx_MV_2droites (exercice_2.m) -----------------------------------
function [a_Dyx_1,b_Dyx_1,a_Dyx_2,b_Dyx_2] = ... 
         estimation_Dyx_MV_2droites(x_donnees_bruitees,y_donnees_bruitees,sigma, ...
                                    tirages_G_1,tirages_psi_1,tirages_G_2,tirages_psi_2)
    rab1 = y_donnees_bruitees - tirages_G_1(:,2) - tan(tirages_psi_1).*(x_donnees_bruitees-tirages_G_1(:,1));
    rab2 = y_donnees_bruitees - tirages_G_2(:,2) - tan(tirages_psi_2).*(x_donnees_bruitees-tirages_G_2(:,2));

    exp1 = exp(-rab1.^2/(2*sigma^2));
    exp2 = exp(-rab2.^2/(2*sigma^2));
    [~, indmax] = max(sum(log(exp1+exp2),2));
    
    a_Dyx_1 = tan(tirages_psi_1(indmax));
    b_Dyx_1 = tirages_G_1(indmax,2) - a_Dyx_1*tirages_G_1(indmax,1);

    a_Dyx_2 = tan(tirages_psi_2(indmax));
    b_Dyx_2 = tirages_G_2(indmax,2) - a_Dyx_2*tirages_G_2(indmax,1);
end

% Fonction probabilites_classe (exercice_3.m) ------------------------------------------
function [probas_classe_1,probas_classe_2] = probabilites_classe(x_donnees_bruitees,y_donnees_bruitees,sigma,...
                                                                 a_1,b_1,proportion_1,a_2,b_2,proportion_2)
    rab1 = y_donnees_bruitees - a_1.*x_donnees_bruitees-b_1;
    rab2 = y_donnees_bruitees - a_2.*x_donnees_bruitees-b_2;
    exp1 = exp(-rab1.^2/(2*sigma^2));
    exp2 = exp(-rab2.^2/(2*sigma^2));
    s = proportion_1*exp1 + proportion_2*exp2;
    probas_classe_1 = proportion_1*exp1./s;
    probas_classe_2 = proportion_2*exp2./s;

end

% Fonction classification_points (exercice_3.m) ----------------------------
function [x_classe_1,y_classe_1,x_classe_2,y_classe_2] = classification_points ...
              (x_donnees_bruitees,y_donnees_bruitees,probas_classe_1,probas_classe_2)

    
    
    ind_classe_1 = (probas_classe_1 > probas_classe_2);
    ind_classe_2 = (probas_classe_2 >= probas_classe_1);
    x_classe_1 = x_donnees_bruitees(ind_classe_1);
    x_classe_2 = x_donnees_bruitees(ind_classe_2);
    y_classe_1 = y_donnees_bruitees(ind_classe_1);
    y_classe_2 = y_donnees_bruitees(ind_classe_2);


end

% Fonction estimation_Dyx_MCP (exercice_4.m) -------------------------------
function [a_Dyx,b_Dyx] = estimation_Dyx_MCP(x_donnees_bruitees,y_donnees_bruitees,probas_classe)
    A = probas_classe' .* [x_donnees_bruitees', ones(size(x_donnees_bruitees,2), 1)];

    B = probas_classe' .* y_donnees_bruitees';
    X = A \ B;
    a_Dyx = X(1);
    b_Dyx = X(2);

    
end

% Fonction iteration_estimation_Dyx_EM (exercice_4.m) ---------------------
function [probas_classe_1,proportion_1,a_1,b_1,probas_classe_2,proportion_2,a_2,b_2] =...
         iteration_estimation_Dyx_EM(x_donnees_bruitees,y_donnees_bruitees,sigma,...
         proportion_1,a_1,b_1,proportion_2,a_2,b_2)

[probas_classe_1,probas_classe_2] = probabilites_classe(x_donnees_bruitees,y_donnees_bruitees,sigma,a_1,b_1,proportion_1,a_2,b_2,proportion_2);

proportion_1 = mean(probas_classe_1);
proportion_2 = mean(probas_classe_2);

[a_1, b_1] = estimation_Dyx_MCP(x_donnees_bruitees,y_donnees_bruitees,probas_classe_1);
[a_2, b_2] = estimation_Dyx_MCP(x_donnees_bruitees,y_donnees_bruitees,probas_classe_2);

end
