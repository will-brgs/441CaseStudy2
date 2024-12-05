%% Efficacy Analysis: Generates Boxplot based on varied parameters and derrived input
%% Introduction
% * Authors:                  Will Burgess, Mack LaRosa
% * Class:                    ESE 441
% * Date:                     Created 12/04/2024, Last Edited 12/09/2024
%% Housekeeping
clear
clc
code = "finished";
colors = get(gca, 'ColorOrder');
blu = colors(1,:);
org = colors(2,:);
purp = colors(4,:);
grn = colors(5,:);

close all
figure
%%
% Parameters
p1Base = 0.03;     % Rate of glucose decay
p2Base = 0.02;     % Rate of insulin action decay
p3Base = 0.01;     % Insulin sensitivity
nBase = 0.1;       % Insulin clearance rate
GbBase = 100;      % Baseline glucose
IbBase = 10;       % Baseline plasma insulin

t = 0:0.1:240;

IC = [GbBase, 0, IbBase]; %should baseline insulin action be zero???

for j = 1:1 % Varies mode from auto to exercise. change to 2 later
    if j ==1
        mode = 'Auto';
        u = zeros(length(t),1);
    elseif j==2
        mode = 'Exercise';
        u = zeros(length(t),1);
    end
for i = 1:4 % Sweeps through D values, change to 4 later
if i == 1
D = DGenerate('Monophasic',t,20,0,70,20,50, 0);
disturbance = 'Monophasic Eating';
elseif i == 2
D = DGenerate('Biphasic',t,15,0,70,15,30, 0);
disturbance = 'Biphasic Eating';
elseif i == 3
D = DGenerate('Lift',t,30,0,10,15,15, 0);
disturbance = 'Weightlifting';
elseif i == 4
D = DGenerate('Run',t,30,0,5,1,50,-10);
disturbance = 'Marathon';
elseif i== 5 %debug only
D = zeros(length(t),1);
disturbance = 'No Disturbance';
end
%% Reset 
for k = 1:30 % 
Gout = zeros(length(t),30);

p1 = p1Base  * (0.85 + (0.3 * rand));     % Rate of glucose decay
p2 = p2Base  * (0.85 + (0.3 * rand));     % Rate of insulin action decay
p3 = p3Base  * (0.85 + (0.3 * rand));     % Insulin sensitivity
n = nBase   * (0.85 + (0.3 * rand));       % Insulin clearance rate
Gb = GbBase;      % Baseline glucose
Ib = IbBase;       % Baseline plasma insulin
%% simulate ODE
D_interp = @(t) interp1(0:0.1:240, D, t, 'linear', 'extrap');
u_interp = @(t) interp1(0:0.1:240, u, t, 'linear', 'extrap');

% dynamics = @(t, y) [
%             -p1 * (y(1) - Gb) - y(2) * y(1) + D(round(t / 0.1) + 1);
%             -p2 * y(2) + p3 * (y(3) - Ib);
%             -n * y(3) + u(round(t / 0.1) + 1)];

dynamics = @(t, y) [
    -p1 * (y(1) - Gb) - y(2) * y(1) + D_interp(t);
    -p2 * y(2) + p3 * (y(3) - Ib);
    -n * y(3) + u_interp(t)];

[t, y] = ode45(dynamics, t, IC);

% Extract states
G = y(:, 1);  % Blood glucose concentration
X = y(:, 2);  % Insulin action
I = y(:, 3);  % Plasma insulin concentration

Gout(:,k) = G; 
%% Run analysis
baseline = Gb;

error = Gout - baseline;
avgError = mean(error);
maxError = max(error);
minError = min(error);


boxplot(error)
end


end
end
