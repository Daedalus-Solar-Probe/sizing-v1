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

    %% Definitions
    
    % Payload Library [cor, tsi, euvi, dsi, uvs, mag, sw, epp, rpw]
    payLibrary = [10, 7, 10, 25, 15, 1.5, 10, 9, 10; % mass [kg]
        15, 14, 12, 37, 22, 2.5, 15, 9, 15; % power [watts]
        19.3, 13.7, 17.6, 41.5, 26.9, 6.8, 24.3, 17.9, 24.3]; % cost [USD FY22 Millions]

    % Total payload mass, power, and cost
    m_pay = 0;p_pay = 0;c_pay = 0;
    for i = 1:9
        m_pay = m_pay + payLibrary(1,i)*payload(i); % mass
        p_pay = p_pay + payLibrary(2,i)*payload(i); % power
        c_pay = c_pay + payLibrary(3,i)*payload(i); % cost
    end

    %Specific power of spacecraft solar panels (w/kg)
    SolarPanel_specific_power = 150;

    %Input argument for power source (only considering solar panels for now)
    powersource_specific_power = SolarPanel_specific_power;

    %% Mass
    
    % power mass
    m_power = (p_pay + P_prop) / powersource_specific_power;

    % Bus Mass (kg) [Based upon Michael's estimate equation]
    m_bus = (m_pay + m_power)/15*100;

    %% Cost
    
    % Bus Cost
    c_bus = 1.28*(2.835*1000*m_bus^0.716);
    
    % Structure/Thermal Cost
    m_struc = 0;
    c_struc = 1.28*1000*646*(m_struc)^.684;SSE_struc = .22;
    c_struc = c_struc*(1 + 0.524*SSE_struc); % 70% certainty
    
    % ADCS Cost
    m_adcs = 0;
    c_adcs = 1.28*1000*324*(m_adcs);SSE_adcs = .44;
    c_adcs = c_adcs*(1 + 0.524*SSE_adcs); % 70% certainty

    % EPS Cost
    m_eps = m_power;
    c_eps = 1.28*1000*64.3*(m_eps);SSE_eps = .41;
    c_eps = c_eps*(1 + 0.524*SSE_eps); % 70% certainty

    % RCS Cost
    vol_rcsTank = 0; % tank volume cc
    c_rcs = 1.28*1000*20*(vol_rcsTank)^.485;SSE_rcs = .35;
    c_rcs = c_rcs*(1 + 0.524*SSE_rcs); % 70% certainty

    % TTC Cost
    c_ttc = 1.28*1000*26916;
    
    % Bus + Cost Integration
    c_int = 1.28*0.195*(c_bus+c_pay);SSE_int = 0.4;
    c_int = c_int*(1 + 0.524*SSE_int);

    % PlaceholderCosts
    m_comm = 0;
    num_channels = 0;
    c_comms = 1.28*1000*(339*(m_comm)+5127*(num_channels));
    c_elec = 1.28*1000*64.3*m_bus;

    cost = c_pay + c_bus + c_struc + c_adcs + c_eps + c_rcs + c_ttc + c_int + c_comms + c_elec;

end