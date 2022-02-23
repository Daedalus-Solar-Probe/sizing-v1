function [mass,time_to_orbit,cost] = sizing_v1(launcher,payload,propulsion,orbit,flybys)

% initial mass estimates
m_total = 1000; % [kg]
m_pay = 500; % [kg]

% launch vehicle C3 analysis
C3 = C3_function(launcher,m_total); % [km^2/s^2]
launcher.C3 = C3;

% trajectory analysis
[time_to_orbit,dV] = ...
    trajectory_analysis(launcher,m_total,orbit,propulsion,flybys);

% propulsion sizing
[P_prop, m_prop, cost_prop] = propulsion_sizing(dV, propulsion, m_pay);

% spacecraft bus sizing
[m_bus, cost_bus] = spacecraft_bus_sizing(payload, P_prop);

% new mass
mass = m_prop + m_bus;

% computed cost
cost = cost_prop + cost_bus;


% end