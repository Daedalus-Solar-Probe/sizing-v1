function [tof,dV] = ...
    trajectory_analysis(launcher,m_total,orbit,propulsion,flybys)
% Inputs:
%   launcher - struct containing launch vehicle information
%       launcher.type - string for the name, e.g. "NASA SLS"
%       launcher.masses - array of possible payload mass [kg]
%       launcher.C3 - array of excess C3 for each payload mass [km^2/s^2]
%   m_total - estimated total spacecraft mass [kg]
%
%   orbit - struct containing final spacecraft orbit
%       orbit.perihelion - final orbit perihelion [km]
%       orbit.aphelion - final orbit aphilion [km]
%       orbit.inclination - final orbit inclination [deg]
%
%   propulsion - struct containing propulsion information
%       propulsion.type - string for the name, e.g. "Solar Sail"
%
%   flybys - struct containing flyby information
%       flybys.planet - string for the name, e.g. "Venus"
%
%
% Ouputs:
%   tof - time of flight (until final orbit first reached) [days]
%   dV - delta-V required for propulsion [km/s]

end