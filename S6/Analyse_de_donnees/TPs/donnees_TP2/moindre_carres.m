function parametres = moindre_carres(d,x,y,parametre_0)
    A = zeros(size(x,1),d);
    for k = 1:d
        A(:,k) = nchoosek(d,k)*x.^k.*(1-x).^(d-k);
    end
    B = y - parametre_0*(1-x).^d;
    parametres = A\B;
end