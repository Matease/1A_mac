clc;
clear all;
close all;
%Frequence d'échantillonage
Fe=24000;
%Période d'échantillonage
Te=1/Fe;
%Debit binaire
Rb=3000;
%taux binaire
Tb=1/Rb;
%frequence porteuse
fp=2000;
%% Chaine 1
N=100;
nb_bits=15000;
M=4;
Ts=log2(M)*Tb;
Rs=Rb./log2(M);
Ns=Fe/Rs;%nombre de période echantillonage par période symbole
bits = randi([0 1],1,nb_bits);
alpha=0.35;
L=4;
h= rcosdesign(alpha,L,Ns,'sqrt');
n0=length(h);
%-----------
%pskmod
symbolesI=1-2.*bits(1:2:nb_bits);%Mapping binaire à moyenne nulle
DiracI = kron(symbolesI, [1 zeros(1,Ns-1)]);
I = filter(h,1,[DiracI zeros(1,n0)]);

%----
symbolesQ=1-2.*bits(2:2:nb_bits);%Mapping binaire à moyenne nulle
DiracQ = kron(symbolesQ, [1 zeros(1,Ns-1)]);
Q = filter(h,1,[DiracQ zeros(1,n0)]);



xe=I+1i*Q;
t=(1:length(xe))*Te;
x=real(xe.*exp(1i*2*pi*fp*t));

Ie=I.*cos(2*pi*fp*t);
DSPI=pwelch(Ie,[],[],2^nextpow2(length(Ie)),1,'twosided');

Qe=Q.*sin(2*pi*fp*t);
DSPQ=pwelch(Qe,[],[],2^nextpow2(length(Qe)),1,'twosided');
figure(1)
%subplot(2,1,1)
plot(t,Ie,'b');hold on; 
%subplot(2,1,2)
plot(t,Qe,'r');
legend('Q(t)','I(t)');
title('Transmission du signal total')
xlabel('Temps en seconde')

figure(2)
semilogy(linspace(-Fe/2,Fe/2,length(DSPI)),fftshift(abs(DSPI)),'b'); hold on;
semilogy(linspace(-Fe/2,Fe/2,length(DSPQ)),fftshift(abs(DSPQ)),'r');
legend('DSP I','DSP Q');
title('DSP des signaux en phase et en quadrature');
xlabel('f en Hz')
ylabel('Sxp')

figure(3)
plot(x);
title('Signal transmis avec fréquence porteuse')
xlabel('Temps en seconde')
DSP=pwelch(x,[],[],2^nextpow2(length(x)),1,'twosided');
figure(4)
semilogy(linspace(-Fe/2,Fe/2,length(DSP)),fftshift(abs(DSP)));
title('DSP du signal transmis avec une fréquence porteuse');
xlabel('f en Hz')
ylabel('Sxp')




TEB_tab=zeros(1,6);


EbN0dB=[0:6];
EbN0=10.^(EbN0dB./10); 

for k=1:length(EbN0dB)

    Px=mean(abs(x).^2);
    sigma=sqrt((Px*Ns)/(2*log2(M)*EbN0(k)));
    bruit = sigma*randn(1,length(x)) ;

    %canal de propagation
    r= x + bruit;

    %echantillonage TEB
    rcos=r.*cos(2*pi*fp*t);
    rsin=-r.*sin(2*pi*fp*t);
    z=filter(h,1,rcos+1i*rsin);


    z_echant=z(n0+1:Ns:length(z));
%     z_eimag=imag(z_echant);
%     z_ereal=real(z_echant);


    %Seuil
    bits_estimes(1:2:nb_bits)=(real(z_echant)<0);
    bits_estimes(2:2:nb_bits)=(imag(z_echant)<0); 
    
    
    TEB_tab(k)=sum(bits_estimes~=bits)/(length(bits));
    

    
