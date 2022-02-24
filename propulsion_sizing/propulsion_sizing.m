function propulsion = propulsion_sizing(dV, propulsion, payload)
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

    % Calculate fuel mass from ideal rocket equation
    propulsion.fuelMass = calculateFuelMass(propulsion, dV, payload);

    % Get propulsion system cost
    propulsion.cost = calculatePropCost(propulsion)

    return
end

function massFuel = calculateFuelMass(propSys, dV, payload)
    % Calculate fuel mass using deltaV eqn
    % dV=g*Isp*exp(minitial/mfinal)
    % minitial = minert + mpay + mfuel
    % mfinal = minitial - mfuel
    % Payload mass is sensor suite and bus mass
    % Inert mass is only engine dry mass
    % Isp is assumed using reference engine designs

    % If solar sail, no fuel mass
    if propSys.type == "Solar Sail"
        massFuel = 0;
    else
        % Calculate fuel mass
        g = 9.81; % m/s^2
        mpay = payload.totalMass;
        minert = propSys.massInert;
        Isp = propSys.Isp;
        dV = dV * 1000; % km/s -> m/s
        massFuel = exp(dV/g/Isp)*(minert + mpay) - minert - mpay; % kg
    end
end

function cost = calculatePropCost(propSys)
    % Link propulsion system type to its cost
    % All values taken from Morphological Matrix

    switch propSys.type
        case "Chemical"
            cost = 99092700; %Engine cost estimate
            % Hypergolic fuel cost, $/kg
            cost_fuel = 150; % MMH
            cost_ox = 150; % Nitrogen Tetroxide
            r = 0.8; % Mixture ratio, Leros 1b
            % https://www.dla.mil/Energy/Business/Standard-Prices/

            m_ox = propSys.fuelMass / (1+r);
            m_fuel = propSys.fuelMass - m_ox;
            cost = cost + m_ox*cost_ox + m_fuel*cost_fuel;
        case "Solar Sail"
            cost = 19944225;
        case "Ion"
            cost = 15000000;
            cost_xenon = 850; % $/kg
            cost = cost + propSys.fuelMass*cost_xenon;
        case "Nuclear"
            cost = 150645600;
            cost_H2 = 3; % Liq Hydrogen, $/kg
            cost = cost + propSys.fuelMass*cost_H2;
        otherwise
            error("No such propulsion type");
    end
end
