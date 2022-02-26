function t_observation = observation_time(final_orbit)
    desired_radius = final_orbit.perihelion;
    desired_inclination = final_orbit.inclination;
    
    % Constants
    mu = 1.327*10^11;    % Solar Gravitational Parameter [km^3/s^2]
    %%%%%
    period = 2*pi*(desired_radius^3/mu)^.5;   % [s]
    period = round(period/60);                % Round Period to nearest minute for use in forloop
    
    % Initialize Time of Observation
    t_observation = 0;
    %%%%%
    for time = 1:1:period
       mean_anomaly = time*60*(mu / desired_radius^3)^.5 * 180 / pi;           % [deg]
       r_z = desired_radius * sind(desired_inclination) * sind(mean_anomaly);  % Radius normal to sun's equatorial plane [km]
       lat = asind(r_z / desired_radius);                                      % Heliocentric Latitude at time step [deg]     
       if abs(lat) >= 60
           t_observation = t_observation + 1;  % Increment time of observation
       end
    end
    t_observation = t_observation / 24 / 60;
end
