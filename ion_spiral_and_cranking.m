function [min_tof, dV] = ion_spiral_and_cranking(propulsion, flybys, orbit)
    propulsion.type = "Ion";

    intermediate_r = linspace(orbit.perihelion, flybys.a, 10001);
    TOF_list = zeros(1,length(intermediate_r));
    dV_list = zeros(1,length(intermediate_r));
    
    initial_orbit.perihelion = flybys.a;

    for i = 1:length(intermediate_r)
        int_orbit.perihelion = intermediate_r(i);
        int_orbit.inclination = orbit.inclination;

        [tof,dV] = spiraling(propulsion, initial_orbit, int_orbit);
        TOF_list(i) = tof;
        dV_list(i) = dV;

        [tof,dV] = cranking(propulsion, int_orbit);
        TOF_list(i) = TOF_list(i) + tof;
        dV_list(i) = dV_list(i) + dV;

        [tof,dV] = spiraling(propulsion, int_orbit, orbit);
        TOF_list(i) = TOF_list(i) + tof;
        dV_list(i) = dV_list(i) + dV;
    end

    % Compute Total 'Cost' by using weight
    % Choose min TOF trajectory as reference
    [min_tof, index] = min(TOF_list);
    cost = TOF_list / TOF_list(index) * 0.6 + dV_list / dV_list(index) * 0.4;

    % find TOF and dV for min-cost trajectory
    [min_cost, index] = min(cost);
    min_tof = TOF_list(index);
    dV = dV_list(index);
 end