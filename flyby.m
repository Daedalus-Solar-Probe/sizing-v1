function [perihelion, aphelion] = flyby(Vs_1, flybys)
% assumptions:
%    
    
    Vplanet = sqrt((132712440018+flybys.mu)/(flybys.a));
    Vinf = abs(Vs_1 - Vplanet); % V infinity for flyby encounter for flyby encounter in degrees
    delta = 2*asin(1 / ((flybys.radius/(flybys.mu/(Vinf^2)) +1 )) ); % delta angle in radians
    Vplus = sqrt(Vplanet^2 + Vinf^2 - 2*Vinf*Vplanet*sin(delta)); %Velocity post flyby
    fpaplus = -1* asin(sin(delta)*Vinf/Vplus); %flight path angle post fly by    
    afinal = (-132712440018/2)/(((Vplus^2)/2)-(132712440018/flybys.a)); % semimajor axis post fly by
    hfinal = abs(flybys.a*(cos(fpaplus)*Vplus)); % angular momentum post fly by
    pfinal = hfinal^2 / 132712440018; %Semilatus rectum post flyby
    efinal = sqrt(1- (pfinal/afinal)); %eccentricity post flyby
    
    perihelion = afinal*(1-efinal); % [km] 
    aphelion = afinal*(1+efinal); % [km]

end