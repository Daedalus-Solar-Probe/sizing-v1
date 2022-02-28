%% Clear

clear
clc
close all

%% Base design

% Falcon Heavy (Expendable)
launch_vehicle.name = "Falcon Heavy (Expendable)";
launch_vehicle.C3 = 0:10:100; % [km^2/s^2]
launch_vehicle.mass = [15010, 12345, 10115, 8225, 6640, 5280, 4100, 3080, 2195, 1425, 770]; % [kg]


% payload.name = "All";
payload.sensors = ["COR" "TSI" "EUVI" "DSI" "UVS" "MAG" "SW" "EPP" "RPW"];
payload.mass = [10, 7, 10, 25, 15, 1.5, 10, 9, 10]; % [kg]
payload.power = [15, 14, 12, 37, 22, 2.5, 15, 9, 15]; % [W]
payload.cost = [19.3, 13.7, 17.6, 41.5, 26.9, 6.8, 24.3, 17.9, 24.3]*1e6; % [USD]

% payload.name = "Remote+MAG";
% payload.sensors = ["COR" "TSI" "EUVI" "DSI" "UVS" "MAG"];
% payload.mass = [10, 7, 10, 25, 15, 1.5]; % [kg]
% payload.power = [15, 14, 12, 37, 22, 2.5]; % [W]
% payload.cost = [19.3, 13.7, 17.6, 41.5, 26.9, 6.8]*1e6; % [USD]
% 
% payload.name = "In Situ";
% payload.sensors = ["MAG" "SW" "EPP" "RPW"];
% payload.mass = [1.5, 10, 9, 10]; % [kg]
% payload.power = [2.5, 15, 9, 15]; % [W]
% payload.cost = [6.8, 24.3, 17.9, 24.3]*1e6; % [USD]

% payload.sensors = ["EUVI" "DSI" "MAG"];
% payload.mass = [10, 25,1.5]; % [kg]
% payload.power = [12, 37,2.5]; % [W]
% payload.cost = [17.6, 41.5,6.8]*1e6; % [USD]


% Solar Sail
propulsion.name = "Solar Sail based on ACS3";
propulsion.type = "Solar Sail";
propulsion.beta = 0.1; % [-] lightness factor
propulsion.rho_material = 0.005; % [kg/m^2] sail material area density
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

%% final inclination trades

% initialize
inclinations = linspace(65,90); % [deg]
masses = zeros(size(inclinations)); % [kg]
tofs = zeros(size(inclinations)); % [days]
costs = zeros(size(inclinations));

