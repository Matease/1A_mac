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





%% modulateur1 binaire
nb_bits=10000   ;
M1=2;
Ts=log2(M1)*Tb;
Rs=Rb./log2(M1);
Ns=Fe/Rs;%nombre de période echantillonage par période symbole
bits = randi([0 1],1,nb_bits);
symboles=2.*bits-1;%Mapping binaire à moyenne nulle
Dirac = kron(symboles, [1 zeros(1,Ns-1)]);%NS-1
h=ones(1,Ns);
x_filtre = filter(h,1,Dirac);




figure(1)
plot(x_filtre,'b')
axis([1,500,-2,2])
title('signal filtrée')
xlabel('x filtré')


%DSP=pwelch(x_filtre,[],[],[],Fe,'twosided');
DSP=pwelch(x_filtre,[],[],2^nextpow2(length(x_filtre)),1,'twosided');
f=linspace(-Fe/2,Fe/2,length(DSP));
figure(2)
semilogy(f,fftshift(DSP),'r');hold on;
semilogy(f,Ns*sinc(f*Ts).^2,'c')
legend('DSP experimentale de x','DSP théorique de x')

%% modulateur 2
M2=4;
Ts2=log2(M2)*Tb;
Rs2=Rb./log2(M2);
Ns2=Fe/Rs2;
r_bits=reshape(bits,nb_bits/log2(M2),log2(M2));
% Symboles2= symboles.*(1+randi([0 1],1,nb_bits).*2);
% Dirac2 = kron(Symboles2, [1 zeros(1,Ns2-1)]);
% x_filtre2= filter(h,1,Dirac2);
h2=ones(1,Ns2);
%Bits_s=bi2de(r_bits);
Nsimu=100;
DSP2=0;
for k=1:Nsimu
    Symboles2= randi([0,3],1,nb_bits/2)*2-3;
    Dirac2 = kron(Symboles2, [1 zeros(1,Ns2-1)]);
    x_filtre2= filter(h2,1,Dirac2);
    DSP2=DSP2+pwelch(x_filtre2,[],[],2^nextpow2(length(x_filtre2)),1,'twosided');
end
DSP2=DSP2/Nsimu;

figure(3)
plot(x_filtre2,'b')
axis([1,500,-2,2])
title('signal filtrée')
xlabel('x filtré 2')


figure(4)
%DSP2=pwelch(x_filtre2,[],[],[],Fe,'twosided');

semilogy(linspace(-Fe/2,Fe/2,length(DSP2)),fftshift(DSP2),'b');hold on;
semilogy(f,Ns2*5*sinc(f*Ts2).^2 ...
    +Ns2*5*sinc((f-Fe)*Ts2).^2 ...
    +Ns2*5*sinc((f+Fe)*Ts2).^2 ...
    +Ns2*5*sinc((f+2*Fe)*Ts2).^2 ...
    +Ns2*5*sinc((f-2*Fe)*Ts2).^2 ...
    ,'m');
legend('DSP expérimentale de x','DSP théorique de x')


%% modulateur 3
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
hr=fliplr(h1);%explication sur TP1BE
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
hb1=fir1(100,fc1);
hb2=fir1(100,fc2);

%réponse impulsionelle globale :
gb1 = conv(g1,hb1);
gb2 = conv(g1,hb2);
r1 = filter(hb1,1,x_filtre1);
r2 = filter(hb2,1,x_filtre1);

%signal en sortie de filtre
zb1 = filter(hr,1,r1);
zb2 = filter(hr,1,r2);

figure(7)
plot(gb1,'b');hold on;
plot(gb2,'r');

%diagrammes de l'oeil
figure(8)
plot(reshape(zb1,Ns1,length(zb1)/Ns1));
legend("diagramme de l'oeil  zb1")
figure(9)
plot(reshape(zb2,Ns1,length(zb2)/Ns1));
legend("diagramme de l'oeil zb2")

%réponse impulsionnelle en fréquence.
N=length(x_filtre1);
H=fft(h,N);
Hr=fft(hr,N);

Hc1=fft(hb1,N);
Hc2=fft(hb2,N);

figure(10)
subplot(2,1,1)
semilogy(linspace(-Fe/2,Fe/2,length(H)),fftshift(abs(H.*Hr)),'b');hold on;
semilogy(linspace(-Fe/2,Fe/2,length(Hc1)),fftshift(abs(Hc1)),'r')
legend("|H*Hr|","|Hc1|")

subplot(2,1,2)
semilogy(linspace(-Fe/2,Fe/2,length(H)),fftshift(abs(H.*Hr)),'b');hold on;
semilogy(linspace(-Fe/2,Fe/2,length(Hc2)),fftshift(abs(Hc2)),'r')
legend("|H*Hr|","|Hc2|")

%calcul des TEB

z_echb1=zb1(n0:Ns1:nb_bits/log2(M1)*Ns1);
TEBb1=sum((z_echb1>0)~=bits)/nb_bits;

z_echb2=zb2(n0:Ns1:nb_bits/log2(M1)*Ns1); 
TEBb2=sum((z_echb2>0)~=bits)/nb_bits;


%% 4 Étude de l impact du bruit et du filtrage adapté, notion d efficacité en puissance


%Chaine
%1----------------------------------------------------------------------
M1=2;
Ts=log2(M1)*Tb;
Rs=Rb./log2(M1);
Ns=Fe/Rs;
bits = randi([0 1],1,nb_bits);
symboles=2.*bits-1;
Dirac = kron(symboles, [1 zeros(1,Ns-1)]);
h1=ones(1,Ns);
x_filtre = filter(h1,1,Dirac);
hr1=fliplr(h1);

