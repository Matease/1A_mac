function [X_VS, w, c, code_retour] = SVM_1(X, Y)

% On fixe la tolérance
epsilon = 1e-6;
N = length(X);

% On détermine la matrice H, A et b
H = zeros(3, 3);
H(1, 1) = 1;
H(2, 2) = 1;
A = [-Y.*X(:, 1) -Y.*X(:, 2) Y];
b = - ones(1, N);

f = zeros(3, 1);

% On utilise quadprog
[concat, ~, code_retour] = quadprog(H, f, A, b);

% On reconstitue w et c
w = concat(1:2);
c = concat(3);

% On trouve les vecteurs supports
X_VS = X(Y.*(X * w - c) - 1 <= epsilon, :);

end