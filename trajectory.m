function [dV_total, tof_total] = trajectory(launch_vehicle,flybys,propulsion,final_orbit,mass)

% solar standard gravitational parameter
mu = 132712440018; % [km^3/s^2]

% running totals
dV_total = 0; % [km/s]
tof_total = 0; % [km/s]

% Launch vehicle excess Earth C3
C3 = interp1(launch_vehicle.mass,launch_vehicle.C3,mass.total,'linear','extrap'); % [km^2/s^2]

% check for positive C3
if C3 < 0
    error("Negative C3")
end % if


% are we doing any flybys?
if flybys.name ~= "None"

    % not enough C3 for encounter (burn just enough for Hohmann transfer)
    if sqrt(C3) < flybys.dV

        dV_total = dV_total + flybys.dV - sqrt(C3); % [km/s]
        tof_total = tof_total + flybys.tof; % [days]

        atrans = 0.5*(149597898+flybys.a); % [km] SemiMajor Axis of Hohmann transfer orbit
        Vs_1 = sqrt(2*((mu/flybys.a)-(mu/(2*atrans)))); % [km/s] Heliocentric velocity for planet approach

    else

        [min_tof, Vs_1, ~] = initial_flyby_min_TOF(C3, flybys);

        tof_total = tof_total + min_tof; % [days]

    end % if

    % find the modified orbit after the flyby
    [perihelion, aphelion] = flyby(Vs_1, flybys);

    initial_orbit.perihelion = perihelion; % [km]
    initial_orbit.aphelion = aphelion; % [km]

else

%     % earth
%     initial_orbit.perihelion = 149597898; % [km]
%     initial_orbit.aphelion = 149597898; % [km]

    error("No flybys not implemented yet!")

end % if doing a flyby

% spiral orbit toward the sun
[tof,dV] = spiraling(propulsion,initial_orbit,final_orbit);

% increment tof and dV
dV_total = dV_total + dV; % [km/s]
tof_total = tof_total + tof; % [days]

% crank the inclination
[tof,dV] = cranking(propulsion,final_orbit);

% increment tof and dV
dV_total = dV_total + dV; % [km/s]
tof_total = tof_total + tof; % [days]


end % function