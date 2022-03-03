%% Death Spiral

%% Explanation and Resources
% This Death_Spiral_EOM.m code examines a potential solar sail spiral
% trajectory into the sun. Starting from the science orbit of 0.48 AU it
% uses the same spiraling algorithm used to calculate TOF from the initial
% orbit to the science orbit. Final orbit radius was set to 0.1 AU
% arbitrarily, but it is unlikely the spacecraft would survive to this
% orbit unless specifically designed to.

% Note: Communication will be an issue as the spacecraft spirals toward the
% sun, with conjunctions likely occurring with increasing frequency and
% duration.
% https://ipnpr.jpl.nasa.gov/progress_report/42-147/147C.pdf
% Source suggests conjunction prevents communication when angle between
% Earth and Mars (in our case, our spacecraft orbiting sun) when distance
% is less than 2 solar radii (or 0.5 degrees). This conjunction will be 
% significant for a potential death spiral regarding the transmission of
% data.

%% Code
mu = 132712440018;  % [km^3/s^2] solar gravitational parameter

% assuming starting and ending circular orbits ***** need to change *****
initial_radius = 0.48*1.496e+8; % [km]
desired_radius = 0.1*1.496e+8; % [km]

    beta = 0.1; % [-] 

    % ?????
    alpha = atan(1/sqrt(2));

    % time of flight
    tof = 1/3 * abs(desired_radius^1.5 - initial_radius^1.5) * ...
        sqrt( (1-beta*(cos(alpha))^3)/(beta^2*mu*(cos(alpha))^4*...
        (sin(alpha))^2) ) / 86400; % [days]

Period = 2*pi*sqrt(desired_radius^3/mu)/86400;
