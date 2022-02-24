function [min_tof, Vs_1, fpa] = initial_flyby_min_TOF(C3, flybys)

    % min_tof   - Time of flight from Earth to the flyby planet (days)
    % Vs_1      - Spacecraft velocity at the flyby planet before flyby (km/s)
    % fpa       - Flight path angle of the spacecraft at the flyby planet (rad)
    
    % C3        - Excess Energy (= v_inf^2) (km^2/s^2)
    % flyby_planet - one of {"Mercury", "Venus", "Mars", "Jupiter"}
    
    % Assumed:
    % e < 1 in heliocentric frame
    % circular and coplanar planet orbits
    
    min_tof = -1;
    Vs_1 = -1;
    fpa = -1;
    
    % 1-Mercury  2-Venus  3-Mars  4-Jupiter
    %Planet_radius = [2439.7, 6051.9, 3397, 71492];  % Equatorial Radius(km)
    %Planet_mu = [22032.0805, 324858.59883, 42828.3143, 126712767.858];
%     Planet_r = [57909101, 108207284, 227944135, 778279959]; % SemiMajor Axis(km)
    %Planet_P = [7600537, 19413722, 59356281, 374479305];    % Period (sec)
    
    mu = 132712440018; % [km^3/s^2] solar gravitational parameter
    r1 = 149597898; % [km] earth semi-major axis
    r2 = flybys.a; % [km] flyby planet semi-major axis
    
    V_E = sqrt((mu + 398600) / 149597898);
    V_E_inf = sqrt(C3);
    %alpha = atan(1/sqrt(2));
    
    C3_angle = linspace(0, pi, 1801);
    TOF_list = zeros(1,length(C3_angle));
    Vs_list = zeros(1,length(C3_angle));
    fpa_list = zeros(1,length(C3_angle));
    
    % Delete this later
    fpa_E_f_list = zeros(1,length(C3_angle));
    
    if flybys.planet == "Venus" || flybys.planet == "Mercury"
        for i = 1:length(C3_angle)
            V_E_f = sqrt(V_E_inf^2+V_E^2-2*V_E_inf*V_E*cos(pi-C3_angle(i)));
            fpa_E_f = -asin(V_E_inf/V_E_f * sin(pi-C3_angle(i)));
            e = sqrt( (r1*V_E_f^2/mu - 1)^2 * (cos(fpa_E_f))^2 + (sin(fpa_E_f))^2 );
            a = -mu / (V_E_f^2 / 2 - mu/r1)/2;

            % Delete this later 
            fpa_E_f_list(i) = fpa_E_f * 180/pi;
            
            if a * (1-e) > r2 || a * (1+e) < r2
                TOF_list(i) = intmax;
                continue;
            end

            theta_1 = 2*pi - acos(1/e*(a*(1-e^2)/r1 - 1));
            theta_2 = 2*pi - acos(1/e*(a*(1-e^2)/r2 - 1));
            
            E1 = 2*atan( sqrt((1-e)/(1+e)) * tan(theta_1/2) );
            E2 = 2*atan( sqrt((1-e)/(1+e)) * tan(theta_2/2) );
            
            if E2 < 0
               E2 = E2 + 2*pi; 
            end
            
            TOF_list(i) = sqrt(a^3/mu) * (E2 - E1 - e* (sin(E2) - sin(E1))) / 86400;
            Vs_list(i) = sqrt(mu*(2/r2 - 1/a));
            fpa_list(i) = atan(e*sin(theta_2)/(1+e*cos(theta_2)));
            if fpa_list(i) > 0
                fpa_list(i) = -fpa_list(i);
            end
        end
    elseif flybys.planet == "Mars" || flybys.planet == "Jupiter"
        for i = 1:length(C3_angle)
            V_E_f = sqrt(V_E_inf^2+V_E^2-2*V_E_inf*V_E*cos(pi-C3_angle(i)));
            fpa_E_f = asin(V_E_inf/V_E_f * sin(pi-C3_angle(i)));
            e = sqrt( (r1*V_E_f^2/mu - 1)^2 * (cos(fpa_E_f))^2 + (sin(fpa_E_f))^2);
            a = -mu / (V_E_f^2 / 2 - mu/r1)/2;

            if a * (1-e) > r2 || a * (1+e) < r2
                TOF_list(i) = intmax;
                continue;
            end

            theta_1 = acos( 1/e * (a*(1-e^2)/r1 - 1) );
            theta_2 = acos(1/e*(a*(1-e^2)/r2 - 1));
            
            E1 = 2*atan( sqrt((1-e)/(1+e)) * tan(theta_1/2) );
            E2 = 2*atan( sqrt((1-e)/(1+e)) * tan(theta_2/2) );
            
            TOF_list(i) = sqrt(a^3/mu) * (E2 - E1 - e * (sin(E2) - sin(E1))) / 86400;
            
            Vs_list(i) = sqrt(mu*(2/r2 - 1/a));
            fpa_list(i) = atan(e*sin(theta_2)/(1+e*cos(theta_2)));
            if fpa_list(i) < 0
                fpa_list(i) = -fpa_list(i);
            end
        end
    else
        return;
    end

    % find min TOF in TOF list
    [min_tof, index] = min(TOF_list);
    Vs_1 = Vs_list(index);
    fpa = fpa_list(index);

 end