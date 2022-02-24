function [tof,dV] = spiraling(propulsion,initial_orbit,final_orbit)
% assumptions:
% either solar sail or ion
% for solar sail use same values as POLARIS

% constants
mu = 132712440018;  % [km^3/s^2] solar gravitational parameter

% assuming starting and ending circular orbits ***** need to change *****
initial_radius = initial_orbit.perihelion; % [km]
desired_radius = final_orbit.perihelion; % [km]

% solar sail propulsion
if propulsion.type == "Solar Sail"

    % delta-V required
    dV = 0; % [km/s]

    % lightness factor
    beta = propulsion.beta; % [-] 

    % ?????
    alpha = atan(1/sqrt(2));

    % time of flight
    tof = 1/3 * abs(desired_radius^1.5 - initial_radius^1.5) * ...
        sqrt( (1-beta*(cos(alpha))^3)/(beta^2*mu*(cos(alpha))^4*...
        (sin(alpha))^2) ) / 86400; % [days]

% ion engine propulsion
elseif propulsion.type == "Ion"
    
    % delta-V required
    dV = sqrt(mu/desired_radius) - sqrt(mu/initial_radius); % [km/s]

    % ion engine acceleration
    T = propulsion.accel/1000; % [km/s^2]

    % time of flight
    tof = dV / T / 86400; % [days]

end % if/elseif

end % function