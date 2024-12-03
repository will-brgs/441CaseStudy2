%% ESE441 Case Study 2: 
%% Introduction
% * Authors:                  Will Burgess, Mack LaRosa
% * Class:                    ESE 441
% * Date:                     Created 11/21/2024, Last Edited 12/09/2024
%% Housekeeping
close all
clear
clc
code = "finished";

colors = get(gca, 'ColorOrder');
blu = colors(1,:);
purp = colors(4,:);
grn = colors(5,:);
%%
% Parameters
p1 = 0.03;     % Rate of glucose decay
p2 = 0.02;     % Rate of insulin action decay
p3 = 0.01;     % Insulin sensitivity
n = 0.1;       % Insulin clearance rate
Gb = 100;      % Baseline glucose
Ib = 10;       % Baseline plasma insulin

t = 0:0.1:180;

IC = [Gb, 0, Ib]; %should baseline insulin action be zero???
u = @(t) 2;  % No external insulin delivery for now

for i = 1:1 % index changes run # 
    %D = @(t) 50 * (t > 60 && t < 120);  % Example: 50 mg/dL/min from 60 to 120 min

if i == 1
D = DGenerate('Monophasic',t,20,0,70,20,50);
%D = DGenerate('Biphasic',t,);

end
figure;
plot(t, D,'color',purp,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('D(t) (mg/dL)');
title('Glucose Influx');
grid on;
if i == 2
    
end
%%
dynamics = @(t, y) [ -p1 * (y(1) - Gb) - y(2) * y(1) + D(t);
                     -p2 * y(2) + p3 * (y(3) - Ib);
                     -n * y(3) + u(t)]; % Gdot, Xdot, Idot
% Solve the system using ode45
[t, y] = ode45(dynamics, t, IC);

% Extract states
G = y(:, 1);  % Blood glucose concentration
X = y(:, 2);  % Insulin action
I = y(:, 3);  % Plasma insulin concentration

figure;
subplot(3, 1, 1);
plot(t, G,'color',blu,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('G(t) (mg/dL)');
title('Blood Glucose Concentration');
grid on;

subplot(3, 1, 2);
plot(t, X,'color',purp , 'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('X(t)');
title('Insulin Action Dynamics');
grid on;

subplot(3, 1, 3);
plot(t, I, 'g','color',grn,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('I(t) (mU/L)');
title('Plasma Insulin Concentration');
grid on;
end
%% plot for analysis
fakey = -20 + (40 * rand(1, 29));
fakex = zeros(length(29),1);

figure
b = bar(fakey);
% b.Barwidth = 2;
% b.FaceColor = 'b';

xlabel('Simulation #')
ylabel('Glucose Deviation from 100mg/dL')
title('Efficacy Analysis of Auto Mode')
grid on