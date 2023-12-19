
% TP2 de Probabilites : fonctions a completer et rendre sur Moodle
% Nom :
% Prenom : 
% Groupe : 1SN-

function varargout = fonctions_TP2_proba(nom_fonction,varargin)

    switch nom_fonction
        case 'calcul_histogramme_image'
            [varargout{1},varargout{2},varargout{3}] = calcul_histogramme_image(varargin{:});
        case 'vectorisation_par_colonne'
            [varargout{1},varargout{2}] = vectorisation_par_colonne(varargin{:});
        case 'calcul_parametres_correlation'
            [varargout{1},varargout{2},varargout{3}] = calcul_parametres_correlation(varargin{:});
        case 'decorrelation_colonnes'
            varargout{1} = decorrelation_colonnes(varargin{:});
        case 'encodage_image'
            varargout{1} = encodage_image(varargin{:});
        case 'coeff_compression'
            varargout{1} = coeff_compression(varargin{:});
        case 'gain_compression'
            varargout{1} = gain_compression(varargin{:});
    end

end

% Fonction calcul_histogramme_image (exercice_1.m) ------------------------
function [histogramme, I_min, I_max] = calcul_histogramme_image(I)
    I_min = min(min(I));
    I_max = max(max(I));
    histogramme=histcounts(I,I_min:I_max+1);
end

% Fonction vectorisation_par_colonne (exercice_1.m) -----------------------
function [Vg,Vd] = vectorisation_par_colonne(I)
    vectorise_I = I(:);
    nb_lignes = size(I, 1);
    nb_colonnes = size(I, 2);
    nb_total = nb_colonnes*nb_lignes;
    Vg=vectorise_I(1:nb_total-nb_lignes);
    Vd=vectorise_I(nb_lignes+1:nb_total);
end

% Fonction calcul_parametres_correlation (exercice_1.m) -------------------
function [r,a,b] = calcul_parametres_correlation(Vd,Vg)
    moyVg = mean(Vg); %Liste Y
    moyVd = mean(Vd); %liste X
    Vgmoinsmoy = Vg - moyVg;
    Vdmoinsmoy = Vd - moyVd;
    Vg2 = Vgmoinsmoy.*Vgmoinsmoy;
    Vd2 = Vdmoinsmoy.*Vdmoinsmoy;
    sigmaVg = sqrt(sum(Vg2)/length(Vg2));
    sigmaVd = sqrt(sum(Vd2)/length(Vd2));
    sigmaVgVd = sum(Vd.*Vg)/length(Vg)-moyVd*moyVg;
    r = sigmaVgVd/(sigmaVd*sigmaVg);
    a = sigmaVgVd/(sigmaVd^2);
    b = moyVg - (moyVd*sigmaVgVd)/(sigmaVd^2);
end

% Fonction decorrelation_colonnes (exercice_2.m) --------------------------
function I_decorrelee = decorrelation_colonnes(I)
    I_decorrelee = I;
    I_decorrelee(:, 2:end) = I_decorrelee(:, 2:end) - I_decorrelee(:,1:end -1);
end

% Fonction encodage_image (exercice_3.m) ----------------------------------
function I_encodee = encodage_image(I)
    


end

% Fonction coeff_compression (exercice_3.m) -------------------------------
function coeff_comp = coeff_compression(signal_non_encode,signal_encode)



end

% Fonction coeff_compression (exercice_3.m) -------------------------------
function gain_comp = gain_compression(coeff_comp_avant,coeff_comp_apres)



end

