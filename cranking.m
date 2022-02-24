function [tof,dV] = cranking(propulsion,final_orbit)
% assumptions:
% either solar sail or ion
% desired radius is the starting point

% solar gravitational parameter
mu = 132712440018; % [km^3/s^2]

% solar sail propulsion     
if propulsion.type == "Solar Sail"

    % no delta-V required!
    dV = 0; % [km/s]

    % ???
    alpha = atan(1/sqrt(2));

    % degrees per orbit
    di = 4 * propulsion.beta * (cos(alpha))^2 * sin(alpha) * 180 / pi; % [deg/orbit]

    % orbital period
    period = 2*pi*sqrt(final_orbit.perihelion^3/mu) / 86400; % [day/orbit]

    % time of flight
    tof = final_orbit.inclination / di * period; % [days]

% ion engine propulsion
elseif propulsion.type == "Ion"

    % nominal acceleration
    T = propulsion.accel; % [km/s]

    % orbital period
    period = 2*pi*sqrt((final_orbit.perihelion)^3/mu); % [days]

    % delta-V per period
    delta_v = T*period/1000; % [km/s]

    % final velocity (circular)
    v = sqrt(mu/final_orbit.perihelion); % [km/s]

    % degrees per orbit
    inclin_change = 2*asind(delta_v / (2*v)); % [deg/orbit]

    % number of orbits required
    num_periods = final_orbit.inclination / inclin_change; % [orbits]

    % time of flight
    tof = period * num_periods / 86400; % [days]

    % total delta-V required
    dV = delta_v * num_periods; % [km/s]

% other propulsion type
else
    
    error("Unsupported propulsion type!")

end % if/elseif/else

end % function