TEB_tab=zeros(1,8);
TEB_theo_tab=zeros(1,8);
EbN0dB=[0:8];
EbN0=10.^(EbN0dB./10); 

for k=1:length(EbN0dB)

    Px= mean(abs(x_filtre).^2);
        %Px est la puisssance de x(t) x(t)= Somme des ak*h(t-kTs)
        %sigmam^2=No/2 & Es=log2(M)*Eb avec Es=PxTS
    %Px=integrale(DSPx(f)df
    sigma=sqrt((Px*Ns)/(2*log2(M1)*EbN0(k)));
    bruit = sigma*randn(1,length(x_filtre)) ;

    %canal de propagation
    r1= x_filtre + bruit;

    %echantillonage TEB
    z1=filter(hr1,1,r1);
    
    z_echant=z1(n0:Ns1:nb_bits/log2(M1)*Ns1);
    TEB_tab(k)=sum((z_echant>0)~=bits)/nb_bits;
    
end

TEB_theo_tab=qfunc(sqrt(2*EbN0));
%TEB=sum((z_echant>0)~=bits)/nb_bits;

%TEB_theo=qfunc(2*EbN0);
figure(12)
plot(reshape(z_echant,Ns,length(z_echant)/Ns));
title("Diagramme de l'oeil de la chaîne 1")
xlabel('t (en seconde)')

figure(14)
semilogy(TEB_tab,'b-o');hold on;
semilogy(TEB_theo_tab,'r-o');
legend('TEB expérimental','TEB théorique');
title("Taux d'erreur binaire chaîne 1")
xlabel("Eb/N0 (en dB)")
grid on

%chaine
%2-------------------------------------------------------------------
M2=2;
Ts2=log2(M2)*Tb;
Rs2=Rb./log2(M2);
Ns2=Fe/Rs2;
bits = randi([0 1],1,nb_bits);
symboles2=2.*bits-1;
Dirac2 = kron(symboles2, [1 zeros(1,Ns2-1)]);
h2=ones(1,Ns2);
x2 = filter(h2,1,Dirac2);
hr2 = [ones(1,Ns2/2) zeros(1,Ns2/2)];
n0=Ns2;
%détermination du bruit 
EbN0dB2=[0:8];
EbN02=10.^(EbN0dB2./10);

TEB_tab2=0;
for k=1:length(EbN0dB2)
    Px2= mean(abs(x2).^2);
    sigma2=sqrt((Px2*Ns2)/(2*log2(M2)*EbN02(k)));
    bruit2 = sigma2*randn(1,length(x2)) ;

    %canal de propagation
    r2 = x2 + bruit2; 
    %echantillonage et TEB
    z2=filter(hr2,1,r2);
    z_echant2=z2(n0:Ns2:nb_bits/log2(M2)*Ns2);
    TEB_tab2(k)=sum((z_echant2>0)~=bits)/nb_bits;
    
end
TEB_theo_tab2=qfunc(sqrt(EbN02));

figure(13)
plot(reshape(z_echant2,Ns2,length(z_echant2)/Ns2));
title("Diagramme de l'oeil de la chaîne 2")
xlabel('t (en seconde)')


figure(16)
semilogy(TEB_tab2,'b-o');hold on;
semilogy(TEB_theo_tab2,'r-o')
xlabel("Eb/N0 (en dB)")
legend('TEB expérimental','TEB théorique');
title("Taux d'erreur binaire chaîne 2")
grid on



%chaine 3------------------------------------------------------------------
M3=4;
Ts3=log2(M3)*Tb;
Rs3=Rb./log2(M3);
Ns3=Fe/Rs3;
r_bits=reshape(bits,nb_bits/log2(M3),log2(M3));

Nsimu=100;
h3 = ones(1,Ns3);
for k=1:Nsimu
    Symboles3= randi([0,3],1,nb_bits/2)*2-3;
    Dirac3 = kron(Symboles3, [1 zeros(1,Ns3-1)]);
    x3= filter(h3,1,Dirac3);
    
end

%détermination du bruit
TEB_tab3=zeros(1,8);
TEB_theo_tab3=zeros(1,8);
for i=1:7
    Px3= mean(abs(x3).^2);
    EbN0dB3=i;
    EbN03=10.^(EbN0dB3./10);
    sigma3=sqrt((Px3*Ns)/(2*log2(M3)*EbN03));
    bruit3 = sigma3*randn(1,length(x3)) ;

%filtre de réception
    hr3=fliplr(h3);

%canal de propagation
    r3=x3+bruit3;

%échantillonage et TEB
    z3 = filter(hr3,1,r3);
    n03=Ns3;
    %z_echant3=z3(n03:Ns3:nb_bits/log2(M3)*Ns3);
    %TEB_tab3(i)=sum((z_echant3>0)~=bits)/nb_bits;
    %TEB_theo_tab3(i)=3/(2*log2(M3))*qfunc(sqrt(6*log2(M3)/15*EbN03));
end


figure(15)

semilogy(TEB_tab,'b-o');hold on;
semilogy(TEB_tab2,'r-o');
legend('TEB1','TEB2');
grid on;
title('TEBs obtenu par simulation pour les chaines de transmission 1 et 2')
xlabel('Eb/N0 (en dB)')

