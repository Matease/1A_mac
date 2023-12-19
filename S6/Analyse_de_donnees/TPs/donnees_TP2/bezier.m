function y = bezier(x, beta) 
    d = length(beta)-1;
    B0 = beta(1)*(1-x(0))^(d);
    B = zeros(1,d);
    for k = 1:d
        y = y + beta(k+1)*nchoosek(d,k)*(x.^k).*(1-x).^(d-k);
    end
end