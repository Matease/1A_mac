clc;
clear all;
close all;
%% Implantation sous Matlab

Fe = 24000;
Te = 1/Fe;
Rb = 6000;
Tb = 1/Rb;
Ts = Tb;
M = 2;
Rs = Rb / log2(M);

%Durée symbole en nombre d1échantillons (Ts1=Ns1*Te)
Ns1 = Fe/Rs;
Ts1 = Te * Ns1;
%Nombre de bits générés
nb_bits=10000;
%Génération de l’information binaire
bits=randi([0,1],1,nb_bits);
%Mapping binaire à moyenne nulle : 0->-1, 1->1
Symboles=-1+2*bits;
%Génération de la suite de Diracs pondérés par les symboles (suréchantillonnage)
Suite_diracs=kron(Symboles, [1 zeros(1,Ns1-1)]);
%Génération de la réponse impulsionnelle du filtre de mise en forme
h=ones(1,Ns1);

n0=length(h);
%Filtrage de mise en forme
x=filter(h,1,Suite_diracs);
%Génération de la réponse impulsionnelle du filtre de réception
hr=fliplr(h);
%Filtrage de réception
z=filter(hr,1,x);
%échantillonage

zechant = z(n0:Ns1:length((z)));
%décisions

TEB1 = sum(zechant > 0 ~= bits)/nb_bits;

scatterplot(zechant);
title("Constallation en sortie d'échantilloneur");

%2) Chaine de transmission avec erreur de phase
%adaptation à l'ajout de la phase
deg = [40 100 180 ]; %À modifier
phi = deg*pi/180;
Tab_TEB = zeros(1,3); 
for i = 1:3
    xp = x*exp(1i*phi(i));
    zp = filter(hr,1,xp);
    zechantp = zp(n0:Ns1:end);
    zechantpr = real(zechantp);
    %scatterplot(zechantpr);
    %décisions
    dp = zechantpr > 0;
    Tab_TEB(i) = sum(dp ~= bits)/nb_bits;
end

%figure(1)
%plot(deg,Tab_TEB);


scatterplot(zechantpr)
title("Constallation en sortie d'échantilloneur avec erreur de phase");


%Chaine avec erreur de phase et bruit

EbN0dB=[0:6];
EbN0=10.^(EbN0dB./10);
xp240=x*exp(1i*phi(1));
xp2100=x*exp(1i*phi(2));

TEB_tab240 = zeros(1,6); 
TEB_tabsp= zeros(1,6);
TEB_tab2100 = zeros(1,6); 
for k = 1:6
    Px=mean(abs(xp240).^2);
    sigma=sqrt((Px*Ns1)/(2*log2(M)*EbN0(k)));
    bruitreal40 = sigma*randn(1,length(real(xp240))) ;
    bruitimag40= sigma*randn(1,length(imag(xp240)));
    bruit40 = bruitreal40 +1i*bruitimag40;

    Px=mean(abs(x).^2);
    sigma=sqrt((Px*Ns1)/(2*log2(M)*EbN0(k)));
    bruitrealx = sigma*randn(1,length(real(x))) ;
    bruitimagx= sigma*randn(1,length(imag(x)));
    bruitx = bruitrealx +1i*bruitimagx;
    
    Px=mean(abs(xp2100).^2);
    sigma=sqrt((Px*Ns1)/(2*log2(M)*EbN0(k)));
    bruitreal100 = sigma*randn(1,length(real(xp2100))) ;
    bruitimag100= sigma*randn(1,length(imag(xp2100)));
    bruit100 = bruitreal100 +1i*bruitimag100;

    %canal
    r40 = xp240+bruit40;
    rx= x+bruitx;
    r100 = xp2100+bruit100;

    %reception 
    zp240 = filter(hr,1,r40);
    zx= filter(hr,1,rx);
    z100=filter(hr,1,r100);

    zechantp240=zp240(n0:Ns1:length(zp240));
    zechantp240r=real(zechantp240);
    zechantpx=zx(n0:Ns1:length(zx));
    zechantpxr=real(zechantpx);
    zechantp100=z100(n0:Ns1:length(z100));
    zechantp100r=real(zechantp100);

    bits_estimes240 = zeros(1, nb_bits);
    bits_estimesx = zeros(1, nb_bits);
    bits_estimes100 = zeros(1, nb_bits);
    for i = 1:length(bits_estimes240)
        if zechantp240r(i) > 0
            bits_estimes240(i) = 1;
        end
    end
    for i = 1:length(bits_estimesx)
        if zechantpxr(i) > 0
            bits_estimesx(i) = 1;
        end
    end
    for i = 1:length(bits_estimes100)
        if zechantp100r(i) > 0
            bits_estimes100(i) = 1;
        end
    end
     
    TEB_tab240(k)=sum(bits_estimes240~=bits)/(length(bits));
    TEB_tabsp(k)= sum(bits_estimesx~=bits)/(length(bits));
    TEB_tab2100(k)=sum(bits_estimes100~=bits)/(length(bits));
