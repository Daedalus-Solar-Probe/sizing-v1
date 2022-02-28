function [tof,mass,cost] = sizing(launch_vehicle,payload,propulsion,orbit,flybys,mass0)

% setup masses
mass = mass0;

% ensure it runs at least once
mass0.total = inf;
mass0.payload = inf;

% convergence tolerance
epsilon = 1e-3;

while abs(mass.total-mass0.total) > epsilon || abs(mass.payload-mass0.payload) > epsilon

    % trajectory analysis
    [dV, tof] = trajectory(launch_vehicle,flybys,propulsion,orbit,mass);
    
    % propulsion sizing
    [P_prop, m_prop, c_prop] = propulsion_sizing(dV, propulsion, mass);
    
    % spacecraft bus sizing
    [m_payload, c_bus] = spacecraft_bus_sizing(payload,P_prop,orbit);
    
    % total cost + 15% mission operational cost
    cost = 1.15*(c_prop + c_bus); % [USD]
    
    % set old mass
    mass0 = mass;

    % set new mass
    mass.total = m_prop + m_payload; % [kg]
    mass.payload = m_payload; % [kg]


end % for

end % function