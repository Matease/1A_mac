function [X_VS,w,c,code_retour] = SVM_1(X,Y)

    H = [1 0 0 ; 0 1 0 ; 0 0 0];
    f = zeros(3, 1);
    A = -Y.*[X -ones(length(X),1)];
    b = -ones(length(X),1);

    [w_tilde, ~, code_retour, ~] = quadprog(H, f, A, b);
    w = w_tilde(1:2);
    c = w_tilde(3);

    X_VS = X(abs(Y'.*(w'*X' - c)-1)<= 1e-6, :);
end

