function [tof_total,dv_total] = ...
    trajectory_analysis(launcher,m_total,orbit,propulsion,flybys)
% Inputs:
%   launcher - struct containing launch vehicle information
%       launcher.type - string for the name, e.g. "NASA SLS"
%       launcher.masses - array of possible payload mass [kg]
%       launcher.C3 - array of excess C3 for each payload mass [km^2/s^2]
%
%   m_total - estimated total spacecraft mass [kg]
%
%   orbit - struct containing final spacecraft orbit
%       orbit.perihelion - final orbit perihelion [km]
%       orbit.aphelion - final orbit aphilion [km]
%       orbit.inclination - final orbit inclination [deg]
%
%   propulsion - struct containing propulsion information
%       propulsion.type - string for the name, e.g. "Solar Sail"
%
%   flybys - struct containing flyby information
%       flybys.planet - string for the name, e.g. "Venus", "None"
%
%
% Ouputs:
%   tof - time of flight (until final orbit first reached) [days]
%   dV - delta-V required for propulsion [km/s]

    dv_total = 0;
    tof_total = 0;
    
    method = propulsion.type;
    desired_radius = orbit.perihelion;
    
    [dv, tof, Vs_1] = hohmann_encounter(flybys.planet, launcher.C3);
    
    if dv == -1 % if C3 is larger than the required hohmann dv, then use other function
        dv = 0;
        [tof, Vs_1, fpa] = initial_flyby_min_TOF(launcher.C3, flybys.planet);
    end
    

    dv_total = dv_total + dv;
    tof_total = tof_total + tof;

    [perihelion, aphelion] = flyby(Vs_1, flybys.planet);
    
    % For solar sail, input should be perihelion = aphelion = initial_radius
    [tof,dV,beta] = spiraling(method,flybys.planet,desired_radius,m_total);
    
    dv_total = dv_total + dV;
    tof_total = tof_total + tof;
    
    starting_orbit = desired_radius; % at 0 inclination
    
    [tof,dV] = cranking(method,orbit.inclination,starting_orbit, beta, m_total);

    dv_total = dv_total + dV;
    tof_total = tof_total + tof;
    
    % Impossible solar sail + flyby case:
%     if solar_sail_flyby_check(flybys.planet, beta, Vs_1) == 0
%         dv_total = -1;
%         tof_total = -1;
%     end
    
    t_observation = observation_time(desired_radius, orbit.inclination) / 86400;
end


function [dv, tof, Vs_1] = hohmann_encounter(flyby_planet, C3)
% assumptions:
% always starting from earth

Planet_Info = [2439.7, 6051.9, 3397, 71492; 22032.0805, 324858.59883, 42828.3143, 126712767.858; 57909101, 108207284, 227944135, 778279959; 7600537, 19413722, 59356281, 374479305; 7.5, 2.5, 2.9, 8.8; 106.75, 120, 259.25, 730];
% Col 1-Mercury 2-Venus 3-Mars 4-Jupiter
% Row 1-Equatorial Radius(km) 2-Grav Param(km^3/s^2) 3-SemiMajor Axis(km)
% 4- Period(sec) 5- Hohmann dV to reach from Earth(km/s) 
% 6- Hohmann TOF to Planet (days)

    dv = 0;
    tof = 0;
    Vs_1 = 0;
    
    if flyby_planet == "Mercury"
        n = 1;
    elseif flyby_planet == "Venus"
        n = 2;
    elseif flyby_planet == "Mars"
        n = 3;    
    elseif flyby_planet == "Jupiter"
        n = 4;
    else
        return;
    end
    
    if sqrt(C3) < Planet_Info(5,n)
        dv = Planet_Info(5,n) - sqrt(C3); %(Equation for TotaldV to reach planet) (km/s)
    else
        dv = -1;
        return;
    end
    
    tof = (Planet_Info(6,n))*24*60*60; %(Equation for Hohmann Transfer TOF to Planet)
    
    atrans = 0.5*(149597898+Planet_Info(3,n)); % SemiMajor Axis of Hohmann transfer orbit
    Vs_1 = sqrt(2*((132712440018/Planet_Info(3,n))-(132712440018/(2*atrans)))); %Heliocentric velocity for planet approach
end


function [perihelion, aphelion] = flyby(Vs_1, flyby_planet)
% assumptions:
%

Planet_Info = [2439.7, 6051.9, 3397, 71492; % r
    22032.0805, 324858.59883, 42828.3143, 126712767.858; % mu
    57909101, 108207284, 227944135, 778279959;  % a
    7600537, 19413722, 59356281, 374479305;  % T
    7.5, 2.5, 2.9, 8.8; % dV
    106.75, 120, 259.25, 730]; % tof
