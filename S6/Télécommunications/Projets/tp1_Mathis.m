clear all
clc;
close all

Fe = 24000; %fréquence d'échantillonnage(/seconde)
Te = 1/Fe;
Rb = 3000; %débit binaire (bit/sec)
Tb = 1/Rb;


%% Modulateur 1

M1 = 2;
Ns = Fe/Rb;
Ts = Ns*Te;
nb_bits = 1000;
t = 0 : Te : (nb_bits-1)*Te;
bits = randi([0,1],1,nb_bits);
%génération de symbole binaires à moyene nulle
symboles = 2.*bits-1;

%réponse impulsionnelle d'un filtre de forme rectngulaire de hauteur 1 et
%de durée égale à la durée symbole
h = ones(1, Ns);

%Génératio peigne de dirac sur le signal symboles
dirac_symbole = kron(symboles, [1 zeros(1,Ns-1)]);

%filtrage du signal généré
sigalfiltre = filter(h,1, dirac_symbole);
%calcul de la DSP


DSP_x = fftshift(pwelch(sigalfiltre, [],[],[], Fe, 'twosided'));
f = linspace(-Fe/2,Fe/2, length(DSP_x));
% DSPt_x = Ts.* (sinc(f*Ts)).^2; %DSP théorique
DSPt_x = Ts.* (sinc(f*Ts)).^2+Ts.* (sinc((f-Fe)*Ts)).^2+Ts.* (sinc((f+Fe)*Ts)).^2; %DSP théorique

%affichage
figure(1)

subplot(2,1,1); plot(sigalfiltre)
axis([1,nb_bits,-2,2])
title("Signal généré modulateur 1")
xlabel("t en secondes")
grid on;

subplot(2,1,2); semilogy(f, DSP_x);

xlabel("fréquence en Hz")
hold on 


semilogy(f,DSPt_x)
title("DSP simulée et théorique du signal généré")
legend("simulée","théorique")
grid on;

%% Modulateur 2

%parametres du modulateur 2
M2 = 2;
Ts2 = log2(M2)*Tb;
Rs2 = Rb./log2(M2);
Ns2 = Fe/Rs2;