end
TEB_theo_tab=qfunc(cos(0)*sqrt(2*EbN0)); %L'angle du cos est à modifier selon le besoin
% figure(2)
% semilogy(TEB_tab240,"dr");hold on;
% semilogy(TEB_tab2100,"db"); hold on
% semilogy(TEB_theo_tab)
% legend('TEB pour phi = 40°','TEB pour phi = 100°','TEB théorique')
% title('TEBs théorique et simulé de la chaine de transmision avec erreur de phase')
% xlabel('Eb/N0')
% ylabel('TEB')


%% 3 Estimation et correction de l'érreur de phase porteuse
xp40=x*exp(1i*phi(1));
xp100=x*exp(1i*phi(2));





TEB_tab400 = zeros(1,6);
TEB_tab1000= zeros(1,6);
for k = 1:6
    Px=mean(abs(xp40).^2);
    sigma=sqrt((Px*Ns1)/(2*log2(M)*EbN0(k)));
    bruitreal40 = sigma*randn(1,length(real(xp40))) ;
    bruitimag40= sigma*randn(1,length(imag(xp40)));
    bruit40 = bruitreal40 +1i*bruitimag40;
    
    Px=mean(abs(xp100).^2);
    sigma=sqrt((Px*Ns1)/(2*log2(M)*EbN0(k)));
    bruitreal100 = sigma*randn(1,length(real(xp100))) ;
    bruitimag100= sigma*randn(1,length(imag(xp100)));
    bruit100 = bruitreal100 +1i*bruitimag100;
    %canal
    r40 = xp40+bruit40;
    r100 = xp100+bruit100;

    %reception 
    zp40 = filter(hr,1,r40);
    zp100 = filter(hr,1,r100);

    zechantp40=zp40(n0:Ns1:length(zp40));
    zechantp100=zp100(n0:Ns1:length(zp100));
    
    
    phi_estime40=1/2*angle(sum(zechantp40.^2));
    phi_estime100=1/2*angle(sum(zechantp100.^2));
    
   
   
    
    
    zc40=zechantp40*exp(-1i*phi_estime40);
    
    zc100=zechantp100*exp(-1i*phi_estime100);
    zechantp40r=real(zc40);
    zechantp100r=real(zc100);

    bits_estimes40 = zeros(1, nb_bits);
    bits_estimes100 = zeros(1, nb_bits);
    for i = 1:length(bits_estimes40)
        if zechantp40r(i) > 0
            bits_estimes40(i) = 1;
        end
    end
    for i = 1:length(bits_estimes100)
        if zechantp100r(i) > 0
            bits_estimes100(i) = 1;
        end    
    end
    TEB_tab400(k)=sum(bits_estimes40~=bits)/(length(bits));
    TEB_tab1000(k)=sum(bits_estimes100~=bits)/(length(bits));
end
figure(3)
semilogy(TEB_tab1000);hold on;
semilogy(TEB_tab400);
semilogy(TEB_theo_tab);
legend('TEB 100°','TEB 40°','TEB theorique')
xlabel('Eb/N0')
ylabel('TEB')

figure(4)
title("comparaison TEB avec correction, sans correction et sans déphasage de 40°")
semilogy(TEB_tab400,'dr');hold on;
semilogy(TEB_tab240,'+');
semilogy(TEB_tabsp);
legend("TEB corrigé 40°","TEB sans correction 40°", "TEB sans déphasage");
xlabel('Eb/N0')
ylabel('TEB')

figure(5)
title("comparaison TEB avec correction, sans correction et sans déphasage de 100°")
semilogy(TEB_tab1000,'dr');hold on;
semilogy(TEB_tab2100,'+');
semilogy(TEB_tabsp);
legend("TEB corrigé 100°","TEB sans correction 100°", "TEB sans déphasage");
xlabel('Eb/N0')
ylabel('TEB')






%% 4


c=zeros(1,length(Symboles));
c(1)=Symboles(1);
for i = 2:length(c)
    c(i)=Symboles(i)*c(i-1);
end
    

diracs=kron(c, [1 zeros(1,Ns1-1)]);
xc=filter(h,1,diracs);
xc40=xc*exp(1i*phi(1));
xc100=xc*exp(1i*phi(2));

