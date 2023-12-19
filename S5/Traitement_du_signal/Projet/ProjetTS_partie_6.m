clc;
clear all;
close all;

fc = 1080;
delta_f = 100;
f0 = 6000;
f1 = 2000; %changement de valeur poar rapport à l'énoncé
fe = 48000;
Te = 1/fe;
Rb = 300; %Débit binaire
Tb = 1/Rb;
Ts = Tb;
Ns = floor((Ts)/(Te)); %floor partie entière


%% 6 Démodulateur de fréquence adapté à la norme V21

%6.1 Synchronisation idéale

bits = randi([0,1],1,1000);
NRZ = kron(bits, ones(1,Ns));
N = length(NRZ);
t = 0:Te:(N-1)*Te;

phi0 = rand*2*pi;
phi1 = rand*2*pi;
x = (1-NRZ).*cos(2*pi*f0*t+phi0)+NRZ.*cos(2*pi*f1*t+phi1);

SNRdb = 50;
Px = mean(abs(x).^2);
Pb = Px/(10^(SNRdb/10));
sigma = sqrt(Pb);
bruitG = sigma*rand(1,N);
y = x + bruitG;

F0 = 1180;
F1 = 980;
x1 = (1-NRZ).*cos(2*pi*F0*t+phi0)+NRZ.*cos(2*pi*F1*t+phi1);
y1 = x1 + bruitG;

yF0 = y1 .*cos(2*pi*F0*t+ phi0);
yF1 = y1 .* cos(2*pi*F1*t + phi1);

figure(9)
plot(yF0)
%legend("yF0 avec une phase phi0 aléatoire sur [0;2pi]. (F0 = 1080 Hz)")
%xlabel('t (en seconde)')

hold on;
plot(yF1)
legend("yF0 avec une phase phi0 aléatoire sur [0;2pi]. (F0 = 1080 Hz)","yF1 avec une phase phi1 aléatoire sur [0;2pi]. (F1 = 980 Hz)")
xlabel('t (en seconde)')


yF0Final = reshape(yF0, Ns, 1000);
yF1Final = reshape(yF1, Ns, 1000);

integrale0 = sum(yF0Final);
integrale1 = sum(yF1Final);

somme = integrale1 - integrale0 ;
detection2  = (sign(somme)+1)/2;
taux_erreur_binaire2 = length(find(bits~=detection2 ))/ 1000

%on doit avoir un TEB de 0

%utiliser bitesign = (sign(s) + 1)/2

%on obtient un signla NRZ à la fin du traitement(cf schema de la partie
%6.1)

%quand on chnage de phases, le démodulateur ne fonctionne plus correctement


%6.2 Gestion d'une erreur de synchronisation de phase porteuse


phi0p = rand*2*pi; 
phi1p = rand*2*pi;

yF0p = y1 .*cos(2*pi*F0*t+phi0p); 
yF1p = y1 .* cos(2*pi*F1*t+phi1p);

yF0Finalp = reshape(yF0p, Ns, 1000); 
yF1Finalp = reshape(yF1p, Ns, 1000);

integrale0p = sum(yF0Finalp); 
integrale1p = sum(yF1Finalp);

somme2 = integrale1p - integrale0p ;
detection3  = (sign(somme2)+1)/2;
taux_erreur_binaire3 = length(find(bits~=detection3 ))/ 1000;


% 6.3 

yFSK0 = y1 .*cos(2*pi*F0*t+phi0p); 
yFSK1 = y1 .*sin(2*pi*F0*t+phi0p);
yFSK2 = y1 .*cos(2*pi*F1*t+phi1p); 
yFSK3 = y1 .*sin(2*pi*F1*t+phi1p); 

yFSK0Final = reshape(yFSK0, Ns, 1000); 
yFSK1Final = reshape(yFSK1, Ns, 1000); 
yFSK2Final = reshape(yFSK2, Ns, 1000); 
yFSK3Final = reshape(yFSK3, Ns, 1000); 


sommeFSK = sum(yFSK3Final).^2 + sum(yFSK2Final).^2 - sum(yFSK1Final).^2 - sum(yFSK0Final).^2;
detectionFSK  = (sign(sommeFSK)+1)/2;
taux_erreur_binaireTSK = length(find(bits~=detectionFSK ))/ 1000

%cette technique permet de corriger le porbleme de différence de phase car
%en sommant ces integrales au carré on à des résultats qui ne dépendent pas des
%différentes phases car la somme de cos^2 et sin^2 vaut 1.



