%--------------------------------------------------------------------------
% ENSEEIHT - 1SN - Calcul scientifique
% TP1 - Orthogonalisation de Gram-Schmidt
% mgs.m
%--------------------------------------------------------------------------

function Q = mgs(A)

    % Recuperation du nombre de colonnes de A
    [n, m] = size(A);
    
    % Initialisation de la matrice Q avec la matrice A
    Q = A;
    
    %------------------------------------------------
    % Algorithme de Gram-Schmidt modifié
    y = zeros(n,1);
    for i = 1 : 1 : m
        y = A(:,i);
        for j = 1 : 1 : i-1
            coord = dot(y, Q(:,j));
            y = y - coord*Q(:,j);
        end
        Q(:,i) = y/(norm(y));
    end
    %------------------------------------------------

end