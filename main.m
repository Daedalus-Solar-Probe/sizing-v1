%% Clear Workspace

clear
close all
%clc

%% Load folders

addpath propulsion_sizing
addpath spacecraft_bus_sizing
addpath trajectory_analysis

%% Inputs

% launch vehicle
launcher.type = "Falcon Heavy Expendable"; 
    %Options are: "New Glenn", "NASA SLS", "Falcon Heavy Recovery", "Falcon Heavy Expendable", "Vulcan Centaur"

% payload (all)
payload.package = "ALL";

% propulsion
propulsion.type = "Ion";

% final orbit
orbit.perihelion = 7.181e7; % [km]
orbit.inclination = deg2rad(65); % [rad]

% flyby planet
flybys.planet = "Venus";

%% Calcs

% Get propulsion system values
propulsion = createPropulsionSys(propulsion);

% Get payload sizing
payload = spacecraft_bus_sizing(payload, propulsion.power);

%% Iterative Process

% Initialize spacecraft struct (for storing final values)
spacecraft.name = "Daedalus";

% Guess fuel mass
propulsion.fuelMass = 1000;

fuelMassConverged = false;
iteration = 1;
if propulsion.type == "Solar Sail"
    fprintf("Calculating fuel mass not necessary, type solar sail\n");

    % Calculate total mass
    totalMass = payload.totalMass + propulsion.massInert;

    % Calculate C3 from total mass
    launcher.C3 = C3_function(launcher, totalMass);

    % Calculate time of flight and delta-V
    [tof, dV] = trajectory_analysis(launcher,totalMass,orbit,propulsion,flybys);

    % Get solar sail cost
    propulsion = propulsion_sizing(dV, propulsion, payload);

    spacecraft.tof = tof;
    spacecraft.dV = dV;
    spacecraft.mass = totalMass;
    spacecraft.cost = propulsion.cost + payload.totalCost;
else 
    fprintf("Starting iterative calculation for fuel mass:\n");
end
while ~fuelMassConverged && propulsion.type ~= "Solar Sail"
    % Save fuel mass guess
    fuelMassGuess = propulsion.fuelMass;

    % Calculate total mass
    totalMass = payload.totalMass + propulsion.massInert + fuelMassGuess;

    % Calculate C3 from total mass
    launcher.C3 = C3_function(launcher, totalMass);

    % Calculate time of flight and delta-V
    [tof, dV] = trajectory_analysis(launcher,totalMass,orbit,propulsion,flybys);

    % Calculate actual fuel mass
    propulsion = propulsion_sizing(dV, propulsion, payload);
    fuelMassCalculated = propulsion.fuelMass;
 
    % Calculate error percentage between calculated and guessed
    error = abs(fuelMassCalculated - fuelMassGuess) / fuelMassGuess;
    error = error * 100;
    
    % Print results of iteration to terminal
    fprintf("Iteration %i: %f kg (g), %f kg (c), error: %e\n", iteration, fuelMassGuess, fuelMassCalculated, error);
    
    % Check if error is sufficiently low
    if error < 1E-10
        fprintf("Convergence achieved after %i iterations.\n", iteration);

        % Save final values
        spacecraft.tof = tof;
        spacecraft.dV = dV;
        spacecraft.mass = totalMass;
        spacecraft.cost = propulsion.cost + payload.totalCost;

        fuelMassConverged = true;
        break
    end
    
    % Increment iteration count
    iteration = iteration + 1;
end

%% Post
fprintf("\nVESSEL INFO:\n\tPropulsion Type: %s\n\tLaunch vehicle: %s \n",propulsion.type, launcher.type)
fprintf("\nORBIT INFO:\n\t%.2f AU perigee\n\t%.1f degrees inclination\n\n",orbit.perihelion/(1.496*10^8),rad2deg(orbit.inclination))
fprintf("Spacecraft payload sensor mass: %.2f kg\n",payload.massSensors)
fprintf("Spacecraft bus mass: %.2f kg\n",payload.busMass)
fprintf("Spacecraft fuel mass: %.2f kg\n",propulsion.fuelMass)
fprintf("Spacecraft dry mass: %.2f kg\n",spacecraft.mass - propulsion.fuelMass)
fprintf("Total spacecraft mass: %.2f kg\n",spacecraft.mass)
fprintf("Expected power requirement: %.2f W\n",payload.totalPowerReq)
fprintf("It is expected to take %.1f days to reach this orbit\n",spacecraft.tof)
fprintf("It is estimated to cost %.3f Million dollars\n",spacecraft.cost/10^6)
