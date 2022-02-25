function [m_bus, cost] = spacecraft_bus_sizing(payload,P_prop)

% payload sensors
m_sensors = sum(payload.mass); % [kg]
P_sensors = sum(payload.power); % [W]
c_sensors = sum(payload.cost); % [USD]

% solar panel specific power
Hsun = 6.33e7; % radiant solar intensity at the sun’s surface [W/m^2]
Rsun = 6.95700e8; % radius of sun [m]
D = 0.5*1.496e11; % spacecraft radius to sun [m] (placeholder of 0.5 AU, maybe pass in final radius??)
Ho = (Rsun/D)^2 * Hsun; % radiant solar intensity at spacecraft [W/m^2]
rho_SP = 2.06; % Spectrolab Space Panels for 6mm thick coverglass [kg/m^2]
spec_power = Ho/rho_SP; % [W/kg]

% mass of power generation
m_power = (P_sensors + P_prop)/spec_power; % [kg]

% mass of bus (Based on Table 14-18 SMAD)
% See Mass / Costs Doc in Structures
m_bus = (1/(1-51/87))*(m_sensors + m_power); % [kg]

% Structure/Thermal Cost (FY22 $Millions)
m_struc = (25/87)*m_bus; % Table 14-18 SMAD relative to bus mass
c_struc = 1.28*1000*646*(m_struc)^.684;SSE_struc = .22;
c_struc_70 = c_struc*(1 + 0.524*SSE_struc); % 70% certainty

% ADCS Cost (FY22 $Millions)
m_adcs = (6/87)*m_bus; % Table 14-18 SMAD relative to bus mass
c_adcs = 1.28*1000*324*(m_adcs);SSE_adcs = .44;
c_adcs_70 = c_adcs*(1 + 0.524*SSE_adcs); % 70% certainty

% EPS Cost (FY22 $Millions)
m_eps = m_power;
c_eps = 1.28*1000*64.3*(m_eps);SSE_eps = .41;
c_eps_70 = c_eps*(1 + 0.524*SSE_eps); % 70% certainty

% RCS Cost (FY22 $Millions)
% Based on ESA Ulysses Spacecraft
% Link: https://www.cosmos.esa.int/web/ulysses/rcs#:~:text=The%20total%20volume%20of%20the,20%20%C2%B0C%20at%20launch.
vol_rcsTank = 44.66*1000; % tank volume cm^3
c_rcs = 1.28*1000*20*(vol_rcsTank)^.485;SSE_rcs = .35;
c_rcs_70 = c_rcs*(1 + 0.524*SSE_rcs); % 70% certainty

% TTC Cost (FY22 $Millions)
c_ttc = 1.28*1000*26916;

% Bus Cost (FY22 $Millions)
% See Mass / Costs Doc in Structures
c_bus = c_struc_70 + c_adcs_70 + c_eps_70 + c_rcs_70 + c_ttc;

% Bus + Cost Integration (FY22 $Millions)
c_int = 1.28*0.195*(c_bus+c_sensors);SSE_int = 0.4;       % is this correct?
c_int_70 = c_int*(1 + 0.524*SSE_int); % 70% certainty

% Communication and Electronics Costs (FY22 $Millions)
m_comm = (7/87)*m_bus; % Table 14-18 SMAD relative to bus mass
num_channels = 2; % assumption
c_comms = 1.28*1000*(339*(m_comm)+5127*(num_channels));
c_elec = 1.28*1000*64.3*m_bus;

% Total Cost (FY22 $Millions)
cost = c_sensors + c_bus + c_int_70 + c_comms + c_elec;

end % function