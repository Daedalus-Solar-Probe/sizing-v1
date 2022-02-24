function payload = spacecraft_bus_sizing(payload, propPower)
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
    
    % Get sensor package power and mass
    switch payload.package
    	case "ALL"
            payload.massSensors = 97.5; % kg
            payload.powerSensors = 141.5; % W
            payload.sensorCost =  192304763.77; % USD
    	case "RM"
            payload.massSensors = 68.5; % kg
            payload.powerSensors = 102.5; % W
            payload.sensorCost =  125,860,878.82; % USD
    	case "INSITU"
            payload.massSensors = 30.5; % kg
            payload.powerSensors = 41.5; % W
            payload.sensorCost =  73,289,286.47; % USD
    	case "DEM"
            payload.massSensors = 36.5; % kg
            payload.powerSensors = 51.5; % W
            payload.sensorCost =  65,939,968.38; % USD
    	otherwise
            fprintf("No such sensor package");
    end

    %Specific power of spacecraft solar panels (w/kg)
    SolarPanel_specific_power = 150;

    %Input argument for power source (only considering solar panels for now)
    powersource_specific_power = SolarPanel_specific_power;

    %% Mass
    
    % Power mass
    payload.totalPowerReq = payload.powerSensors + propPower;
    payload.massPower = (payload.totalPowerReq) / powersource_specific_power;

    % Bus Mass (kg) [Based upon Michael's estimate equation]
    payload.busMass = (payload.massSensors + payload.massPower)/15*100;

    % Total mass
    payload.totalMass = payload.busMass + payload.massPower + payload.massSensors;

    %% Cost
    
    % Bus Cost
    c_bus = 1.28*(2.835*1000*payload.totalMass^0.716);
    
    % Structure/Thermal Cost
    m_struc = 0;
    c_struc = 1.28*1000*646*(m_struc)^.684;SSE_struc = .22;
    c_struc = c_struc*(1 + 0.524*SSE_struc); % 70% certainty
    
    % ADCS Cost
    m_adcs = 0;
    c_adcs = 1.28*1000*324*(m_adcs);SSE_adcs = .44;
    c_adcs = c_adcs*(1 + 0.524*SSE_adcs); % 70% certainty

    % EPS Cost
    m_eps = payload.massPower;
    c_eps = 1.28*1000*64.3*(m_eps);SSE_eps = .41;
    c_eps = c_eps*(1 + 0.524*SSE_eps); % 70% certainty

    % RCS Cost
    vol_rcsTank = 0; % tank volume cc
    c_rcs = 1.28*1000*20*(vol_rcsTank)^.485;SSE_rcs = .35;
    c_rcs = c_rcs*(1 + 0.524*SSE_rcs); % 70% certainty

    % TTC Cost
    c_ttc = 1.28*1000*26916;
    
    % Bus + Cost Integration
    c_int = 1.28*0.195*(c_bus+payload.sensorCost);SSE_int = 0.4;
    c_int = c_int*(1 + 0.524*SSE_int);

    % PlaceholderCosts
    m_comm = 0;
    num_channels = 0;
    c_comms = 1.28*1000*(339*(m_comm)+5127*(num_channels));
    c_elec = 1.28*1000*64.3*payload.totalMass;

    payload.totalCost = payload.sensorCost + c_bus + c_struc + c_adcs + c_eps + c_rcs + c_ttc + c_int + c_comms + c_elec;

end
