function [dv, tof, Vs_1] = hohmann_encounter(flybys, C3)
% assumptions:
% always starting from earth


    tof = 0;
    Vs_1 = 0;

    if flybys.name == "None"
        dv = 0;
        return
    end

    
    if sqrt(C3) < flybys.dV
        dv = flybys.dV - sqrt(C3); % [km/s] Equation for dV to reach planet
    else
        dv = -1;
        return;
    end
    
    tof = flybys.tof; % [day] Equation for Hohmann Transfer TOF to Planet
    
    atrans = 0.5*(149597898+flybys.a); % [km] SemiMajor Axis of Hohmann transfer orbit
    Vs_1 = sqrt(2*((132712440018/flybys.a)-(132712440018/(2*atrans)))); % [km/s] Heliocentric velocity for planet approach
end