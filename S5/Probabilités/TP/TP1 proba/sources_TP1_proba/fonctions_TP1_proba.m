
% TP1 de Probabilites : fonctions a completer et rendre sur Moodle
% Nom : Sigier & David
% Prénom : Mathis & Capucine
% Groupe : 1SN-L

function varargout = fonctions_TP1_proba(nom_fonction, varargin)

    switch nom_fonction
        case 'G_et_R_moyen'
            [varargout{1},varargout{2},varargout{3}] = G_et_R_moyen(varargin{:});
        case 'tirages_aleatoires_uniformes'
            [varargout{1},varargout{2}] = tirages_aleatoires_uniformes(varargin{:});
        case 'estimation_C'
            varargout{1} = estimation_C(varargin{:});
        case 'estimation_C_et_R'
            [varargout{1},varargout{2}] = estimation_C_et_R(varargin{:});
        case 'occultation_donnees'
            [varargout{1},varargout{2}] = occultation_donnees(varargin{:});
    end

end

% Fonction G_et_R_moyen (exercice_0.m) ------------------------------------
function [G, R_moyen, distances] = G_et_R_moyen(x_donnees_bruitees,y_donnees_bruitees)
    G = [mean(x_donnees_bruitees) mean(y_donnees_bruitees)];
    x_donnees_bruitees=(x_donnees_bruitees-G(1)).^2;
    y_donnees_bruitees=(y_donnees_bruitees-G(2)).^2;
    distances=sqrt([x_donnees_bruitees+y_donnees_bruitees]);
    R_moyen=mean(distances);
        
end

% Fonction tirages_aleatoires (exercice_1.m) ------------------------------
function [tirages_C,tirages_R] = tirages_aleatoires_uniformes(n_tirages,G,R_moyen)
    tirages_R=0;
    tirages_C=G+(rand(n_tirages,2)-0.5)*2*R_moyen
    


end

% Fonction estimation_C (exercice_1.m) ------------------------------------
function C_estime = estimation_C(x_donnees_bruitees,y_donnees_bruitees,tirages_C,R_moyen)
    n_tirages=size(tirages_C,1)
    pause
    X=repmat(x_donnees_bruitees,1,n_tirages);
    pause
    Cx=repmat(tirages_C(:,1),length(x_donnees_bruitees),1);
    pause
    Y=repmat(y_donnees_bruitees,1,n_tirages);
    pause
    Cy=repmat(tirages_C(:,2),length(y_donnees_bruitees),1);
    pause
    Mx=(X-Cx).^2;
    pause
    My=(Y-Cy).^2;
    pause
    M=(sqrt(Mx+My)-R_moyen).^2;
    pause
    D=sum(M,2);
    pause
    [~,i]=min(D)
    pause
    C_estime=tirages_C(i,:)
    pause


end

% Fonction estimation_C_et_R (exercice_2.m) -------------------------------
function [C_estime, R_estime] = ...
         estimation_C_et_R(x_donnees_bruitees,y_donnees_bruitees,tirages_C,tirages_R)



end

% Fonction occultation_donnees (donnees_occultees.m) ----------------------
function [x_donnees_bruitees_visibles, y_donnees_bruitees_visibles] = ...
         occultation_donnees(x_donnees_bruitees, y_donnees_bruitees, ...
                             theta_donnees_bruitees, theta_1, theta_2)
    


end

