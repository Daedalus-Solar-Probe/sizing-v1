function [mass,time_to_orbit,cost] = sizing_v1(launcher,payload,propulsion,orbit,flybys)


% initial mass guess
mass.new.total = 1000; % [kg]
mass.new.bus = 500; % [kg]

for i = 1:3

mass.prev.total = mass.new.total;
mass.prev.bus = mass.new.bus;

% launch vehicle C3 analysis
launcher.C3 = C3_function(launcher,mass.prev.total); % [km^2/s^2]

% trajectory analysis
[time_to_orbit,dV] = ...
    trajectory_analysis(launcher,mass.prev.total,orbit,propulsion,flybys);

% propulsion sizing
[P_prop, m_prop, cost_prop] = propulsion_sizing(dV, propulsion, mass.prev.bus);

% spacecraft bus sizing
[m_bus, cost_bus] = spacecraft_bus_sizing(payload, P_prop);

% new mass
mass.new.total = m_prop + m_bus;
mass.new.bus = m_bus;

% computed cost
cost = cost_prop + cost_bus;

% mass error
error = mass.prev.total - mass.new.total

end % for

end % function