TEB_tab40 = zeros(1,6);
TEB_tab100= zeros(1,6);
TEB_tab40c = zeros(1,6);
TEB_tab100c= zeros(1,6);
for k=1:6
    
    %Bruit
    Px=mean(abs(xc40).^2);
    sigma=sqrt((Px*Ns1)/(2*log2(M)*EbN0(k)));
    bruitrealxc40 = sigma*randn(1,length(real(xc40))) ;
    bruitimagxc40= sigma*randn(1,length(imag(xc40)));
    bruitxc40 = bruitrealxc40 +1i*bruitimagxc40;
    
    Px=mean(abs(xc100).^2);
    sigma=sqrt((Px*Ns1)/(2*log2(M)*EbN0(k)));
    bruitrealxc100 = sigma*randn(1,length(real(xc100))) ;
    bruitimagxc100= sigma*randn(1,length(imag(xc100)));
    bruitxc100 = bruitrealxc100 +1i*bruitimagxc100;



   %Canal
   rc40= xc40 +bruitxc40;
   rc100= xc100 +bruitxc100;

   %reception

   zc40=filter(hr,1,rc40);
   zc100=filter(hr,1,rc100);

   zechant40=zc40(n0:Ns1:length(zc40));
   zechant100=zc100(n0:Ns1:length(zc100));

   phi_estimec40=1/2*angle(sum(zechant40.^2));
   phi_estimec100=1/2*angle(sum(zechant100.^2));
    
   zcc40=zechant40*exp(-1i*phi_estimec40);
   zcc100=zechant100*exp(-1i*phi_estimec100);

    zechantp40c=real(zcc40);
    zechantp100c=real(zcc100);
    zechantpr40=real(zechant40);
    zechantpr100=real(zechant100);

    bits_estimes40 = zeros(1, nb_bits);
    bits_estimesc40 = zeros(1, nb_bits);
    bits_estimes100 = zeros(1, nb_bits);
    bits_estimesc100 = zeros(1, nb_bits);
    %decision
    Decision40 = zeros(1,length(zechantp40c));
    Decision100 = zeros(1,length(zechantp100c));
    Decision40c = zeros(1,length(zechantp40c));
    Decision100c = zeros(1,length(zechantp100c));
    for i=1:length(zechantp40c)
        if zechantp40c > 0
            Decision40c(i)= -sign(zechantp40c(1));
        else
            Decision40c(i)= sign(zechantp40c(1));
        end
    end

    for i=1:length(zechantp100c)
        if zechantp100c > 0
            Decision100c(i)= -sign(zechantp100c(1));
        else
            Decision100c(i)= sign(zechantp100c(1));
        end
    end

    for i=1:length(zechantpr40)
        if zechantpr40 > 0
            Decision40(i)= -sign(zechantpr40(1));
        else
            Decision40(i)= sign(zechantpr40(1));
        end
    end

    for i=1:length(zechantpr100)
        if zechantpr100 > 0
            Decision100(i)= -sign(zechantpr100(1));
        else
            Decision100(i)= sign(zechantpr100(1));
        end
    end



    ak40=zeros(1,length(Decision40));
    ak100=zeros(1,length(Decision100));
    ak40(1)=Decision40(1);
    ak100(1)=Decision100(1);

    ak40c=zeros(1,length(Decision40c));
    ak100c=zeros(1,length(Decision100c));
    ak40c(1)=Decision40c(1);
    ak100c(1)=Decision100c(1);


    for i=2:length(ak100)
        ak40(i)=Decision40(i)*Decision40(i-1);
        ak100(i)=Decision100(i)*Decision100(i-1);
        ak40c(i)=Decision40c(i)*Decision40c(i-1);
        ak100c(i)=Decision100c(i)*Decision100c(i-1);
    end


    for i = 1:length(bits_estimes40)
        if ak40(i) > 0
            bits_estimes40(i) = 1;
        end
    end
    for i = 1:length(bits_estimesc40)
        if ak40c(i) > 0
            bits_estimesc40(i) = 1;
        end
    end
    for i = 1:length(bits_estimes100)
        if ak100(i) > 0
            bits_estimes100(i) = 1;
        end
    end
    for i = 1:length(bits_estimesc100)
        if ak100c(i) > 0
            bits_estimesc100(i) = 1;
        end
    end
    TEB_tab40(k)=sum(bits_estimes40~=bits)/(length(bits));
    TEB_tab100(k)=sum(bits_estimes100~=bits)/(length(bits));
    TEB_tab40c(k)=sum(bits_estimesc40~=bits)/(length(bits));
    TEB_tab100c(k)=sum(bits_estimesc100~=bits)/(length(bits));
end
figure(6)
title("comparaison correction de phase et sans, pour un codage de transition avec un angle de 40° ")
semilogy(TEB_tab40);hold on;
semilogy(TEB_tab40c,'dr');
legend('TEB sans correction de phase 40°','TEB avec correction de phase 40°')
    

figure(7)
title("comparaison correction de phase et sans, pour un codage de transition avec un angle de 100° ")
semilogy(TEB_tab100);hold on;
semilogy(TEB_tab100c,'dr');
legend('TEB sans correction de phase 100°','TEB avec correction de phase 100°')
    
figure(8)
title("comparaison codage de transition avec et sans, pour un angle de 40° ")
semilogy(TEB_tab40);hold on;
semilogy(TEB_tab400,'dr');
legend('TEB avec codage de transition 40°','TEB sans codage de transition 40°')

figure(9)
title("comparaison codage de transition avec et sans, pour un angle de 100° ")
semilogy(TEB_tab100);hold on;
semilogy(TEB_tab1000,'dr');
legend('TEB avec codage de transition 100°','TEB sans codage de transition 100°')














