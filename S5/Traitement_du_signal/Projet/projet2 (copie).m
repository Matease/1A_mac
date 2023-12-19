clc;
clear all;
close all;

fc = 1080;
delta_f = 100;
f0 = 2000;
f1 = 6000; %changement e valeur poar rapport à l'énoncé
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
f0 = 2000;
f1 = 6000; %changement e valeur poar rapport à l'énoncé
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

%figure(1)
%title('signal NRZ');
%plot(t,NRZ);
%xlabel('t en secondes')
%ylabel('Nrz(t)')
%legend('NRZ')

%DSP de NRZ
DSPs_NRZ = pwelch(NRZ,[],[],[],fe,'twosided'); %DSP simulée
DSPt_NRZ = Ts/4*(sinc(linspace(-fe/2,fe/2,length(DSPs_NRZ)).*Ts)).^2+dirac(linspace(-fe/2,fe/2,length(DSPs_NRZ)))/4;

%figure(2)
%title('DSP NRZ')
%semilogy(linspace(-fe/2,fe/2, length(DSPs_NRZ)), fftshift(DSPs_NRZ),'r')
%hold on;
%xlabel('f');
%ylabel('DSP(f)');
%semilogy(linspace(-fe/2,fe/2, length(DSPs_NRZ)), DSPt_NRZ, 'b')
%legend('DSP théorique NRZ','DSP simulée NRZ')
%grid on;

%3.2 Génération du signal modulé en fréquence
phi0 = rand*2*pi;
phi1 = rand*2*pi;
x = (1-NRZ).*cos(2*pi*f0*t+phi0)+NRZ.*cos(2*pi*f1*t+phi1);
%figure(3)
%plot(t, x)
%title('x(k)');
%xlabel('t en secondes')
%ylabel('x(t)')
%legend('x(t)')
%grid on;

DSPs_x = pwelch(x, [],[],[],fe,'twosided');
%figure(4)
%title('DSP x')
%semilogy(linspace(-fe/2,fe/2, length(DSPs_x)), fftshift(DSPs_x),'r')
%xlabel('f')
%ylabel('DSP')
%grid on;

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
tN = -N:1:N;
hPB = 2*fc/fe*sinc(2*Fc/fe*tN); %la transformée de fourrier est une porte
%HPH = 1 - HPB donc la transformée iinverse est hPH = dirac - hPB
HPH = fft(hPB);
hPH = 1 - 
HPH = 1-2*FcTile;

figure(1)
subplot(1,1,1); plot(hPB)
title("Réponse impulsionnel filtre passe-bas")
subplot(2,1,2); plot (HPH)
title("réponse fréquentiel filtre passe-bas")


