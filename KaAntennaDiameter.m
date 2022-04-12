%% TT+C Antenna Sizing
%  Author: Sam Dzigiel

%% Function
function[ka_diameter] = KaAntennaDiameter(downlink_time)
    %% Ka 

    % Basic Parameters:
    Mod_index = 1.2; % Modulation Index
    f_c = 26; %RF Frequency, GHz
    transmit_power = 50; % Transmit Power (corresponds to 100W)
    transmit_loss = -2; % Loss, db
    ground_gain = 79.5; % DSN Ground Antenna Gain
    d = 177724800; % Furthest Distance, km
    K = 175; % System Noise Temp, K
    N0 = 10*log10(1.38E-23 * 1000 * K); % System Noise density
    atmos_loss = -0.3; % Loss, db
    reciever_loss = -1; % Loss, db
    Data2P =10*log10((sin(Mod_index))^2); % Data-to-Total Power
    path_loss =10*log10((300000/(4*pi*d*f_c*10^9))^2); % Loss
    science_data_rate = 125.576; % Scientific Data Rate, kbps
    bit_rate = 24/downlink_time*science_data_rate; % Transmit data rate, kbps

    % Find diamater from downlink time and desired margin:
    Desired_margin = 3; % Desired Link Margin, db
    Required_SNR = 10.5; % Required SNR, db
    Recieved_SNR = Required_SNR+Desired_margin-reciever_loss; % Necessary Signal-to Noise for 3 db Margin
    total_recieved_power = Recieved_SNR-Data2P+N0+10*log10(bit_rate*1000); % Total Recieved Power, db
    EIRP = total_recieved_power-ground_gain-atmos_loss-path_loss; % EIRP

    transmit_gain = EIRP - transmit_loss - transmit_power; % Transmit Gain
    ka_diameter = 10^((transmit_gain-20.4-20*log10(f_c)-10*log10(0.55))/20); % Required diameter

end