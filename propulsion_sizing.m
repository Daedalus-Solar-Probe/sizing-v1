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
    lambda_spars = propulsion.lambda_spars; % [kg/m]

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

    % solar sail cost estimations
    %
    % using analogous cost estimation suggested from cost est. lecture
    % https://ntrs.nasa.gov/api/citations/20120015033/downloads/20120015033.pdf
    % slide 13: area = 85m*85m = 7225m^2
    % final slide: gives $35M FY2011 cost for development+fabrication
    %             ->$43961098 FY2022 cost
    % fairly crude model: cost=43961098*(S_sail/7225 m^2)
%     cost = 43961098*(S_sail/7225); % [USD]
    %
    % lightsail 2 material approximation
    % Lightsail 2 thickness(Mylar) = 4.5 micrometer=0.177 mil~0.24 mil
    % https://www.chemplex.com/xrf-sample-cup-thin-film-sample-support-windows.html
    % gives $45/(0.0762m X 91.4m) = $50/6.9647 m^2
    % =$7.18/m^2 of mylar
    % mylar density=1389 kg/m^3
    % rho_sail=1389; kg/m^3
    % cost_sail=S_sail*7.18; %m^2*7.18USD/m^2 -> [USD]
    %https://arc.aiaa.org/doi/pdf/10.2514/6.2017-0171#:~:text=The%20TRACTM%20Boom%20is%20a,cost%20and%20more%20compact%20packaging.
    % lightsail 2's TRAC booms cross-sec area given by
    % A=2*t*f=2*24.6mm*0.408mm=20.0736mm^2=2.00736e-5 m^2
    % A_boom=2.00736e-5; %[m^2]
    % vol=A_boom*length
    % length of diag. boom given by sqrt(2)*S_sail
    % vol_booms=2*(A_boom*sqrt(2)*S_sail)); [kg^3]
    %https://www.sciencedirect.com/science/article/pii/S027311772030449X
    % booms made from elgiloy alloy
    %https://www.metalsuppliersonline.com/buy/exchange/post/viewhresponse.asp?BidId=43619
    %gives cost at $157.77/lb=$347.338/kg
    %https://www.elgiloy.com/assets/1/6/Strip_-_Elgiloy_Alloy1.pdf
    %gives densiy of elgiloy=8600 kg/m^3
    %mass_booms=vol_booms(m^3)*8600(kg/m^3); [kg]
    %
    %assume boom deployment system cost is extra 5% onto material cost
    %
    % from https://ntrs.nasa.gov/api/citations/20120015033/downloads/20120015033.pdf
    % DDT&E given at 10/25 of flight unit cost = 40% of total cost goes to
    % development

    cost_sail=S_sail*7.18; %[USD]
    A_boom=2.00736e-5; %[m^2]
    vol_booms=2*(A_boom*sqrt(2)*S_sail); %[m^3]
    mass_booms=vol_booms*8600; %[kg]
    cost_booms=mass_booms*346.338; %[usd]
    cost_sail_mat=cost_sail+cost_booms; %total material cost
    cost=1.45*cost_sail_mat; % 40% extra for DDT&E, 5% for deployment material


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
    m_prop = exp(dV*1000/g0/Isp)*(m_payload + m_inert)-m_payload-m_inert; % [kg]

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
    m_prop = exp(dV*1000/g0/Isp)*(m_payload + m_engine)-m_payload-m_engine; % [kg]

    % propulsion system mass
    m_propsys = m_prop + m_engine; % [kg]

    % cost of propulsion system
    cost = propulsion.cost; % [USD]
    
    % power required for chemical engine
    P_eng_valve = 78; % [W], for actuation of engine valves
    P_prop =  P_eng_valve; % [W]

else

    error("Unsupported Propulsion type!")

end % if/elseif


end % function
