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
    
    % possibly better cost model? (this needs to be updated to reflect ACS3 materials)
    % this also does not implement cost of booms, deployment system, development costs, etc
    % https://earth.esa.int/web/eoportal/satellite-missions/i/ikaros
    % gives that IKAROS membrane is 0.0075 mm of polyimide ~ 0.0003" thick
    % and covered with 8e-5 mm thick evaporated aluminum
    % https://catalog.cshyde.com/item/films/kapton-polyimide-film-type-hn/18-1-3f-24
    % gives .0003" thick Kapton polyimide film is $28.74 per 25in x 1ft
    % ->25in x 1ft= 0.635m*0.3048m = 0.194 m^2
    % so polyimide cost would be $28.74/0.194 m^2 = $148.14/m^2
    % cost_poly=148.14*S_sail;
    % approx. volume of aluminum needed would be volume=area*thickness
    %  ->vol_al(m^3)=S_sail*(8e-8 m)
    % https://markets.businessinsider.com/commodities/aluminum-price
    % gives $3.30/kg for aluminum as of 2/24
    % Al density=2.7 g/cm^3=2700 kg/m^3
    %  ->mass_al(kg)=(2700 kg/m^3)*vol_al
    % cost_al(USD)=mass_al*($3.30/kg)
    % cost_al = mass_al*3.30
    % cost=cost_poly+cost_al; (USD)

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
    cost_xenon = 850; % [USD/kg]         source on this?

    % cost of ion system
    cost = cost_engine*N_engines + m_prop*cost_xenon; % [USD]

else

    error("Unsupported Propulsion type!")

end % if/elseif


end % function