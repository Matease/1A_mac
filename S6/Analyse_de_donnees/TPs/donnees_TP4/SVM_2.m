function [X_VS,w,c,code_retour] = SVM_2(X,Y)

    H = [1 0 0 ; 0 1 0 ; 0 0 0];
    f = -ones(lenght(X), 1);
    A = -Y.*[X -ones(length(X),1)];
    b = -ones(length(X),1);

    [alpha_tilde, ~, code_retour, ~] = quadprog(H, f, A, b);
    alpha = alpha_tilde(1:length(X));
    c = w_tilde(3);

    w = sum(alpha.*Y.*X);

    X_VS = X(abs(Y'.*(w'*X' - c)-1)<= 1e-6, :);
end

