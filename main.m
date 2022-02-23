%% Clear Workspace

clear
close all
clc

%% Load folders

addpath propulsion_sizing\
addpath spacecraft_bus_sizing\
addpath trajectory_analysis\

%% Inputs

% launch vehicle
launcher.type = "Falcon Heavy Expendable";

% payload (all)
payload = ones(1,9);

% propulsion
propulsion.type = "Solar Sail";
% propulsion.type = "Ion";

% final orbit
orbit.perihelion = 7.181e7; % [km]
orbit.inclination = deg2rad(65); % [rad]

% flyby planet
flybys.planet = "Venus";

%% Calcs

[mass,time_to_orbit,cost] = sizing_v1(launcher,payload,propulsion,orbit,flybys);

%% Post

mass
time_to_orbit
cost