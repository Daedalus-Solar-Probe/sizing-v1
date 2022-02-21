function [m_bus, cost] = spacecraft_bus_sizing(payload, P_prop)
% Inputs:
%   payload - struct containing payload information
%       payload.sensors - [1x9] array for payload sensors included
%
%   P_prop - the power requirement of the propulsion system [W]
%
%
% Outputs:
%   m_bus - mass of spacecraft bus (includes payload) [kg]
%
%   cost - estimated cost of payload + spacecraft bus [USD]


% Instrument mass, power, and cost
mass_inst = 0;power_inst = 0;cost_inst = 0;
for i = 1:9
    mass_inst = mass_inst + payLibrary(1,i)*payConfig(i);
    power_inst = power_inst + payLibrary(2,i)*payConfig(i);
    cost_inst = cost_inst + payLibrary(3,i)*payCondfig(i);
end

% Additional Mass Required to power instruments (kg)
mass_power = (payload_power + additional_power) / powersource_specific_power;

% Bus Mass (kg) [Based upon Michael's estimate equation]
mass_bus = (mass_inst + mass_power)/15*100;

% Bus Price
cost_bus = 1.28*(2.835*1000*mass_bus^0.716);

% PlaceholderCosts
cost_comms = 0;

% Total mass
mass = propSysInMass + propFuelMass + mass_inst + mass_bus;

% Total cost
cost_elec = 1.28*1000*64.3*mass;
cost = propCost + cost_inst + cost_bus + cost_comms + cost_elec;



end