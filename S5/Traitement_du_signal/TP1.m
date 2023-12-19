
clc;
clear all;
close all;

Fe=10000;%critère de shanon : fe<2*fmax
Te=1/Fe;
N=90;
A=1;
F0=1100;

%représentation temporelle 
t=0:Te:(N-1)*Te;
x1=A.*cos((2*pi*F0).*t); %la période retrouvée sur le graphique est bien f0
%le critère de Shanon est respecté

Fe2=1000;
Te2=1/Fe2;
t2=0:Te2:(N-1)*Te2;
x2=A.*cos((2*pi*F0).*t2); %la période retrouvée sur le graphique n'est pas f0
%le critère de Shanon n'est pas respecté
figure(1)
plot(t,x1,'r'); hold on,
plot(t2,x2,'b')
xlabel('temps')
ylabel('x(t)')
title('génération de deux signaux cosinus')
legend('x1','x2');%respect de l'ordre pour la légende
grid on;

%représentation fréquentielle : Transformée de Fourier Discret (TFD)
%calculée entre 0 et Fe pour éviter le recouvrement 
%[0,Fe/2] partie positive, [Fe/2,Fe] partie négative
TFD1=abs(fft(x1));
TFD2=abs(fft(x2));
figure(2)
semilogy(linspace(0,Fe,N),TFD1,'r'); hold on,
semilogy(linspace(0,Fe2,N),TFD2,'b'); %échelle logarithmique, N=length(x1)
xlabel('fréquences')
ylabel('amplitude')
title('transformée de fourier des signaux générés')
legend('fft1','fft2')

%autre représenatation
TFD12=fftshift(abs(x1));
TFD22=fftshift(abs(x2));
figure(3)
subplot(2,1,1)
semilogy(linspace(-Fe/2,Fe/2,N),TFD12,'r')
title('transformée de fourier TFD1 de x1')
xlabel('fréquences')
ylabel('amplitude')
grid on;
subplot(2,1,2)
semilogy(linspace(-Fe2/2,Fe2/2,N),TFD22,'b')
legend('fft1')
xlabel('fréquences')
ylabel('amplitude')
title('transformée de fourier TFD2 de x2')
grid on;
legend('fft2')

%question 3 partie 2, changement de N en N'
%on choisit N'>N en utilisant la technique de Zero Padding, N' doit être
%égale à une puissance de 2
N1=2048; 
N2=2^nextpow2(N);%trouve p tel que 2^p=N
TFD12b=fft(x1,N2);
TFD12c=fft(x1,N1);
figure(4)
subplot(2,1,1)
semilogy(linspace(0,Fe,N1),abs(TFD12c),'r')
title('transformée de fourier TFD1 de x1 avec N1>N')
xlabel('fréquences')
ylabel('amplitude')
legend('fft1')
grid on;
subplot(2,1,2)
semilogy(linspace(0,Fe2,N2),abs(TFD12b),'b')
xlabel('fréquences')
ylabel('amplitude')
title('transformée de fourier TFD2 de x1 avec N2>N')
grid on;
legend('fft2')

%question 4 partie 2,
%help pwelch 
DSP_x=pwch(x1,[],[],[],Fe,'twosided');
figure(5)
semilogy(linspace(-Fe/2,Fe/2,length(DSP_x)),fftshift(DSP_x,N));


