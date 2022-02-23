%% Clear Workspace

clear
close all
%clc

%% Load folders

addpath propulsion_sizing\
addpath spacecraft_bus_sizing\
addpath trajectory_analysis\

%% Inputs

% launch vehicle
launcher.type = "Falcon Heavy Expendable"; 
    %Options are: "New Glenn", "NASA SLS", "Falcon Heavy Recovery", "Falcon Heavy Expendable", "Vulcan Centaur"

% payload (all)
payload = ones(1,9);
    
% propulsion
%propulsion.type = "Chemical";
%propulsion.type = "Nuclear";
propulsion.type = "Solar Sail";
%propulsion.type = "Ion";

% final orbit
orbit.perihelion = 7.181e7; % [km]
orbit.inclination = deg2rad(65); % [rad]

% flyby planet
flybys.planet = "Venus";

%% Calcs

[mass,time_to_orbit,cost] = sizing_v1(launcher,payload,propulsion,orbit,flybys);

%% Post

fprintf("VESSEL INFO:\n\tPropulsion Type: %s\n\tLaunch vehicle: %s \n",propulsion.type, launcher.type)
fprintf("\nORBIT INFO:\n\t%.2f AU perigee\n\t%.1f degrees inclination\n\n",orbit.perihelion/(1.496*10^8),rad2deg(orbit.inclination))
fprintf("Total payload mass: %.2f kg\n",mass)
fprintf("It is expected to take %.1f days to reach this orbit\n",time_to_orbit)
fprintf("It is estimated to cost %.3f Million dollars\n",cost/10^6)