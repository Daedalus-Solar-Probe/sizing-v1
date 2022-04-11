%% TT+C Mass, Cost, and Power
%  Author: Sam Dzigiel

%% Function
function[Mass, Cost, Power] = TelecommsMassCostPower()
    % Mass and Power Estimates are non-parameterized. Based on SMAD
    % component level estimations for Ka and X band componentry. A margin
    % was placed for antenna weight to account for varying antenna diameter
    % (the effect is neglidgible, on the order of ~1 kg, but the margin was
    % still implemented to be safe).

    inflation = 1.3; %FY10 to FY22 Conversion Rate

    % Mass Estimation (See "Telemetry Data Rate", week 11 folder)
    Mass = 48.25; % kg

    % USCM8, SMAD Table 11-11
    Cost_recur = (189*Mass)*1000*inflation; % USD, 2022

    % USCM8, SMAD Table 11-8
    Cost_nonrecur = 29616*1000*inflation; % USD, 2022

    % Summed Cost
    Cost = Cost_recur+Cost_nonrecur;

    % Power Estimation (See "Telemetry Data Rate", week 11 folder)
    Power = 267.5; % W
end