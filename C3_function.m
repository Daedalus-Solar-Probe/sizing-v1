function [C3_output] = C3_function(Launch_Vehicle,pay_mass)

%input mass in kg
C3 = [0:10:100]; %km^2/s^2

if Launch_Vehicle == "Vulcan Centaur"
    m = [10850, 9130, 7630, 6310, 5150, 4120, 3250, 2420, 1780, 1370, 755]; %kg
elseif Launch_Vehicle == "Falcon Heavy Expendable"
    m = [15010, 12345, 10115, 8225, 6640, 5280, 4100, 3080, 2195, 1425, 770]; %kg
elseif Launch_Vehicle == "Falcon Heavy Recovery"
    m = [6690, 4930, 3845, 2740, 1805, 1005, 320, 0, -1, -2, -3]; %kg
elseif Launch_Vehicle == "NASA SLS"
    m = [26910, 22085, 18266, 15201, 12739, 10628, 8920, 7513, 6307, 5201, 4296]; %kg
elseif Launch_Vehicle == "New Glenn"
    m = [7180, 5130, 2365, 120, 0, -1, -2, -3, -4, -5, -6]; %kg
end

C3_output = interp1(m,C3,pay_mass); %km^2/s^2