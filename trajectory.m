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
            fpa = 0;
        else
    
            [min_tof, Vs_1, fpa] = initial_flyby_min_TOF(C3, flybys);
            tof_total = tof_total + min_tof; % [days]
    
        end % if
    
        % find the modified orbit after the flyby
        [perihelion, aphelion] = flyby(Vs_1, flybys, fpa);
    
        initial_orbit.perihelion = perihelion; % [km]
        initial_orbit.aphelion = aphelion; % [km]
    
    else
    
    %     % earth
    %     initial_orbit.perihelion = 149597898; % [km]
    %     initial_orbit.aphelion = 149597898; % [km]
    
        error("No flybys not implemented yet!")
    
    end % if doing a flyby
    
    if (propulsion.type == "Solar Sail" && flybys.planet == "None") 
    
        % spiral orbit toward the sun
        initial_orbit.perihelion = 149597898; % [km]
        initial_orbit.aphelion = 149597898; % [km]
        [tof,dV] = spiraling(propulsion,initial_orbit,final_orbit);
        
        % increment tof and dV
        dV_total = dV_total + dV; % [km/s]
        tof_total = tof_total + tof; % [days]
        
        % crank the inclination
        [tof,dV] = cranking(propulsion,final_orbit);
        
        % increment tof and dV
        dV_total = dV_total + dV; % [km/s]
        tof_total = tof_total + tof; % [days]

    elseif (propulsion.type == "Solar Sail")
        % Post flyby trajectory 
        %[tof,dV] = post_flyby_solar_sail(propulsion, flybys, initial_orbit, final_orbit);
        
        r1 = flybys.a;
        r2 = initial_orbit.perihelion;
        if initial_orbit.perihelion < final_orbit.perihelion
            r2 = final_orbit.perihelion;
        end
    
        a = (initial_orbit.perihelion + initial_orbit.aphelion) / 2;
        e = (initial_orbit.aphelion - initial_orbit.perihelion) / (2*a);
    
        r2_list = linspace(r1, r2, 10001);
        TOF_list = zeros(1,length(r2));
        theta_1 = 2*pi - acos(1/e*(a*(1-e^2)/r1 - 1));
        E1 = 2*atan( sqrt((1-e)/(1+e)) * tan(theta_1/2) );

        if E1 < 0
               E1 = E1 + 2*pi;
        end

        for i = 1:length(r2_list)
            theta_2 = 2*pi - acos(1/e*(a*(1-e^2)/r2_list(i) - 1));
            E2 = 2*atan( sqrt((1-e)/(1+e)) * tan(theta_2/2) );
            
            if E2 < 0
               E2 = E2 + 2*pi; 
            end
            
            initial_orbit.perihelion = r2_list(i);
            [tof,dV] = spiraling(propulsion,initial_orbit,final_orbit);
            TOF_list(i) = abs(sqrt(a^3/mu) * (E2 - E1 - e* (sin(E2) - sin(E1))) / 86400) + tof;
        end

        [min_tof, index] = min(TOF_list);

        tof_total = tof_total + min(TOF_list); % [days]

%         if initial_orbit.perihelion < final_orbit.perihelion
%         initial_orbit.perihelion = final_orbit.perihelion;
%         end

        % spiral orbit toward the sun
%         [tof,dV] = spiraling(propulsion,initial_orbit,final_orbit);
%         dV_total = dV_total + dV; % [km/s]
%         tof_total = tof_total + tof; % [days]
        
        % crank the inclination
        [tof,dV] = cranking(propulsion,final_orbit);
        dV_total = dV_total + dV; % [km/s]
        tof_total = tof_total + tof; % [days]

    elseif (propulsion.type == "Ion")

        % crank the inclination
        initial_orbit.inclination = 90;
        [tof,dV] = cranking(propulsion,initial_orbit);
        
        % increment tof and dV
        dV_total = dV_total + dV; % [km/s]
        tof_total = tof_total + tof; % [days]

        % spiral orbit toward the sun
        initial_orbit.perihelion = flybys.a;
        [tof,dV] = spiraling(propulsion,initial_orbit,final_orbit);
        
        % increment tof and dV
        dV_total = dV_total + dV; % [km/s]
        tof_total = tof_total + tof; % [days]
    end

end % function
