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

% Payload Library [cor, tsi, euvi, dsi, uvs, mag, sw, epp, rpw]
    payLibrary = [10, 7, 10, 25, 15, 1.5, 10, 9, 10; % mass [kg]
        15, 14, 12, 37, 22, 2.5, 15, 9, 15; % power [watts]
        19.3, 13.7, 17.6, 41.5, 26.9, 6.8, 24.3, 17.9, 24.3]; % cost [USD FY22 Millions]

    % Total instrument mass, power, and cost
    m_inst = 0;p_inst = 0;c_inst = 0;
    for i = 1:9
        m_inst = m_inst + payLibrary(1,i)*payload(i);
        p_inst = p_inst + payLibrary(2,i)*payload(i);
        c_inst = c_inst + payLibrary(3,i)*payload(i);
    end

    %Specific power of spacecraft solar panels (w/kg)
    SolarPanel_specific_power = 150;

    %Input argument for power source (only considering solar panels for now)
    powersource_specific_power = SolarPanel_specific_power;

    % Additional Mass Required to power instruments (kg)
    m_power = (p_inst + P_prop) / powersource_specific_power;

    % Bus Mass (kg) [Based upon Michael's estimate equation]
    m_bus = (m_inst + m_power)/15*100;

    % Bus Price
    c_bus = 1.28*(2.835*1000*m_bus^0.716);

    % PlaceholderCosts
    c_comms = 0;
    c_elec = 1.28*1000*64.3*m_bus;

    cost = c_inst + c_bus + c_comms + c_elec;

end