% Col 1-Mercury 2-Venus 3-Mars 4-Jupiter
% Row 1-Equatorial Radius(km) 2-Grav Param(km^3/s^2) 3-SemiMajor Axis(km)
% 4- Period(sec) 5- Hohmann dV to reach from Earth(km/s) 
% 6- Hohmann TOF to Planet (days)

    perihelion = 0;
    aphelion = 0;
    
    if flyby_planet == "Mercury"
        n = 1;
    elseif flyby_planet == "Venus"
        n = 2;
    elseif flyby_planet == "Mars"
        n = 3;    
    elseif flyby_planet == "Jupiter"
        n = 4;
    else
        return;
    end
    
    Vplanet = sqrt((132712440018+Planet_Info(2,n))/(Planet_Info(3,n)));
    Vinf = abs(Vs_1 - Vplanet); % V infinity for flyby encounter for flyby encounter in degrees
    delta = 2*asin(1 / ((Planet_Info(1,n)/(Planet_Info(2,n)/(Vinf^2)) +1 )) ); % delta angle in radians
    Vplus = sqrt(Vplanet^2 + Vinf^2 - 2*Vinf*Vplanet*sin(delta)); %Velocity post flyby
    fpaplus = -1* asin(sin(delta)*Vinf/Vplus); %flight path angle post fly by    
    afinal = (-132712440018/2)/(((Vplus^2)/2)-(132712440018/Planet_Info(3,n))); % semimajor axis post fly by
    hfinal = abs(Planet_Info(3,n)*(cos(fpaplus)*Vplus)); % angular momentum post fly by
    pfinal = hfinal^2 / 132712440018; %Semilatus rectum post flyby
    efinal = sqrt(1- (pfinal/afinal)); %eccentricity post flyby
    
    perihelion = afinal*(1-efinal); % kilometers
    aphelion = afinal*(1+efinal); % kilometers
end


function [tof,dV,beta] = spiraling(method,flyby_planet,desired_radius,mass)
% assumptions:
% either solar sail or ion
% for solar sail use same values as POLARIS
    beta = 0;
    tof = 0;
    dV = 0;

    Planet_r = [57909101, 108207284, 227944135, 778279959, 149597898];
    mu = 132712440018;  % km^3 / s^2

    if flyby_planet == "Mercury"
        n = 1;
    elseif flyby_planet == "Venus"
        n = 2;
    elseif flyby_planet == "Mars"
        n = 3;    
    elseif flyby_planet == "Jupiter"
        n = 4;
    else
        n = 5;  % Earth
    end
    initial_radius = Planet_r(n);
    
    if method == "Solar Sail"
        % S_0 = affordable_budget * 0.8 / price_per_area;
        % a_c = 8.172 / (M_total * 1000) * S_0;   % M_total (kg), S_0(m^2)
        % beta = a_c / 5.93;
        
        beta = 0.1;
        alpha = atan(1/sqrt(2));
        tof = 1/3 * abs(desired_radius^1.5 - initial_radius^1.5) * sqrt( (1-beta*(cos(alpha))^3)/(beta^2*mu*(cos(alpha))^4*(sin(alpha))^2) ) / 86400; % days
    end
            
     if method == "Ion"
       dV = sqrt(mu/desired_radius) - sqrt(mu/initial_radius);
       T = 1.77 / mass / 1000; % acceleration from ion engine, km/s^2
       tof = dV/ T / 86400;
     end
end


function [tof,dV] = cranking(method,desired_inclination,starting_orbit, beta, total_mass)
% assumptions:
% either solar sail or ion
% desired radius is the starting point
    tof = 0;
    dV = 0;           
    mu = 132712440018;
           
    if method == "Solar Sail"
           alpha = atan(1/sqrt(2));
           di = 4 * beta * (cos(alpha))^2 * sin(alpha) * 180 / pi; % deg/orbit
           period = 2*pi*sqrt(starting_orbit^3/mu) / 86400; % day/orbit
           tof = desired_inclination / di * period;
    end

    if method == "Ion"
       T = 1.77; % thrust in Newtons using AEPS as reference 
       period = 2*pi*sqrt(starting_orbit^3/mu); 
       delta_v = T*period/total_mass/1000; % delta v from ion engine per period, km/s
       v =  sqrt(mu/starting_orbit); 
       inclin_change = 0.5*asind(delta_v / (2*v)); % assuming circular orbit, deg/orbit
       num_periods = desired_inclination / inclin_change;
       tof = period * num_periods / 86400;
       dV = delta_v * num_periods;
    end
end


