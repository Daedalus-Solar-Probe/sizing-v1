function [A_RCD, P_RCD, M_RCD] = SolarSailControl(As,cg,sbm,slew_max,omega_z,P,ref)
%As: sail area
%cg: center gap
%sbm: Sail and boom mass
%dm: deployment mass
%slew_max: maximum slew rate (10 deg/day)
%omega_z angular velocity of solar sai lin z-direction (1 rpm)

l = sqrt(As+cg^2); %sail side length
rho = sbm/As; %kg
%moments of inertia
Izz = (1/12)*((rho*l^2)*(2*l^2)-(rho*cg^2)*(cg^2)); %kg*m^2
Ixx = Izz/2;
Iyy = Izz/2;

%converting inputs to correct units:
omega_z = omega_z*0.10472; %convert rpm to rad/s
slew_max = slew_max*(pi/180)*(1/86400); %convert degree/day to rad/s


H = Izz*omega_z; %angular momentum (kg*m^2/s)
Tau_max = H*slew_max; %max torque based on max slew rate

r = (30*2)+(40*2); %length of all 4 arms on one side
F_RCD = Tau_max/r; %force required per RCD

%Solar Pressure
%P = 4e-5 at 0.48AU (Pa)
%P = 1.33e-5 at 1AU (Pa), about three times more pressure at 0.48AU

%Sizing RCDs (Area, Mass, and Power)
A_RCD = (F_RCD/P)*(1/ref); %Area per RCD taking into account reflectivity
rhoa = 0.017; %areal density for RCD Technology (kg/m^2)
M_RCD = A_RCD*rhoa; %mass per RCD
rhop = 5; %power density for the RCD Technology (W/m^2)
P_RCD = A_RCD*rhop;

%multiply by 8 to get total values


