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
end