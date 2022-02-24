function [m_bus, cost] = spacecraft_bus_sizing(payload,P_prop)

% payload sensors
m_sensors = sum(payload.mass); % [kg]
P_sensors = sum(payload.power); % [W]
c_sensors = sum(payload.cost); % [USD]

% solar panel specific power
spec_power = 150; % [W/kg]      at what distance to sun?? 1 AU???

% mass of power generation
m_power = (P_sensors + P_prop)/spec_power; % [kg]

% mass of bus
m_bus = m_sensors + m_power; % [kg]

%%%% What are the units of cost?? %%%%

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
c_int = 1.28*0.195*(c_bus+c_sensors);SSE_int = 0.4;       % is this correct?
c_int = c_int*(1 + 0.524*SSE_int);

% PlaceholderCosts
m_comm = 0;
num_channels = 0;
c_comms = 1.28*1000*(339*(m_comm)+5127*(num_channels));
c_elec = 1.28*1000*64.3*m_bus;

cost = c_sensors + c_bus + c_struc + c_adcs + c_eps + c_rcs + c_ttc + c_int + c_comms + c_elec;

end % function