function t_observation = observation_time(desired_radius, desired_inclination)
% Constants
mu = 1.327*10^11;    % Solar Gravitational Parameter [km^3/s^2]
%%%%%
period = 2*pi*(desired_radius^3/mu)^.5;   % [s]
period = round(period);                   % Round Period to nearest second for use in forloop
% Initialize Time of Observation
t_observation = 0;
%%%%%
for time = 1:1:period
   mean_anomaly = time*(mu / desired_radius^3)^.5 * 180 / pi;              % [deg]
   r_z = desired_radius * sind(desired_inclination) * sind(mean_anomaly);  % Radius normal to sun's equatorial plane [km]
   lat = asind(r_z / desired_radius);                                      % Heliocentric Latitude at time step [deg]     
   if abs(lat) >= 60
       t_observation = t_observation + 1;  % Increment time of observation
   end
end
end


% 1 for possible  and  0 for not possible
function possible = solar_sail_flyby_check(flyby_planet, beta, Vs_1)

    % For solar sail, post-flyby trajectory is fixed due to required V and FPA
    % So, Vs_1 may be too large or small for spiral trajectory after flyby
    
    possible = 1;
    Planet_Info = [2439.7, 6051.9, 3397, 71492; 22032.0805, 324858.59883, 42828.3143, 126712767.858; 57909101, 108207284, 227944135, 778279959; 7600537, 19413722, 59356281, 374479305; 7.5, 2.5, 2.9, 8.8; 106.75, 120, 259.25, 730];
    % Col 1-Mercury 2-Venus 3-Mars 4-Jupiter
    % Row 1-Equatorial Radius(km) 2-Grav Param(km^3/s^2) 3-SemiMajor Axis(km)
    % 4- Period(sec) 5- Hohmann dV to reach from Earth(km/s)
    % 6- Hohmann TOF to Planet (days)
    
    if flyby_planet == "Mercury"
        n = 1;
    elseif flyby_planet == "Venus"
        n = 2;
    elseif flyby_planet == "Mars"
        n = 3;    
    elseif flyby_planet == "Jupiter"
        n = 4;
    else
        return;
    end
    
    % Post-flyby characteristics
    alpha = atan(1/sqrt(2));
    mu = 132712440018;
    desired_fpa = atan( (2*beta*(cos(alpha))^2*sin(alpha)) / (1-beta*(cos(alpha))^3) ); % FPA after flyby
    V_planet = sqrt( (mu + Planet_Info(2,n)) / (Planet_Info(3,n)) );
    V_f = sqrt(mu/Planet_Info(2,n)) * sqrt(1-beta*(cos(alpha))^2*(cos(alpha)-sin(alpha)*tan(desired_fpa)));
    V_inf = sqrt(V_planet^2 + V_f^2 - 2*V_f*V_planet*sin(delta));

    % if the initial velocity is not in qualified range, return 0
    % The initial velocity is too big or small
    if Vs_1 > (V_planet + V_inf) || Vs_1 < (V_planet - V_inf)
        possible = 0;
        return;
    end

    
     % Transfer orbit characteristics from Earth to flyby planet
%     initial_fpa = acos( (Vs_1^2+V_planet^2-V_inf^2) / (2*Vs_1*V_planet));
%     r = Planet_Info(3,n);
%     e_initial = sqrt( (r*Vs_1^2/132712440018 - 1)^2 * (cos(initial_fpa))^2 + (sin(initial_fpa))^2);
%     a_initial = -2*mu / (Vs_1^2 / 2 - mu/r);
%     perihelion = a_initial * (1-e_initial);
%     aphelion = a_initial * (1+e_initial);
    
end


function [min_tof, Vs_1, fpa] = initial_flyby_min_TOF(C3, flyby_planet)

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
    Planet_r = [57909101, 108207284, 227944135, 778279959]; % SemiMajor Axis(km)
    %Planet_P = [7600537, 19413722, 59356281, 374479305];    % Period (sec)

    if flyby_planet == "Mercury"
        n = 1;
    elseif flyby_planet == "Venus"
        n = 2;
    elseif flyby_planet == "Mars"
        n = 3;    
    elseif flyby_planet == "Jupiter"
        n = 4;
    else 
        return;
    end
    
    mu = 132712440018;
    r1 = 149597898;
    r2 = Planet_r(n);
    
    V_E = sqrt((mu + 398600) / 149597898);
    V_E_inf = sqrt(C3);
    %alpha = atan(1/sqrt(2));
    
    C3_angle = linspace(0, pi, 1801);
    TOF_list = zeros(1,length(C3_angle));
    Vs_list = zeros(1,length(C3_angle));
    fpa_list = zeros(1,length(C3_angle));
    
    % Delete this later
    fpa_E_f_list = zeros(1,length(C3_angle));
    
    if flyby_planet == "Venus" || flyby_planet == "Mercury"
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
    elseif flyby_planet == "Mars" || flyby_planet == "Jupiter"
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
