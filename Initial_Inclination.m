function [Theta] = Initial_Inclination (C3)
% This function is intended to estimate the inclination change possible
% using the excess C3 to raise the inclination before the venus flyby.

% Note: This function assumes Hohmann transfer to Venus for dV and V_tr
% velocities.
mu_sun = 1.327e+11; % [km^3 / s^2]
r_a = 1.496e+8; % [km]
r_p = 1.496e+8 * 0.7; % [km]
a = 1.496e+8 * 0.85; % [km]
% C3 = 219.74; % [km^2 / s^2]

V_i = sqrt(mu_sun / r_a); % [km / s] Initial velocity

V_tr = sqrt(mu_sun * (2 / r_a - 1 / a)); % [km / s] Final velocity

dV = V_i - V_tr; % [km / s] dV change

Tot_dV = sqrt(C3); % [km / s] Excess dV of Launch Vehicle + Kick Stage

Rem_dV = Tot_dV - dV; % [km / s] Excess dV - dV change

%% Version 1
% Inclination change possible with separate inclination and perihelion drop
% burns.
% Theta = 2*asin(Rem_dV / 2 / V_i)*180/pi; % [degrees]

%% Version 2 
% Inclination hange combined with perihilion drop.
Theta = acos((Tot_dV^2 - V_i^2 - V_tr^2) / (-2*V_i*V_tr))*180/pi; % [degrees]

end
