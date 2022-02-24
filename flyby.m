function [perihelion, aphelion] = flyby(Vs_1, flybys, fpa)
% assumptions:
%
    Vplanet = sqrt((132712440018+flybys.mu)/flybys.a); % Velocity of planet on circular coplanar orbit
    Vinf = sqrt(Vplanet^2+Vs_1^2-2*Vplanet*Vs_1*cos(fpa)); % V infinity for flyby encounter for flyby encounter in degrees
    
    index = 1;
    for rp = (flybys.radius):5:(flybys.radius+1000) % Varying the flyby pass distance
        afly = flybys.mu/(Vinf^2);
        e = (rp/afly) + 1;
        delta = 2*asin(1/e);
        
        etaposs = [asin((Vs_1*sin(fpa))/Vinf), pi - asin((Vs_1*sin(fpa))/Vinf)]; % Two possible eta angle values
        pposs = [asin((Vplanet*sin(fpa))/Vinf), pi - asin((Vplanet*sin(fpa))/Vinf)]; % Two possible rho angle values
        
        %Need to check which combination of angles satisfies the velocity triangle
        if ((etaposs(1)+ pposs(1)) >= (pi-fpa)-0.04) && ((etaposs(1)+ pposs(1)) <= (pi-fpa)+0.04) 
            eta = etaposs(1);
        elseif ((etaposs(1)+ pposs(2)) >= (pi-fpa)-0.04) && ((etaposs(1)+ pposs(2)) <= (pi-fpa)+0.04)
            eta = etaposs(1);
        elseif ((etaposs(2)+ pposs(1)) >= (pi-fpa)-0.04) && ((etaposs(2)+ pposs(1)) <= (pi-fpa)+0.04) 
            eta = etaposs(2);
        else
            eta = etaposs(2);
        end
 
        Vplus = sqrt(Vplanet^2+Vinf^2-2*Vplanet*Vinf*cos(eta+delta)); % Velocity of s/c post flyby (km/s)
        fpaplus = asin((Vinf*sin(eta+delta))/Vplus); %flight path angle post flyby (radians)
        afinal = (-132712440018/2)/(((Vplus^2)/2)-(132712440018/flybys.a)); % semimajor axis post fly by (km)
        hfinal = abs(flybys.a*(cos(fpaplus)*Vplus)); % angular momentum post fly by
        pfinal = hfinal^2 / 132712440018; %Semilatus rectum post flyby (km)
        efinal = sqrt(1- (pfinal/afinal)); %eccentricity post flyby
    
        perh(index) = afinal*(1-efinal); % kilometers
        aph(index) = afinal*(1+efinal); % kilometers
        index = index + 1;
    end
    
    perihelion = min(perh);
    aphelion = aph(perh==(min(perh)));
end