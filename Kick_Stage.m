%% Kick Stage
function [dV,Cost,C3_old,C3_lv,C3_new] = Kick_Stage (mass,launch_vehicle,type)

g0 = 9.81;
sc_mass = mass.total;
% sc_mass = 160; % kg

if type == "none"
    mass_i = 0; % kg
    dV = 0; % km/s
    Cost = 0; % $
elseif type == "Star 27H"
    Isp = 291.4; % s
    mass_i = 367.8; % kg
    mass_f = mass_i - 338.8; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 1; % $
elseif type == "Star 30E"
    Isp = 290.4; % s
    mass_i = 673.9; % kg
    mass_f = mass_i - 631.4; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 1.5; % $
elseif type == "Star 37XFP"
    Isp = 290.0; % s
    mass_i = 955.3; % kg
    mass_f = mass_i - 883.6; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 1.75; % $
elseif type == "Star 48BV"
    Isp = 292.1; % s
    mass_i = 2164.5; % kg
    mass_f = mass_i - 2010; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 2; % $
elseif type == "Castor-30B"
    Isp = 300.6; % s
    mass_i = 13971; % kg
    mass_f = mass_i - 12885; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 2.5; % $
elseif type == "Castor-30XL"
    Isp = 294.4; % s
    mass_i = 26407; % kg
    mass_f = mass_i - 24925; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 3; % $
end

%% Check LV C3
% Before kick stage
C3_old = interp1(launch_vehicle.mass,launch_vehicle.C3,sc_mass,'linear','extrap'); % [km^2/s^2]

% After kick stage
mass_new = sc_mass + mass_i; % kg
C3_lv = interp1(launch_vehicle.mass,launch_vehicle.C3,mass_new,'linear','extrap'); % [km^2/s^2]
if C3_lv <= 0
    error("Launch vehicle C3 is less than 0.")
else
    dV_lv = sqrt(C3_lv); % km/s
    dV_new = dV_lv + dV; % km/s
    C3_new = dV_new^2; % km^2/s^2
end

end