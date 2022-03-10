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
    Cost = 2.49e+6; % $
elseif type == "Star 30E"
    Isp = 290.4; % s
    mass_i = 673.9; % kg
    mass_f = mass_i - 631.4; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 3.56e+6; % $
elseif type == "Star 37XFP"
    Isp = 290.0; % s
    mass_i = 955.3; % kg
    mass_f = mass_i - 883.6; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 4.81e+6; % $
elseif type == "Star 48BV"
    Isp = 292.1; % s
    mass_i = 2164.5; % kg
    mass_f = mass_i - 2010; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 8.17e+6; % $
elseif type == "Star 63F"
    Isp = 297.1; % s
    mass_i = 4591.7; % kg
    mass_f = mass_i - 4264.5; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 14.3e+6; % $
elseif type == "Castor-30B"
    Isp = 300.6; % s
    mass_i = 13971; % kg
    mass_f = mass_i - 12885; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 25.55e+6; % $
elseif type == "Castor-30XL"
    Isp = 294.4; % s
    mass_i = 26407; % kg
    mass_f = mass_i - 24925; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 38.94e+6; % $
elseif type == "Leros 4"
    Isp = 321; % s
    mass_i = 1351.8; % kg
    mass_f = mass_i - 1231.3; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 1.1; % $
elseif type == "Leros 2b"
    Isp = 320; % s
    mass_i = 959.7; % kg
    mass_f = mass_i - 862.7; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 1.1; % $
elseif type == "TR-312-100YN"
    Isp = 330; % s
    mass_i = 507.5; % kg
    mass_f = mass_i - 435.4; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 1; % $
elseif type == "Ariane 400N"
    Isp = 321; % s
    mass_i = 609.9; % kg
    mass_f = mass_i - 534.6; % kg
    dV = Isp*g0*log((sc_mass+mass_i)/(sc_mass+mass_f))/1000; % km/s
    Cost = 1; % $
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