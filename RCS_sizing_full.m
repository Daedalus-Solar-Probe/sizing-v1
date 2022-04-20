% function RCS_sizing()

%% RCS Sizing

clear;
close all;

%% Desaturation Requirements

% From Reaction wheel sizing
ang_moment_max = 0.03061;
torque_disturb = 0.0000168;

% Estimates based off SMAD
moment_arm = 0.5;
burn_time = 1;

% Desaturation Requirements
force_desat = ang_moment_max / (moment_arm * burn_time);
time = ang_moment_max / torque_disturb;

%% Bus Propellant Calculations

% MR-401 0.09 N (0.02 lbf) Rocket Engine Assembly
density_prop = 1021; % for Hydrazine
force_thrust = 0.09;
grav = 9.81;
spec_impulse = 196;
moment_arm_bus = 0.5;
moment_arm_sail = 35.7;

time_total = ang_moment_max / (force_thrust * moment_arm);
mass_prop_burn = force_desat * time_total / (grav * spec_impulse);
    
time_use_to_deploy = (2462570.6250004 - 2462418.0000004) * 86400;
mass_prop_total_to_deploy = mass_prop_burn * time_use_to_deploy / time;
volume_prop_total_to_deploy = 1.05 * mass_prop_total_to_deploy / density_prop;

time_use_full = (2467616 - 2462418.0000004) * 86400;
mass_prop_total_full = mass_prop_burn * time_use_full / time;
volume_prop_total_full = 1.05 * mass_prop_total_full / density_prop;

%% Spin Up/Solar Sail Deployment

area_sail = 5000;
length_sail = sqrt(area_sail + 10 ^ 2);
density_sail = 0.007;
center_gap = 10;
mass_sail_boom = 35;
mass_deploy = 15;
mass_bus = 200;

I_zz = (1 / 12) * (density_sail * length_sail ^ 2) * (length_sail) ^ 2 - (1 / 12) * (density_sail * center_gap ^ 2) * (center_gap) ^ 2;
I_xx = 0.5 * I_zz;
I_yy = 0.5 * I_zz;

ang_vel_deploy = 2 * pi / 60;
ang_moment_deploy = I_zz * ang_vel_deploy;
mass_prop_deploy = ang_moment_deploy / (1.75 * grav * spec_impulse);

%% Total

mass_prop_to_deploy = mass_prop_deploy + mass_prop_total_to_deploy;
mass_prop_full = mass_prop_deploy + mass_prop_total_full;
% end