for i = 1:length(inclinations)

    orbit.inclination = inclinations(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    tofs(i) = tof;
    masses(i)=mass.total;
    costs(i)=cost;

end % for

% plot
figure(1)
subplot(3,1,1)
plot(inclinations,tofs,'b')
grid on
xlabel("Final Inclination [deg]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Final Inclination")

subplot(3,1,2)
plot(inclinations,masses,'b')
grid on
xlabel("Final Inclination [deg]")
ylabel("Spacecraft Mass [kg]")
title("Spacecraft Mass vs Final Inclination")

subplot(3,1,3)
plot(inclinations,costs,'b')
grid on
xlabel("Final Inclination [deg]")
ylabel("Cost (USD)")
title("Cost vs Final Inclination")

% reset inclination
orbit.inclination = 90; % [-]

%% lightness factor trades

% initialize 
betas = linspace(0.01,0.20); % [-]

for i = 1:length(betas)

    propulsion.beta = betas(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    tofs(i) = tof;
    masses(i) = mass.total;
    costs(i)=cost;

end % for

% plot
figure(2)
subplot(3,1,1)
plot(betas,tofs,'b')
grid on
xlabel("Lightness Factor [-]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Lightness Factor")

subplot(3,1,2)
plot(betas,masses,'b')
grid on
xlabel("Lightness Factor [-]")
ylabel("Spacecraft Mass [kg]")
title("Spacecraft Mass vs Lightness Factor")

subplot(3,1,3)
plot(betas,costs,'b')
grid on
xlabel("Lightness Factor [-]")
ylabel("Cost (USD)")
title("Cost vs Lightness Factor")

% reset lightness factor, mass
propulsion.beta = 0.1; % [-]


%% sail density trades

% initialize 
sail_rhos = linspace(0.001,0.025); % [-]

for i = 1:length(sail_rhos)

    propulsion.rho_material = sail_rhos(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    masses(i) = mass.total;
    tofs(i)= tof;
    costs(i)=cost;

end % for

% plot
figure(3)
subplot(3,1,1)
plot(sail_rhos,masses,'b')
grid on
xlabel("Sail Material Area Density [kg/m^2]")
ylabel("Spacecraft Mass [kg]")
title("Spacecraft Mass vs Sail Density")

subplot(3,1,2)
plot(sail_rhos,tofs,'b')
grid on
xlabel("Sail Material Area Density [kg/m^2]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Sail Density")

subplot(3,1,3)
plot(sail_rhos,costs,'b')
grid on
xlabel("Sail Material Area Density [kg/m^2]")
ylabel("Cost (USD)")
title("Cost vs Sail Density")

% reset sail density
propulsion.rho_material = 0.0133; 

%% spar density trades

% initialize 
spar_rhos = linspace(0.01,1); % [-]

for i = 1:length(spar_rhos)

    propulsion.lambda_spars = sail_rhos(i);
    [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0);
    masses(i) = mass.total;
    tofs(i)= tof;
    costs(i)=cost;

end % for

% plot
figure(4)
subplot(3,1,1)
plot(spar_rhos,masses,'b')
grid on
xlabel("Spar Material Linear Density [kg/m]")
ylabel("Spacecraft Mass [kg]")
title("Spacecraft Mass vs Spar Density")

subplot(3,1,2)
plot(spar_rhos,tofs,'b')
grid on
xlabel("Spar Material Linear Density [kg/m]")
ylabel("Time to Orbit [days]")
title("Time to Orbit vs Spar Density")

subplot(3,1,3)
plot(spar_rhos,costs,'b')
grid on
xlabel("Sail Material Area Density [kg/m^2]")
ylabel("Cost (USD)")
title("Cost vs Sail Density")

% reset sail density
propulsion.lambda_spars = 0.1286;

%% payload trades

payload1.name = "All";
payload1.sensors = ["COR" "TSI" "EUVI" "DSI" "UVS" "MAG" "SW" "EPP" "RPW"];
payload1.mass = [10, 7, 10, 25, 15, 1.5, 10, 9, 10]; % [kg]
payload1.power = [15, 14, 12, 37, 22, 2.5, 15, 9, 15]; % [W]
payload1.cost = [19.3, 13.7, 17.6, 41.5, 26.9, 6.8, 24.3, 17.9, 24.3]*1e6; % [USD]

[tof1,mass1,cost1] = sizing(launch_vehicle,payload1,propulsion,orbit,flybys,mass0);
mass1=mass1.total;

payload2.name = "Remote+MAG";
payload2.sensors = ["COR" "TSI" "EUVI" "DSI" "UVS" "MAG"];
payload2.mass = [10, 7, 10, 25, 15, 1.5]; % [kg]
payload2.power = [15, 14, 12, 37, 22, 2.5]; % [W]
payload2.cost = [19.3, 13.7, 17.6, 41.5, 26.9, 6.8]*1e6; % [USD]

[tof2,mass2,cost2] = sizing(launch_vehicle,payload2,propulsion,orbit,flybys,mass0);
mass2=mass2.total;

payload3.name = "In Situ";
payload3.sensors = ["MAG" "SW" "EPP" "RPW"];
payload3.mass = [1.5, 10, 9, 10]; % [kg]
payload3.power = [2.5, 15, 9, 15]; % [W]
payload3.cost = [6.8, 24.3, 17.9, 24.3]*1e6; % [USD]

[tof3,mass3,cost3] = sizing(launch_vehicle,payload3,propulsion,orbit,flybys,mass0);
mass3=mass3.total;

payload4.sensors = ["EUVI" "DSI" "MAG"];
payload4.mass = [10, 25,1.5]; % [kg]
payload4.power = [12, 37,2.5]; % [W]
payload4.cost = [17.6, 41.5,6.8]*1e6; % [USD]

[tof4,mass4,cost4] = sizing(launch_vehicle,payload4,propulsion,orbit,flybys,mass0);
mass4=mass4.total;

figure(5)
plot3(tof1,mass1,cost1,'*',tof2,mass2,cost2,'x',...
    tof3,mass3,cost3,'+',tof4,mass4,cost4,'o')
grid on; title('Payload Trade Studies')
legend('All Instruments','Remote + MAG','In Situ','EUVI+DSI+MAG')
xlabel('Time to Flight [days]');ylabel('Spacecraft Mass [kg]');
zlabel('Cost [USD]')
view([45 25])

%% flyby trades

% Mercury
flybys1.name = "Single Mercury";
flybys1.planet = "Mercury";
flybys1.encounters = 1;
flybys1.radius = 2439.7; % [km] planetary radius
flybys1.mu = 22032.0805; % [km^3/2^2] standard gravitational parameter
flybys1.a = 57909101; % [km] heliocentric semimajor axis
flybys1.T = 7600537; % [s] heliocentric orbital period
flybys1.dV = 7.5; % [km/s] Hohmann dV from Earth
flybys1.tof = 106.75; % [days] Hohmann time of flight from Earth

[tof_merc,mass_merc,cost_merc] = sizing(launch_vehicle,payload,...
    propulsion,orbit,flybys1,mass0);
mass_merc=mass_merc.total;

% Venus
flybys2.name = "Single Venus";
flybys2.planet = "Venus";
flybys2.encounters = 1;
flybys2.radius = 6051.9; % [km] planetary radius
flybys2.mu = 324858.59883; % [km^3/2^2] standard gravitational parameter
flybys2.a = 108207284; % [km] heliocentric semimajor axis
flybys2.T = 19413722; % [s] heliocentric orbital period
flybys2.dV = 2.5; % [km/s] Hohmann dV from Earth
flybys2.tof = 120; % [days] Hohmann time of flight from Earth

[tof_ven,mass_ven,cost_ven] = sizing(launch_vehicle,payload,...
    propulsion,orbit,flybys2,mass0);
mass_ven=mass_ven.total;


% % Mars
flybys3.name = "Single Mars";
flybys3.planet = "Mars";
flybys3.encounters = 1;
flybys3.radius = 3397; % [km] planetary radius
flybys3.mu = 42828.3143; % [km^3/2^2] standard gravitational parameter
flybys3.a = 227944135; % [km] heliocentric semimajor axis
flybys3.T = 59356281; % [s] heliocentric orbital period
flybys3.dV = 2.9; % [km/s] Hohmann dV from Earth
flybys3.tof = 259.25; % [days] Hohmann time of flight from Earth

[tof_mar,mass_mar,cost_mar] = sizing(launch_vehicle,payload,...
    propulsion,orbit,flybys3,mass0);
mass_mar=mass_mar.total;


% Jupiter
flybys4.name = "Single Jupiter";
flybys4.planet = "Jupiter";
flybys4.encounters = 1;
flybys4.radius = 71492; % [km] planetary radius
flybys4.mu = 126712767.858; % [km^3/2^2] standard gravitational parameter
flybys4.a = 778279959; % [km] heliocentric semimajor axis
flybys4.T = 374479305; % [s] heliocentric orbital period
flybys4.dV = 8.8; % [km/s] Hohmann dV from Earth
flybys4.tof = 730; % [days] Hohmann time of flight from Earth

[tof_jup,mass_jup,cost_jup] = sizing(launch_vehicle,payload,...
    propulsion,orbit,flybys4,mass0);
mass_jup=mass_jup.total;


figure(6)
plot(tof_merc,cost_merc,'*',...
    tof_ven,cost_ven,'x',...
    tof_mar,cost_mar,'+',...
    tof_jup,cost_jup,'o')
grid on;
title('Flyby Trade Study')
legend('Mercury Flyby','Venus Flyby','Mars Flyby','Jupiter Flyby')
xlabel('Time to Flight [days]');ylabel('Cost [USD]')

%% Launch Vehicles Tradeoffs

% % Vulcan Centaur (6 SRBs)
launch_vehicle1.name = "Vulcan Centaur";
launch_vehicle1.C3 = 0:10:100; % [km^2/s^2]
launch_vehicle1.mass = [10850, 9130, 7630, 6310, 5150, 4120, 3250, 2420, 1780, 1370, 755]; % [kg]

[tof_vc,mass_vc,cost_vc] = sizing(launch_vehicle1,payload,...
    propulsion,orbit,flybys,mass0);
mass_vc=mass_vc.total;

% % Falcon Heavy (Recovery)
launch_vehicle2.name = "Falcon Heavy (Recovery)";
launch_vehicle2.C3 = 0:10:70; % [km^2/s^2]
launch_vehicle2.mass = [6690, 4930, 3845, 2740, 1805, 1005, 320, 0]; % [kg]

[tof_fhr,mass_fhr,cost_fhr] = sizing(launch_vehicle2,payload,...
    propulsion,orbit,flybys,mass0);
mass_fhr=mass_fhr.total;

% Falcon Heavy (Expendable)
launch_vehicle3.name = "Falcon Heavy (Expendable)";
launch_vehicle3.C3 = 0:10:100; % [km^2/s^2]
launch_vehicle3.mass = [15010, 12345, 10115, 8225, 6640, 5280, 4100, 3080, 2195, 1425, 770]; % [kg]

[tof_fhe,mass_fhe,cost_fhe] = sizing(launch_vehicle3,payload,...
    propulsion,orbit,flybys,mass0);
mass_fhe=mass_fhe.total;

% % NASA SLS
launch_vehicle4.name = "NASA SLS";
launch_vehicle4.C3 = 0:10:100; % [km^2/s^2]
launch_vehicle4.mass = [26910, 22085, 18266, 15201, 12739, 10628, 8920, 7513, 6307, 5201, 4296]; % [kg]

[tof_sls,mass_sls,cost_sls] = sizing(launch_vehicle4,payload,...
    propulsion,orbit,flybys,mass0);
mass_sls=mass_sls.total;

% % New Glenn
launch_vehicle5.name = "New Glenn";
launch_vehicle5.C3 = 0:10:40; % [km^2/s^2]
launch_vehicle5.mass = [7180, 5130, 2365, 120, 0]; % [kg]

[tof_ng,mass_ng,cost_ng] = sizing(launch_vehicle5,payload,...
    propulsion,orbit,flybys,mass0);
mass_ng=mass_ng.total;

figure(7)
plot(tof_vc,mass_vc,'o',tof_fhr,mass_fhr,'x',...
    tof_fhe,mass_fhe,'*',tof_sls,mass_sls,'+',...
    tof_ng,mass_ng,'s');
grid on;
title('Launch Vehicle Trade Study')
legend('Vulcan Centaur','Falcon Heavy Reusable',...
    'Falcon Heavy Expendable','SLS','New Glenn')
xlabel('Time to Flight [days]')
ylabel('Spacecraft Mass [kg]')
