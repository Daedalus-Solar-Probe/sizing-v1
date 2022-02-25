function [P_prop, m_propsys, cost] = propulsion_sizing(dV, propulsion, mass)

% constants
mu = 132712440018; % [km^3/s^2] % solar standard gravitational parameter
g0 = 9.81; % [m/s^2] standard gravity
AU = 1.496e+8; % [km] % AU in km

% solar sail case
if propulsion.type == "Solar Sail"
    
    % lightness factor (design input)
    beta = propulsion.beta; % [-]
    
    % payload mass (everything minus the solar sail)
    m_payload = mass.payload; % [kg]
    
    % sail material area density
    rho_material = propulsion.rho_material; % [kg/m^2]
    
    % spar material linear density
    lambda_spars = propulsion.rho_material; % [kg/m]

    % local solar gravity at 1 AU
    a_g = mu/AU^2*1000; % [m/s^2]

    % solar pressure at 1 AU
    P = 9.08e-06; % [N/m^2]

    % lmao this is a monster of an equation...
    S_sail = (a_g^2*beta^2*m_payload^2)/((a_g*beta*(2*a_g*beta*lambda_spars^2 ...
        + 2*P*m_payload - a_g*m_payload*rho_material*beta))^(1/2) ...
        - 2^(1/2)*a_g*beta*lambda_spars)^2; % [m^2]

    % effective density of sail (includes spars)
    rho_sail = rho_material + 2*lambda_spars*sqrt(2/S_sail); % [kg/m^2]

    % mass of sail
    m_propsys = S_sail*rho_sail; % [kg]

    % power requred for sail
    P_prop = 0; % [W]

    % Ethan's attempts at cost estimation:
    % using analogous cost estimation suggested from cost est. lecture
    % https://ntrs.nasa.gov/api/citations/20120015033/downloads/20120015033.pdf
    % slide 13: area = 85m*85m = 7225m^2
    % final slide: gives $35M FY2011 cost for development+fabrication
    %             ->$43961098 FY2022 cost
    % fairly crude model: cost=43961098*(S_sail/7225 m^2)
    cost = 43961098*(S_sail/7225); % [USD]
    
    % possibly better cost model? 
    % crude attempt to include development and deployment costs
    % https://pure.tudelft.nl/ws/portalfiles/portal/87293343/6.2021_1260.pdf
    % gives that ASC3 membrane is 2 micrometer of PEN = 0.002 mm thick
    % and covered with 100nm = 1e-7 m thick evaporated aluminum
    % and has 15nm=1.5e-8m thick chromium layer
    %
    % https://www.sigmaaldrich.com/US/en/product/aldrich/gf23662043
    % gives 0.0013~0.002mm thick PEN at $223/(150mm*150mm) sheet
    % ->0.15m*0.15m=0.0225m^2
    % so PEN cost would be $223/0.0225 m^2 = $9911.11/m^2
    % cost_PEN=9911.11*S_sail; in USD
    %
    % approx. volume of aluminum needed would be volume=area*thickness
    %  ->vol_al(m^3)=S_sail*(1e-7 m)
    % https://markets.businessinsider.com/commodities/aluminum-price
    % gives $3.30/kg for aluminum as of 2/24
    % Al density=2.7 g/cm^3=2700 kg/m^3
    %  ->mass_al(kg)=(2700 kg/m^3)*vol_al
    %  ->cost_al(USD)=mass_al*($3.30/kg)
    % mass_al = 2700*vol_al; %in kg
    % cost_al = mass_al*3.30; %in usd
    %
    %
    % approx. volume of chromium needed would be volume=area*thickness
    %  ->vol_Cr(m^3)=S_sail*(1.5e-8 m)
    % https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/media/files/mis-202112-chrom.pdf
    % gives $5.65/lb=$12.46/kg as of Dec. 2021
    % Cr density=7.19 g/cm^3=7190 kg/m^3
    %  ->mass_Cr(kg)=(7190 kg/m^3)*vol_Cr
    %  ->cost_Cr(USD)=mass_Cr*($12.46/kg)
    % mass_Cr = 7190*vol_Cr; %in kg
    % cost_Cr = mass_al*12.46; %in usd
    %
    % sail_cost=cost_PEN+cost_al+cost_Cr; (USD), sail only
    % 
    % assuming boom and deployment will be approx 50% of total unit cost
    % (not sure if this is valid assumption but haven't been able to to 
    % quantize deployment and boom costs):
    % sail_cost=2*cost_PEN+cost_al+cost_Cr;
    %
    % from https://ntrs.nasa.gov/api/citations/20120015033/downloads/20120015033.pdf
    % DDT&E given at 10/25 of flight unit cost = 40% of total cost goes to
    % development:
    % cost=1.4*sail_cost; %40% extra for DDT&E

% ion engine case
elseif propulsion.type == "Ion"

    % spacecraft mass (everything except launch vehicle)
    m_spacecraft = mass.total; % [kg]

    % payload mass (spacecraft mass minus propulsion and propellant)
    m_payload = mass.payload; % [kg]

    % required nominal acceleration
    accel = propulsion.accel*1000; % [m/s^2]

    % required thrust estimate
    F_total = m_spacecraft*accel; % [N]

    % thrust per ion engine
    F_engine = propulsion.thrust; % [N/engine]

    % power per ion engine
    P_engine = propulsion.power; % [W/engine]

    % maximum Isp for ion engine
    Isp = propulsion.Isp; % [s]

    % mass per ion engine
    m_engine = propulsion.mass; % [kg/engine]

    % number of engines required
    N_engines = ceil(F_total/F_engine); % [engines]

    % total inert propulsion mass
    m_inert = m_engine*N_engines; % [kg]

    % total propulsion power
    P_prop = P_engine*N_engines; % [W]

    % propellant mass
    m_prop = exp(dV/g0/Isp)*(m_payload + m_inert)-m_payload-m_inert; % [kg]

    % propulsion system mass
    m_propsys = m_prop + m_inert; % [kg]

    %%%%% Need Help! %%%%%

    % cost per engine
    cost_engine = propulsion.cost; % [USD/engine]

    % cost of xenon
    % https://www.dla.mil/Portals/104/Documents/Energy/Standard%20Prices/Aerospace%20Prices/E_2022Feb1AerospaceStandardPrices_220202.pdf?ver=Vpk1UcDGxl9qd5ne0o33Ag%3d%3d
    % $20.85 / liter
    % https://en.wikipedia.org/wiki/Xenon
    % "Equivalent costs per kilogram of xenon are calculated by multiplying cost per liter by 174."
    cost_xenon = 20.85*174; % [USD/kg] ~3600$/kg


    % cost of ion system
    cost = cost_engine*N_engines + m_prop*cost_xenon; % [USD]

elseif propulsion.type == "Chemical"

    % payload mass (spacecraft mass minus propulsion and propellant)
    m_payload = mass.payload; % [kg]

    %  Isp of engine
    Isp = propulsion.Isp; % [s]

    % mass of engine
    m_engine = propulsion.mass; % [kg]

    % propellant mass
    m_prop = exp(dV/g0/Isp)*(m_payload + m_engine)-m_payload-m_engine; % [kg]

    % propulsion system mass
    m_propsys = m_prop + m_engine; % [kg]

    % cost of propulsion system
    cost = propulsion.cost; % [USD]

else

    error("Unsupported Propulsion type!")

end % if/elseif


end % function
