%% Clear

clear
clc

%% Base design

% Falcon Heavy (Expendable)
launch_vehicle.name = "Falcon Heavy (Expendable)";
launch_vehicle.C3 = 0:10:100; % [km^2/s^2]
launch_vehicle.mass = [15010, 12345, 10115, 8225, 6640, 5280, 4100, 3080, 2195, 1425, 770]; % [kg]


% All instraments
payload.name = "All";
payload.sensors = ["COR" "TSI" "EUVI" "DSI" "UVS" "MAG" "SW" "EPP" "RPW"];
payload.mass = [10, 7, 10, 25, 15, 1.5, 10, 9, 10]; % [kg]
payload.power = [15, 14, 12, 37, 22, 2.5, 15, 9, 15]; % [W]
payload.cost = [19.3, 13.7, 17.6, 41.5, 26.9, 6.8, 24.3, 17.9, 24.3]*1e6; % [USD]


% Solar Sail
propulsion.name = "Solar Sail based on ACS3";
propulsion.type = "Solar Sail";
propulsion.beta = 0.1; % [-] lightness factor
propulsion.rho_material = 0.0133; % [kg/m^2] sail material area density
propulsion.lambda_spars = 0.1286; % [kg/m] spar material linear density


% POLARIS Final Orbit
orbit.perihelion = 0.48*1.496e+8; % [km]
orbit.inclination = 90; % [rad]


% Venus flyby
flybys.name = "Single Venus";
flybys.planet = "Venus";
flybys.encounters = 1;
flybys.radius = 6051.9; % [km] planetary radius
flybys.mu = 324858.59883; % [km^3/2^2] standard gravitational parameter
flybys.a = 108207284; % [km] heliocentric semimajor axis
flybys.T = 19413722; % [s] heliocentric orbital period
flybys.dV = 2.5; % [km/s] Hohmann dV from Earth
flybys.tof = 120; % [days] Hohmann time of flight from Earth

% initial mass estimation
mass0.payload = sum(payload.mass); % [kg] everything minus propulsion
mass0.total = 2*sum(payload.mass); % [kg] everything

%% time to orbit vs final inclination

% initialize
inclinations = linspace(65,90); % [deg]
tofs = zeros(size(inclinations)); % [days]

for i = 1:length(inclinations)

    orbit.inclination = inclinations(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    tofs(i) = tof;

end % for

% plot
figure(1)
plot(inclinations,tofs,'b')
grid on
xlabel("Final Inclination [deg]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Final Inclination Trade Study")

% reset inclination
orbit.inclination = 90; % [-]

%% time to orbit vs lightness factor

% initialize 
betas = linspace(0.01,0.20); % [-]
tofs = zeros(size(inclinations)); % [days]

for i = 1:length(betas)

    propulsion.beta = betas(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    tofs(i) = tof;

end % for

% plot
figure(2)
plot(betas,tofs,'b')
grid on
xlabel("Lightness Factor [-]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Lightness Factor Trade Study")

% reset lightness factor
propulsion.beta = 0.1; % [-]

%% Spacecraft mass vs lightness factor

% initialize 
betas = linspace(0.01,0.20); % [-]
masses = zeros(size(inclinations)); % [kg]

for i = 1:length(betas)

    propulsion.beta = betas(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    masses(i) = mass.total;

end % for

% plot
figure(3)
plot(betas,masses,'b')
grid on
xlabel("Lightness Factor [-]")
ylabel("Spacecraft Mass [kg]")
title("Spacecraft Mass vs Lightness Factor")

% reset lightness factor, mass
propulsion.beta = 0.1; % [-]

%%% ethan's sensitivity attempts as of 2/25 follow: %%%

%% Spacecraft mass vs sail density

% initialize 
sail_rhos = linspace(0.001,0.025); % [-]
masses = zeros(size(inclinations)); % [kg]
tofs = zeros(size(inclinations)); % [days]

for i = 1:length(sail_rhos)

    propulsion.rho_material = sail_rhos(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    masses(i) = mass.total;
    tofs(i)= tof;

end % for

% plot
figure(4)
plot(sail_rhos,masses,'b')
grid on
xlabel("Sail Material Area Density [kg/m^2]")
ylabel("Spacecraft Mass [kg]")
title("Spacecraft Mass vs Sail Density")

figure(5)
plot(sail_rhos,tofs,'b')
grid on
xlabel("Sail Material Area Density [kg/m^2]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Sail Density")

% reset sail density
propulsion.rho_material = 0.0133; 

%% Spacecraft mass vs spar density

% initialize 
spar_rhos = linspace(0.01,1); % [-]
masses = zeros(size(inclinations)); % [kg]
tofs = zeros(size(inclinations)); % [days]

for i = 1:length(spar_rhos)

    propulsion.lambda_spars = sail_rhos(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    masses(i) = mass.total;
    tofs(i)= tof;

end % for

% plot
figure(6)
plot(spar_rhos,masses,'b')
grid on
xlabel("Spar Material Linear Density [kg/m]")
ylabel("Spacecraft Mass [kg]")
title("Spacecraft Mass vs Spar Density")

figure(7)
plot(spar_rhos,tofs,'b')
grid on
xlabel("Spar Material Linear Density [kg/m]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Spar Density")

% reset sail density
propulsion.lambda_spars = 0.1286;

