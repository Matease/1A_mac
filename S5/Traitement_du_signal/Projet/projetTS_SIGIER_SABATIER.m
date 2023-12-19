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

%% 3 Modem de fréquence
%3.1
%Génération du signal NRZ

bits = randi([0,1],1,1000);
NRZ = kron(bits, ones(1,Ns));
N = length(NRZ);
t = 0:Te:(N-1)*Te;

figure(1)
title('signal NRZ');
plot(t,NRZ);
xlabel('t en secondes')
ylabel('Nrz(t)')
legend('NRZ')

%DSP de NRZ
DSPs_NRZ = pwelch(NRZ,[],[],[],fe,'twosided'); %DSP simulée
DSPt_NRZ = Ts/4*(sinc(linspace(-fe/2,fe/2,length(DSPs_NRZ)).*Ts)).^2+dirac(linspace(-fe/2,fe/2,length(DSPs_NRZ)))/4;

figure(2)
title('DSP NRZ')
semilogy(linspace(-fe/2,fe/2, length(DSPs_NRZ)), fftshift(DSPs_NRZ),'r')
hold on;
xlabel('f');
ylabel('DSP(f)');
semilogy(linspace(-fe/2,fe/2, length(DSPs_NRZ)), DSPt_NRZ, 'b')
legend('DSP théorique NRZ','DSP simulée NRZ')
grid on;

%3.2 Génération du signal modulé en fréquence
phi0 = rand*2*pi;
phi1 = rand*2*pi;
x = (1-NRZ).*cos(2*pi*f0*t+phi0)+NRZ.*cos(2*pi*f1*t+phi1);

figure(3)
plot(t, x)
title('x(k)');
xlabel('t en secondes')
ylabel('x(t)')
legend('x(t)')
grid on;

DSPs_x = pwelch(x, [],[],[],fe,'twosided');
figure(4)
title('DSP x')
semilogy(linspace(-fe/2,fe/2, length(DSPs_x)), fftshift(DSPs_x),'r')
xlabel('f')
ylabel('DSP')
grid on;

%% Canal de transmission à bruit additif, blanc et gaussien
%faire démo trouver formule passe bas idéal

Px = mean(abs(x).^2);

clc;
clear all;
close all;

fc = 1080;
delta_f = 100;
f0 = 6000;
f1 = 2000; %changement de valeur par rapport à l'énoncé
fe = 48000;
Te = 1/fe;
Rb = 300; %Débit binaire
Tb = 1/Rb;
Ts = Tb;
Ns = floor((Ts)/(Te)); %floor partie entière

%% 3 Modem de fréquence
%3.1
%Génération du signal NRZ

bits = randi([0,1],1,1000);
NRZ = kron(bits, ones(1,Ns));
N = length(NRZ);
t = 0:Te:(N-1)*Te;

figure(1)

plot(t,NRZ);
title("signal NRZ")
xlabel('t en secondes')
ylabel('Nrz(t)')
legend('NRZ')

%DSP de NRZ
DSPs_NRZ = pwelch(NRZ,[],[],[],fe,'twosided'); %DSP simulée
DSPt_NRZ = Ts/4*(sinc(linspace(-fe/2,fe/2,length(DSPs_NRZ)).*Ts)).^2+dirac(linspace(-fe/2,fe/2,length(DSPs_NRZ)))/4;

figure(2)
title('DSP NRZ')
semilogy(linspace(-fe/2,fe/2, length(DSPs_NRZ)), fftshift(DSPs_NRZ),'r')
hold on;
xlabel('f');
ylabel('DSP(f)');
semilogy(linspace(-fe/2,fe/2, length(DSPs_NRZ)), DSPt_NRZ, 'b')
legend('DSP théorique NRZ','DSP simulée NRZ')
grid on;

%3.2 Génération du signal modulé en fréquence
phi0 = rand*2*pi;
phi1 = rand*2*pi;
x = (1-NRZ).*cos(2*pi*f0*t+phi0)+NRZ.*cos(2*pi*f1*t+phi1);

figure(3)
plot(t, x)
title('x(k)');
xlabel('t en secondes')
ylabel('x(t)')
legend('x(t)')
grid on;

DSPs_x = pwelch(x, [],[],[],fe,'twosided');

figure(4)
semilogy(linspace(-fe/2,fe/2, length(DSPs_x)), fftshift(DSPs_x),'r')
title("DSP x")
xlabel('f')
ylabel('DSP')
grid on;

%% 4 Canal de transmission à bruit additif, blanc et gaussien
%faire démo trouver formule passe bas idéal à faire

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




%% 6 Démodulateur de fréquence adapté à la norme V21

%6.1 Synchronisation idéale


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