end
TEB_theo_tab=qfunc(sqrt(2*EbN0));
figure (5)
semilogy(EbN0dB,TEB_theo_tab); hold on
semilogy(EbN0dB,TEB_tab,'dr')
legend('TEB théorique','TEB simulé')
title('TEBS théorique et simulé de la chaine de transmission avec fréquence porteuse')



%% CHAINE PASSE BAS

Fc=8000/(Fe/2);
%hpb = fir1(100,Fc);
%hpb=ones(1,3);
%n02 = length(hpb);
hr=fliplr(h);
%-----------

%DiracI = kron(symbolesI, [1 zeros(1,Ns-1)]);
%I2 = filter(hpb,1,DiracI);

%----

%DiracQ = kron(symbolesQ, [1 zeros(1,Ns-1)]);
%Q2 = filter(hpb,1,DiracQ);



% %xe2=I2+1i*Q2;
% t2=(1:length(xe2))*Te;
 x2=xe;
% 
% Ie2=I2.*cos(2*pi*fp*t2);
% DSPI2=pwelch(Ie2,[],[],2^nextpow2(length(Ie2)),1,'twosided');
% 
% Qe2=Q2.*sin(2*pi*fp*t2);
% DSPQ2=pwelch(Qe2,[],[],2^nextpow2(length(Qe2)),1,'twosided');

% figure(6)
% %subplot(2,1,1)
% plot(t2,Ie2,'b');hold on; 
% legend('I');
% %subplot(2,1,2)
% plot(t2,Qe2,'r');
% legend('Q');
% 
% figure(7)
% semilogy(linspace(-Fe/2,Fe/2,length(DSPI2)),fftshift(abs(DSPI2)),'b'); hold on;
% semilogy(linspace(-Fe/2,Fe/2,length(DSPQ2)),fftshift(abs(DSPQ2)),'r');
% legend('DSP I','DSP Q');
% 
% 
figure(8)
plot(x2);
DSP2=pwelch(x2,[],[],2^nextpow2(length(x2)),1,'twosided');
title("DSP du signal transmis en phase avec une fréquence porteuse")
xlabel('f en Hz')
%N_sup = 2^nextpow2(length(xe));
%DSP2 = 1/length(xe) * abs(fft(xe,N_sup)).^2;
% 
% %DSP2=periodogram(x2);
figure(9)
semilogy(linspace(-Fe/2,Fe/2,length(DSP2)),fftshift(abs(DSP2)));
title('DSP du signal transmis en phase avec une fréquence porteuse')
% %plot(DSP2);
% semilogy(linspace(-1/Ns,1/Ns,N_sup),fftshift(DSP2));


TEB_tab2=zeros(1,6);




for k=1:length(EbN0dB)

    Px=mean(abs(x2).^2);
    sigma=sqrt((Px*Ns)/(2*log2(M)*EbN0(k)));
    bruitreal = sigma*randn(1,length(real(x2))) ;
    bruitimag= sigma*randn(1,length(imag(x2)));
    bruit2 = bruitreal +1i*bruitimag;
    %canal de propagation
    r2= x2 + bruit2;

    %echantillonage TEB
    rcos2=r2.*cos(2*pi*fp*t);
    rsin2=-r2.*sin(2*pi*fp*t);
    
    
    z2=filter(hr,1,r2);
    %z2=filter(hr,1,[r2 zeros(1,(L*Ns)/2 )]);
    %z2=z2((L*Ns)/2 +1 :end);
    %z_echant2=z2(1:Ns:end);
    
    
   
    
   z_echant2=z2(n0+1:Ns:length(z2));
%     z_eimag=imag(z_echant);
%     z_ereal=real(z_echant);

    bits_estimes2(1:2:nb_bits)=(real(z_echant2)<0);
    bits_estimes2(2:2:nb_bits)=(imag(z_echant2)<0); 
    %symboles_ai_r = (sign(real(z_echant2))+1)/2;
    %symboles_bi_r = (sign(imag(z_echant2))+1)/2; 
    %bits_recu(1:2:nb_bits) = symboles_ai_r;
    %bits_recu(2:2:nb_bits) = symboles_bi_r;
    
    TEB_tab2(k)=sum(bits_estimes2~=bits)/(length(bits));
    %TEB_tab2(k)=sum(bits_recu~=bits)/(length(bits));
    
    

    