%génération des bits et symboles
bits_2 = randi([0,1],1,nb_bits);
bits2_2 = reshape (bits_2, [2, nb_bits/2]);
bit2_f = bi2de (bits2_2'); % conversion des éléments binaires en décimal 2 à 2, on a donc des éléments entiers entre 0 et 3
symboles2 = 2*bit2_f - 3;
dirac_symbole2 = kron(symboles2, [1 zeros(1,Ns2-1)]);

%filtrage des symboles
signalfiltre2 = filter(h,1, dirac_symbole2);


%calcul des DSP
%DSP numérique
DSP_x2 = fftshift(pwelch(signalfiltre2, [],[],[], Fe, 'twosided'));
f2 = linspace(-Fe/2,Fe/2, length(DSP_x2));
%DSP théorique
DSPt_x2 = Ts2.* (sinc(f2*Ts2)).^2+Ts2.* (sinc((f2-Fe)*Ts2)).^2+Ts2.* (sinc((f2+Fe)*Ts2)).^2; %DSP théorique

%affichage
figure(2)

subplot(2,1,1); plot(signalfiltre2)
axis([1,nb_bits/2,-15,15])
title("Signal généré 4 aires du modulateur 2")
xlabel("t en secondes")
grid on;

subplot(2,1,2); semilogy(f2, DSP_x2);

xlabel("fréquence en Hz")
hold on 


semilogy(f2,DSPt_x2)
title("DSP simulée et théorique du signal généré 4 aires")
legend("simulée","théorique")
grid on;

%% Modulateur 3
M3=2;
Ts3=log2(M3)*Tb;
Rs=Rb./log2(M3);
Ns3=Fe/Rs;%nombre de période echantillonage par période symbole


bits = randi([0 1],1,nb_bits);
symboles=2.*bits-1;%Mapping binaire à moyenne nulle
alpha =rand(1);
L = 10;

h3 = rcosdesign(alpha,L,Ns3);

Dirac3 = kron(symboles, [1 zeros(1,Ns3-1)]);
x_f = filter(h3,1,Dirac3);
z = filter(h3,1,x_f);
%eyediagram(z,2*Ns3,2*Ns3);%faire le eyediagram pour savoir comment prendre leL
% figure(5)
% plot(h3,'b');
% title('x filtrée')
% xlabel('x filtré 3')
% 


Nsimu=100;

DSP3=0;
for k=1:Nsimu
    bits = randi([0 1],1,nb_bits);
    symboles=2.*bits-1;%Mapping binaire à moyenne nulle
    Dirac3 = kron(symboles, [1 zeros(1,Ns3-1)]);
    x_f = filter(h3,1,Dirac3);
    DSP3=DSP3+pwelch(x_f,[],[],2^nextpow2(length(x_f)),1,'twosided');
end
DSP3=DSP3/Nsimu;
DSP3_theorique = zeros(length(DSP3),1);
f1=linspace(-Fe/2,Fe/2,length(DSP3));
variance=var(symboles);
for i = 1:length(DSP3)
    if (abs(f1(i)) < (1-alpha)/(2*Ts3))
        DSP3_theorique(i) = variance;
    elseif ((abs(f1(i)) < (1+alpha)/(2*Ts3))) 
        if ((abs(f1(i)) > (1-alpha)/(2*Ts3)))
            DSP3_theorique(i) = variance/2*(1+cos(pi*Ts3/alpha*(abs(f1(i))-(1-alpha)/(2*Ts3))));
        end
    else
        DSP3_theorique(i) = 0;
    end
end

figure(5)
semilogy(linspace(-Fe/2,Fe/2,length(DSP3_theorique)),(abs(DSP3_theorique)),'b');hold on;
semilogy(linspace(-Fe/2,Fe/2,length(DSP3)),fftshift(DSP3),'r');
grid on;
legend('DSP3 Theorique','DSP Experimentale')


%% Etude des interferences
%ordre = Ns*L -1;
%3.1
Ns1=8;
Dirac1 = kron(symboles, [1 zeros(1,Ns1-1)]);%NS-1
h1=ones(1,Ns1);
x_filtre1 = filter(h1,1,Dirac1);
hr=fliplr(h1);%explication sur TP1BE, flip les éléments du tableau 
% (ici h1 n'est composé que de 1 donc ca ne sert à rien)
z1= filter(hr,1,x_filtre1);
n0=8;


 
g1=conv(h1,hr);

z_echant=z1(n0:Ns1:nb_bits/log2(M1)*Ns1);%Echantillonage ici 
TEB=sum((z_echant>0)~=bits)/nb_bits;
figure(6)
plot(reshape(z_echant,Ns1,length(z_echant)/Ns1));

%3.2----------------------------------------------------------

fc1=8000/(Fe/2); %fir1 (ordre, frequence de coupure normalisée/(Fe/2))
fc2 = 1000/(Fe/2);
hb1=fir1(M1,fc1);
hb2=fir1(M1,fc2);

gb1 = conv(g1,hb1);
gb2 = conv(g1,hb2);
r1 = filter(hb1,1,x_filtre1);
r2 = filter(hb2,1,x_filtre1);


%signaux de sortie
zb1 = filter(hr,1,r1);
zb2 = filter(hr,1,r2);

z_echantb1=zb1(n0:Ns1:nb_bits/log2(M1)*Ns1);%Echantillonage ici 
TEB2=sum((z_echantb1>0)~=bits)/nb_bits;
z_echantb2=zb1(n0:Ns1:nb_bits/log2(M1)*Ns1);%Echantillonage ici 
TEB3=sum((z_echantb2>0)~=bits)/nb_bits;

figure(7)
plot(gb1,'b');hold on;
plot(gb2,'r');

figure(8)
plot(reshape(zb1,Ns1,length(zb1)/Ns1));
legend("diagramme de l'oeil  zb1")
figure(9)
plot(reshape(zb2,Ns1,length(zb2)/Ns1));
legend("diagramme de l'oeil zb2")
