function propSys = createPropulsionSys(propSys)
    % Calculate propulsion system dry mass
    propSys.massInert = calculatePropMass(propSys);
    % Get propulsion system Isp
    propSys.Isp = calculatePropIsp(propSys);
    % Get propulsion system power requirement
    propSys.power = calculatePropPower(propSys);
    return
end

% Calculate inert (dry mass) of propulsion system
% Solar sail uses thickness, area, and material density of LightSail 2
% Other systems use reference designs
function minert = calculatePropMass(propSys)
    switch propSys.type
        case "Chemical"
            % Juno main engine, LEROS 1b
            % https://en.wikipedia.org/wiki/LEROS
            % https://www.nammo.com/product/nammo-space-leros-1b-apogee-engine/
            minert = 4.5; % kg
        case "Solar Sail"
            % https://www.planetary.org/articles/what-is-solar-sailing
            A = 32; % m^2, LightSail 2 area
            z = 4.5E-6; % m^2, LS2 thickness
            rho = 1380; % kg/m3, LS2 density (mylar)
            minert = A*z*rho; % kg, only includes sail not supporting structure
        case "Ion"
            % https://www.sciencedirect.com/topics/engineering/ion-engines
            % https://en.m.wikipedia.org/wiki/Dawn_(spacecraft)
            minert = 8.3; % kg, NSTAR ion engine (Dawn probe)
        case "Nuclear"
            % https://www.osti.gov/includes/opennet/includes/Understanding%20the%20Atom/SNAP%20Nuclear%20Space%20Reactors.pdf
            minert = 854; % kg, SNAP10A
        otherwise
            fprintf("No such propulsion type");
    end
    return
end

% Link propulsion system type to its Isp
% All values taken from Rocket Propulsion Elements table 2-1
function Isp = calculatePropIsp(propSys)
    switch propSys.type
        case "Chemical"
            % Juno main engine, LEROS 1b
            % https://en.wikipedia.org/wiki/LEROS
            % https://www.nammo.com/product/nammo-space-leros-1b-apogee-engine/
            Isp = 317;
        case "Solar Sail"
            % https://www.planetary.org/articles/what-is-solar-sailing
            Isp = 'inf';
        case "Ion"
            % Dawn Spacecraft Ion Engine
            % https://en.m.wikipedia.org/wiki/Dawn_(spacecraft)
            Isp = 3100;
        case "Nuclear"
            % https://www.osti.gov/includes/opennet/includes/Understanding%20the%20Atom/SNAP%20Nuclear%20Space%20Reactors.pdf
            Isp = 850;
        otherwise
            fprintf("No such propulsion type");
    end
    return
end

% Link propulsion system type to its Isp
% All values taken from Rocket Propulsion Elements table 2-1
function power = calculatePropPower(propSys)
    switch propSys.type
        case "Chemical"
            % Pumps require power but more research necessary
            power = 0;
        case "Solar Sail"
            power = 0;
        case "Ion"
            % https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.465.718&rep=rep1&type=pdf
            power = 2567; % Watts
        case "Nuclear"
            % No clue where to find this
            power = 0;
        otherwise
            fprintf("No such propulsion type");
    end
    return
end