end
TEB_theo_tab2=qfunc(sqrt(2*EbN0));
figure (10)
semilogy(EbN0dB,TEB_theo_tab2)
hold on
semilogy(EbN0dB,TEB_tab2,'dr')
legend('TEB théorique','TEB simulé')
title('TEBS théorique et simulé de la chaine de transmission avec une fréquence porteuse')
xlabel('Eb/N0')
ylabel('')
scatterplot(z_echant2)
title("Constellation en sortie de l'échantillonneur")

%% Comparaison chaine
Fepsk=6000;
Mpsk=8;
Rspsk=Rb./log2(Mpsk);
Nspsk=Fepsk/Rspsk;

% 8-PSK
alphapsk=0.20;
hpsk=rcosdesign(alphapsk,L,Nspsk,'sqrt');
hrpsk=fliplr(hpsk);
%n0psk=Nspsk;
n0psk=length(hrpsk);

bitspsk = reshape(bits ,length(bits)/3,3);
decipsk = bi2de(bitspsk);
decipsk= decipsk.';
mapping=pskmod(decipsk,8,pi/8,'gray');
scatterplot(mapping);
title("constellation en sortie du mapping ")
diracpsk=kron(mapping, [1 zeros(1,Nspsk-1)]);
xpsk=filter(hpsk,1,[diracpsk zeros(1,n0psk)]);

figure(11)

DSPpsk = 1/length(xpsk)*abs(fft(xpsk,2^nextpow2(length(xpsk)))).^2;
semilogy(linspace(-1/Nspsk,1/Nspsk,2^nextpow2(length(xpsk))),fftshift(DSPpsk));
title('DSP du signal 8-PSK')
xlabel("f en Hz")
%DSPpsk=pwelch(xpsk,[],[],2^nextpow2(length(xpsk)),1,'twosided');
%semilogy(linspace(-Fepsk/2,Fepsk/2,length(xpsk)),fftshift(abs(DSPpsk)));
TEB_tabpsk=zeros(1,6);
for k=1:length(EbN0dB)

    Px=mean(abs(xpsk).^2);
    sigma=sqrt((Px*Nspsk)/(2*log2(Mpsk)*EbN0(k)));
    bruitrealpsk = sigma*randn(1,length(real(xpsk))) ;
    bruitimagpsk= sigma*randn(1,length(imag(xpsk)));
    bruitpsk = bruitrealpsk +1i*bruitimagpsk;
    %canal de propagation
    rpsk= xpsk + bruitpsk;

    %echantillonage TEB
      
    
    zpsk=filter(hrpsk,1,rpsk);


    %zpsk=filter(hr,1,[rpsk zeros(1,L*Ns/2)]);
    %zpsk=zpsk( L*Ns/2+1 :end);
    %z_echantpsk=zpsk(1:Ns:end);
    
    
   
    
   z_echantpsk=zpsk(n0psk+1:Nspsk:length(zpsk));

   demapping=pskdemod(z_echantpsk,8,pi/8,'gray');
   bits_estimespsk=de2bi(demapping);
   bits_estimespsk=bits_estimespsk(:)';

   TEB_tabpsk(k)=sum(bits_estimespsk~=bits)/(length(bits));
end    
scatterplot(z_echantpsk)
title("Constellation en sortie de l'échantilloneur")
TEB_theo_tabpsk=2/log2(Mpsk)*qfunc(2*sqrt(EbN0)*sin(pi/Mpsk));
figure (12)
semilogy(EbN0dB,TEB_theo_tabpsk)
hold on
semilogy(EbN0dB,TEB_tabpsk,'dr')
legend('TEB théorique','TEB simulé')
title("TEBs théorique et simulé des deux modulateurs")
xlabel("Eb/N0")
ylabel('TEB')



