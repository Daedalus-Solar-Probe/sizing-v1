%% Calculating Torques using Tracjetory Data
data = csvread(['Trajectory.csv'],1);

%radial velocity x,y,z in AU/day
radVelx = data(:,5);
radVely = data(:,6);
radVelz = data(:,7);

radVel = (radVelx.^2+radVely.^2+radVelz.^2).^(1/2);

%radius x,y,z in AU
radius_x = data(:,2);
radius_y = data(:,3);
radius_z = data(:,4);

radius = (radius_x.^2+radius_y.^2+radius_z.^2).^(1/2);

angVel = radVel./radius; %1/day

length = size(data);
n = length(1);

time = data(:,1);

for i = 1:n-1
    change_angVel(i) = (angVel(i+1)-angVel(i));
    change_time(i) = time(i+1)-time(i);
    angAccel(i) = change_angVel(i)/change_time(i); %1/day^2
end

%calculating moment of inertia
M = 526; %kg
r = sqrt(6000); %m
I = 0.5*M*r^2;

Torq = I.*angAccel;

