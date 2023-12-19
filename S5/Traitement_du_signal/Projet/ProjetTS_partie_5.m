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

bits = randi([0,1],1,1000);
NRZ = kron(bits, ones(1,Ns));
N = length(NRZ);
t = 0:Te:(N-1)*Te;

phi0 = rand*2*pi;
phi1 = rand*2*pi;
x = (1-NRZ).*cos(2*pi*f0*t+phi0)+NRZ.*cos(2*pi*f1*t+phi1);

Px = mean(abs(x).^2);
SNRdb = 50;
Pb = Px/(10^(SNRdb/10));
sigma = sqrt(Pb);
bruitG = sigma*rand(1,N);
y = x + bruitG;

%% 5 Démodulation par filtrage
%synthèse du filtre passe-bas
F0 = 6000;
F1 = 2000;
Fc = (F0+F1)/2; %la fréquence de coupure est la moyenne car est entre F0 et F1
FcTile = Fc/fe;
ordre = 61;
tN = -(ordre-1)/2:(ordre-1)/2;
hPB = 2*fc/fe*sinc(2*Fc/fe*tN); %la transformée de fourrier est une porte
%HPH = 1 - HPB donc la transformée iinverse est hPH = dirac - hPB
HPH = fft(hPB, 2024);
hPH = -hPB;
hPH((ordre+1)/2) = 1 -2*FcTile;
%hPH = 1 - 
%HPH = 1-2*FcTile;

figure(5)
subplot(2,1,1); plot(hPB)

title("Réponse impulsionnelle filtre passe-bas")

subplot(2,1,2); plot (HPH)
title("réponse fréquentielle filtre passe-bas")


figure(6)
subplot(2,1,1); plot(hPH)
title("Réponse impulsionnelle filtre passe-haut")
subplot(2,1,2); plot(HPH)
title("Réponse féquentielle filtre passe-haut")




% 5.5

% Réalisation du filtrage passe-bas

signalfiltre = filter(hPB,1,y);


figure(7)
plot(signalfiltre)
title("sigal y filtré par le passe bas")
legend("signal filtré")
ylabel('yfiltré(t)')
xlabel('t (en seconde)')

s = reshape(signalfiltre,Ns,1000);
energie = sum(abs(s).^2,1);
seuil_K = (max(energie)-min(energie))/2;
detection = energie > seuil_K;


diff = bits - detection;
taux_erreur_binaire = length(find(bits - detection ~= 0))/ 1000;


% Changement de l'odre du filtre à 201

ordre2 = 201;
tN2 = -(ordre2-1)/2:(ordre2-1)/2;
hPB2 = 2*fc/fe*sinc(2*Fc/fe*tN2);
signalfiltre2 = filter(hPB2,1,y);

figure(8)
plot(signalfiltre2)
title("sigal y filtré par le passe haut")
legend("signal filtré")
ylabel('yfiltré(t)')
xlabel('t (en seconde)')

s = reshape(signalfiltre2,Ns,1000);
energie = sum(abs(s).^2,1);
seuil_K = (max(energie)-min(energie))/2;
detection = energie > seuil_K;


diff = bits - detection;
taux_erreur_binaire = length(find(bits - detection ~= 0))/ 1000;

% On trouve TEB ~= 1/2 donc pas bon du tout
% Vu le grand ordre du filtre il faut gérer le retard 

ordre2 = 201;
tN2 = -(ordre2-1)/2:(ordre2-1)/2;
hPB2 = 2*fc/fe*sinc(2*Fc/fe*tN2);

signalfiltre2 = filter(hPB2,1,[y,zeros(1,(ordre2-1)/2)]);
signalfinal2 = signalfiltre2((ordre2-1)/2: end);

%s = reshape(signalfinal2,Ns,1000);
%energie = sum(abs(s).^2,1);
%seuil_K = (max(energie)-min(energie))/2;
%detection = energie > seuil_K;

%diff = bits - detection;
%taux_erreur_binaire = length(find(bits - detection ~= 0))/ 1000;


