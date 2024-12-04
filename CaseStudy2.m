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
org = colors(2,:);
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

t = 0:0.1:240;

IC = [Gb, 0, Ib]; %should baseline insulin action be zero???
u = @(t) 2;  % No external insulin delivery for now

for i = 1:1 % index i changes run # 
i = 4
if i == 1
D = DGenerate('Monophasic',t,20,0,70,20,50, 0);
elseif i == 2
D = DGenerate('Biphasic',t,15,0,70,15,30, 0);
elseif i == 3
D = DGenerate('Lift',t,30,0,10,15,15, 0);
elseif i == 4
D = DGenerate('Run',t,30,0,5,1,50,-10);
end
figure;
plot(t, D,'color',purp,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('D(t) (mg/dL)');
title(sprintf('Utlilized Glucoes Disturbance | Run #%d', i));
if i ~= 4
xlim([0 max(t)]), ylim([0 31]);  
elseif i == 4
xlim([0 max(t)]), ylim([-12 31]);  
yline(0, '--','Color', org, 'LineWidth', 1.5);
end
grid on;
    
%%
dynamics = @(t, y, D) [
    -p1 * (y(1) - Gb) - y(2) * y(1) + D(round(t*10) + 1); % t*10 to match indices
    -p2 * y(2) + p3 * (y(3) - Ib);
    -n * y(3) + u(t)]; % Gdot, Xdot, Idot

[t, y] = ode45(@(t, y) dynamics(t, y, D), t, IC);

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

%% Save images
% filepath = "C:\Users\Will\OneDrive - Washington University in St. Louis\. Control Systems\Case Study 2\Figure Export";
% exportgraphics(fh1, fullfile(filepath, 'part1 different vars.jpg'), 'resolution', 300);
% exportgraphics(fh2, fullfile(filepath, 'part1 equilibrium zoom in.jpg'), 'resolution', 300);
% exportgraphics(fh3, fullfile(filepath, 'part1 linearized sim 1.jpg'), 'resolution', 300);
% fh4 no longer exists
% exportgraphics(fh5, fullfile(filepath, 'part2 delayed sine input u.jpg'), 'resolution', 300);
% exportgraphics(fh6, fullfile(filepath, 'part2 delayed sine sim.jpg'), 'resolution', 300);
% exportgraphics(fh7, fullfile(filepath, 'part2 zombies sim.jpg'), 'resolution', 300);
% exportgraphics(fh8, fullfile(filepath, 'part3 networked sim no control.jpg'), 'resolution', 300);
% exportgraphics(fh9, fullfile(filepath, 'part3 networked sim control.jpg'), 'resolution', 300);
