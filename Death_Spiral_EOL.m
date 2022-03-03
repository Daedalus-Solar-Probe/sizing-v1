
mu = 132712440018;  % [km^3/s^2] solar gravitational parameter

% assuming starting and ending circular orbits ***** need to change *****
initial_radius = 0.48*1.496e+8; % [km]
desired_radius = 0.1*1.496e+8; % [km]


    beta = 0.05; % [-] 

    % ?????
    alpha = atan(1/sqrt(2));

    % time of flight
    tof = 1/3 * abs(desired_radius^1.5 - initial_radius^1.5) * ...
        sqrt( (1-beta*(cos(alpha))^3)/(beta^2*mu*(cos(alpha))^4*...
        (sin(alpha))^2) ) / 86400; % [days]

Period = 2*pi*sqrt(desired_radius^3/mu)/86400;
