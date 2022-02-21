function [P_prop, m_prop, cost] = propulsion_sizing(dV, propulsion, m_pay)
% Inputs:
%   dV - delta-V required for propulsion [km/s]
%
%   propulsion - struct containing propulsion information
%       propulsion.type - string for the name, e.g. "Solar Sail"
%
%   m_pay - estimate for the mass of the spacecraft bus + payload [kg]
%
%
% Outputs:
%   P_prop - Power requirement of the propulsion system [W]
%
%   m_prop - Propellant + inert mass for propulsion system [kg]
%
%   cost - Cost estimate of propulsion system [USD]

% Calculate propulsion system dry mass
propulsion.inert = calculatePropMass(propulsion);
% Get propulsion system Isp
propulsion.Isp = calculatePropIsp(propulsion);
% Get propulsion system cost
cost = calculatePropCost(propulsion);
% Get propulsion system power requirement
P_prop = calculatePropPower(propulsion);
% Calculate fuel mass
m_fuel = calculateFuelMass(propulsion, dV, m_pay);
% Calculate total propulsion mass
m_prop = propulsion.inert + m_fuel;

% Calculate fuel mass using deltaV eqn
% dV=g*Isp*exp(minitial/mfinal)
% minitial = minert + mpay + mfuel
% mfinal = minitial - mfuel
% Payload mass is sensor suite and bus mass
% Inert mass is only engine dry mass
% Isp is assumed using reference engine designs
function m_fuel = calculateFuelMass(propSys, dV, mpay)
    % If solar sail, no fuel mass
    if propSys.type == "solarsail"
        m_fuel = 0;
        return
    end
    
    % Calculate fuel mass
    g = 9.81; % m/s^2
    minert = propSys.inert; % kg
    Isp = propSys.Isp; % seconds
    m_fuel = exp(dV/g/Isp)*(minert + mpay) - minert - mpay; % kg
end
% Calculate inert (dry mass) of propulsion system
% Solar sail uses thickness, area, and material density of LightSail 2
% Other systems use reference designs
function m_prop = calculatePropMass(propSys)
    switch propSys.type
        case 'chemical'
            % Juno main engine, LEROS 1b
            % https://en.wikipedia.org/wiki/LEROS
            % https://www.nammo.com/product/nammo-space-leros-1b-apogee-engine/
            m_prop = 4.5; % kg
        case 'solarsail'
            % https://www.planetary.org/articles/what-is-solar-sailing
            A = 32; % m^2, LightSail 2 area
            z = 4.5E-6; % m^2, LS2 thickness
            rho = 1380; % kg/m3, LS2 density (mylar)
            m_prop = A*z*rho; % kg, only includes sail not supporting structure
        case 'ion'
            % NSTAR ion engine
%             % https://www.sciencedirect.com/topics/engineering/ion-engines
%             % https://en.m.wikipedia.org/wiki/Dawn_(spacecraft)
%             m_prop = 8.3; % kg, NSTAR ion engine (Dawn probe)
            % https://www.researchgate.net/publication/237470667_NEXT_Ion_Propulsion_System_Development_Status_and_Performance
            m_prop = 58.2; % kg, NEXT ion engine
        case 'nuclear'
            % https://www.osti.gov/includes/opennet/includes/Understanding%20the%20Atom/SNAP%20Nuclear%20Space%20Reactors.pdf
            m_prop = 854; % kg, SNAP10A
        otherwise
            fprintf("No such propulsion type");
    end
    return
end

% Link propulsion system type to its Isp
% All values taken from Rocket Propulsion Elements table 2-1
function Isp = calculatePropIsp(propSys)
    switch propSys.type
        case 'chemical'
            % Juno main engine, LEROS 1b
            % https://en.wikipedia.org/wiki/LEROS
            % https://www.nammo.com/product/nammo-space-leros-1b-apogee-engine/
            Isp = 317;
        case 'solarsail'
            % https://www.planetary.org/articles/what-is-solar-sailing
            Isp = 'inf';
        case 'ion'
%             % Dawn Spacecraft Ion Engine
%             % https://en.m.wikipedia.org/wiki/Dawn_(spacecraft)
%             Isp = 3100;
            % NEXT Ion Engine
            % https://www.researchgate.net/publication/237470667_NEXT_Ion_Propulsion_System_Development_Status_and_Performance
            Isp = 4190; % seconds
        case 'nuclear'
            % https://www.osti.gov/includes/opennet/includes/Understanding%20the%20Atom/SNAP%20Nuclear%20Space%20Reactors.pdf
            Isp = 850;
        otherwise
            fprintf("No such propulsion type");
    end
    return
end

% Link propulsion system type to its cost
% All values taken from Morphological Matrix
function cost = calculatePropCost(propSys)
    switch propSys.type
        case 'chemical'
            cost = 99092700;
        case 'solarsail'
            cost = 19944225;
        case 'ion'
            cost = 15000000;
        case 'nuclear'
            cost = 150645600;
        otherwise
            fprintf("No such propulsion type");
    end
    return
end
end

% Link propulsion system type to its Isp
function power = calculatePropPower(propSys)
    switch propSys.type
        case 'chemical'
            % Power required for the valves
            % https://www.rocket.com/sites/default/files/documents/In-Space%20Data%20Sheets_7.19.21.pdf
            power = 45; % Watts
        case 'solarsail'
            power = 0;
        case 'ion'
            % https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.465.718&rep=rep1&type=pdf
            power = 7220; % Watts
        case 'nuclear'
            % No clue where to find this
            power = 0;
        otherwise
            fprintf("No such propulsion type");
    end
    return
end
