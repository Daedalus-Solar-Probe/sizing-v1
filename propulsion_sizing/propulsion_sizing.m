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

    % Calculate propulsion system engine mass
    propulsion = calculateEngineMass(propulsion);
    % Get propulsion system Isp
    propulsion = calculatePropIsp(propulsion);
    % Get propulsion system power requirement
    propulsion = calculatePropPower(propulsion);
    % Calculate fuel and inert masses
    propulsion = calculateFuelMass(propulsion, dV, m_pay);
    % Get propulsion system cost
    propulsion = calculatePropCost(propulsion);
    % Calculate total propulsion mass
    propulsion.TotalMass = propulsion.m_inert + propulsion.mfuel_total + propulsion.EngineMass;
    
    P_prop = propulsion.P_prop;
    m_prop = propulsion.TotalMass;
    cost = propulsion.cost;
end

function propSys = calculateEngineMass(propSys)
    % Calculate inert (dry mass) of propulsion system
    % Solar sail uses thickness, area, and material density of LightSail 2
    % Other systems use reference designs
    switch propSys.type
        case 'Chemical'
            % Juno main engine, LEROS 1b
            % https://en.wikipedia.org/wiki/LEROS
            % https://www.nammo.com/product/nammo-space-leros-1b-apogee-engine/
            m_Engine = 4.5; % kg
            fIn=0.3;
        case 'Solar Sail'
            % https://www.planetary.org/articles/what-is-solar-sailing
            A = 32; % m^2, LightSail 2 area
            z = 4.5E-6; % m^2, LS2 thickness
            rho = 1380; % kg/m3, LS2 density (mylar)
            m_Engine = A*z*rho; % kg, only includes sail not supporting structure
            fIn=0;
        case 'Ion'
            % https://www.sciencedirect.com/topics/engineering/ion-engines
            % https://en.m.wikipedia.org/wiki/Dawn_(spacecraft)
            % m_prop = 8.3; % kg, NSTAR ion engine (Dawn probe)
            % https://www.researchgate.net/publication/237470667_NEXT_Ion_Propulsion_System_Development_Status_and_Performance
            m_Engine = 58.2; % kg, NEXT ion engine
            fIn=0.3;
        case 'Nuclear'
            % https://www.osti.gov/includes/opennet/includes/Understanding%20the%20Atom/SNAP%20Nuclear%20Space%20Reactors.pdf
            m_Engine = 854; % kg, SNAP10A
            fIn=0.3;
        otherwise
            error("No such propulsion type");
    end
    propSys.EngineMass = m_Engine;
    propSys.InertFraction = fIn; %Inert fuel fraction, m_in/(m_in+m_prop)
end

function propSys = calculatePropIsp(propSys)
    % Link propulsion system type to its Isp
    % All values taken from Rocket Propulsion Elements table 2-1
        switch propSys.type
            case 'Chemical'
                % Juno main engine, LEROS 1b
                % https://en.wikipedia.org/wiki/LEROS
                % https://www.nammo.com/product/nammo-space-leros-1b-apogee-engine/
                Isp = 317;
            case 'Solar Sail'
                % https://www.planetary.org/articles/what-is-solar-sailing
                Isp = 'inf';
            case 'Ion'
                % Dawn Spacecraft Ion Engine
                % https://en.m.wikipedia.org/wiki/Dawn_(spacecraft)
                % Isp = 3100;
                % https://www.researchgate.net/publication/237470667_NEXT_Ion_Propulsion_System_Development_Status_and_Performance
                Isp = 4190;
            case 'Nuclear'
                % https://www.osti.gov/includes/opennet/includes/Understanding%20the%20Atom/SNAP%20Nuclear%20Space%20Reactors.pdf
                Isp = 850;
            otherwise
                error("No such propulsion type");
        end
        
        propSys.Isp=Isp;
end

function propSys = calculatePropPower(propSys)
    % Link propulsion system type to its Isp
    switch propSys.type
        case 'Chemical'
            % Pumps require power but more research necessary
            power = 0;
        case 'Solar Sail'
            power = 0;
        case 'Ion'
            % https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.465.718&rep=rep1&type=pdf
            % power = 2567; % Watts
            % https://www.researchgate.net/publication/237470667_NEXT_Ion_Propulsion_System_Development_Status_and_Performance
            power = 7220; % Watts
        case 'Nuclear'
            % No clue where to find this
            power = 0;
        otherwise
            error("No such propulsion type");
    end
    propSys.P_prop = power;
end

function propSys = calculateFuelMass(propSys, dV, mpay)
    % Calculate fuel mass using deltaV eqn
    % dV=g*Isp*exp(minitial/mfinal)
    % minitial = minert + mpay + mfuel
    % mfinal = minitial - mfuel
    % Payload mass is sensor suite and bus mass
    % Inert mass is only engine dry mass
    % Isp is assumed using reference engine designs

    % If solar sail, no fuel mass
    if propSys.type == "Solar Sail"
        propSys.m_inert = 0; % kg
        propSys.mfuel_total = 0; % kg
        return
    end

    % Calculate fuel mass
    g = 9.81; % m/s^2
    mEngine = propSys.EngineMass + mpay; % kg
    fInert = propSys.InertFraction;
    Isp = propSys.Isp; % seconds
    K=exp(dV/g/Isp);
    propSys.m_inert = fInert*(K - 1)*(mEngine + mpay)/(1 - fInert*K); % kg
    propSys.mfuel_total = (1 - fInert)*(K - 1)*(mEngine + mpay)/(1 - fInert*K); % kg
end

function propSys = calculatePropCost(propSys)
    % Link propulsion system type to its cost
    % All values taken from Morphological Matrix

    switch propSys.type
        case 'Chemical'
            cost = 99092700; %Engine cost estimate
            % Hypergolic fuel cost, $/kg
            cost_fuel = 150; % MMH
            cost_ox = 150; % Nitrogen Tetroxide
            r = 0.8; % Mixture ratio, Leros 1b
            % https://www.dla.mil/Energy/Business/Standard-Prices/

            m_ox = propSys.mfuel_total / (1+r);
            m_fuel = propSys.mfuel_total - m_ox;
            cost = cost + m_ox*cost_ox + m_fuel*cost_fuel;
        case 'Solar Sail'
            cost = 19944225;
        case 'Ion'
            cost = 15000000;
            cost_xenon = 850; % $/kg
            cost = cost + propSys.mfuel_total*cost_xenon;
        case 'Nuclear'
            cost = 150645600;
            cost_H2 = 3; % Liq Hydrogen, $/kg
            cost = cost + propSys.mfuel_total*cost_H2
        otherwise
            error("No such propulsion type");
    end
    propSys.cost=cost;
end