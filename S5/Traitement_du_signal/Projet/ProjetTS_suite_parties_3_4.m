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
