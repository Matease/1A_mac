clear;
close all;
clc;

taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

figure('Name','Visualisation des canaux RVB (canal par canal et en 3D)',...
       'Position',[0.1*L,0.05*H,0.8*L,0.75*H]);

% Lecture d'une image RVB :
%I = imread('autumn.tif');
 I = imread('image.png');

% Decoupage de l'image en trois canaux et conversion en doubles :
R = double(I(:,:,1));
V = double(I(:,:,2));
B = double(I(:,:,3));

% Affichage de l'image RVB :
subplot(2,3,1);
imagesc(I);
axis image off;
title('Image RVB','FontSize',20);

% Affichage du canal R :
colormap gray;
subplot(2,3,2);
imagesc(R);
axis image off;
title('Canal R','FontSize',20);

% Affichage du canal V :
subplot(2,3,4);
imagesc(V);
axis image off;
title('Canal V','FontSize',20);

% Affichage du canal B :
subplot(2,3,5);
imagesc(B);
axis image off;
title('Canal B','FontSize',20);

% Affichage du nuage de pixels dans le repere RVB :
subplot(1,3,3);
plot3(R,V,B,'.','MarkerSize',3,'Color',"#4DBEEE")
axis equal;
set(gca,'FontSize',10);
xlabel('R','FontWeight','bold','FontSize',15,'Color','red')
ylabel('V','FontWeight','bold','FontSize',15,'Color',[0,0.5,0.2])
zlabel('B','FontWeight','bold','FontSize',15,'Color','blue')
view([45 20])
rotate3d;
grid on;
title({'Representation 3D des pixels' ...
       'dans l''espace RVB'},'FontSize',20)

% Matrice des donnees :
X = [R(:) V(:) B(:)];		% Les trois canaux sont vectorises et concatenes



[correlation,contraste] = correlation_contraste(X);

% Affichage des resultats :
fprintf('Correlation entre R et V = %.3f\n',correlation(1));
fprintf('Correlation entre R et B = %.3f\n',correlation(2));
fprintf('Correlation entre V et B = %.3f\n',correlation(3));

fprintf('Proportion de contraste dans le canal R = %.3f\n',contraste(1));
fprintf('Proportion de contraste dans le canal V = %.3f\n',contraste(2));
fprintf('Proportion de contraste dans le canal B = %.3f\n',contraste(3));

save exercice_1;


function [correlation,contraste] = correlation_contraste(X)

    Xr = X - mean(X);
    Xr2 = Xr./(sqrt(mean(X.^2)));

    Sigma = transpose(Xr2)*Xr2./(size(X,1));

    ec1 = sqrt(Sigma(1,1)); %écart-type
    ec2 = sqrt(Sigma(2,2));
    ec3 = sqrt(Sigma(3,3));

    r12 = Sigma(1,2)/(ec1*ec2);
    r13 = Sigma(1,3)/(ec1*ec3);
    r23 = Sigma(2,3)/(ec2*ec3);

    correlation = [r12 r13 r23];

    svariance = Sigma(1,1) + Sigma(2,2) + Sigma(3,3);
    c1 = Sigma(1,1)/svariance;
    c2 = Sigma(2,2)/svariance;
    c3 = Sigma(3,3)/svariance;

    contraste = [c1 c2 c3];

end
