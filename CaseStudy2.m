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
%%

% Parameters
p1 = 0.03;     % Rate of glucose decay (1/min)
p2 = 0.02;     % Rate of insulin action decay (1/min)
p3 = 0.01;     % Insulin sensitivity (1/min)
n = 0.1;       % Insulin clearance rate (1/min)
Gb = 100;      % Baseline glucose (mg/dL)
Ib = 10;       % Baseline plasma insulin (mU/L)


tspan = linspace(0,1000,300); % minutes
IC = [Gb, 0, Ib];

% Meal glucose influx D(t) and insulin delivery u(t)
D = @(t) 50 * (t > 60 && t < 120);  % Example: 50 mg/dL/min from 60 to 120 min
u = @(t) 0;  % No external insulin delivery for now

dynamics = @(t, y) [ -p1 * (y(1) - Gb) - y(2) * y(1) + D(t);
                     -p2 * y(2) + p3 * (y(3) - Ib);
                     -n * y(3) + u(t)]; % Gdot, Xdot, Idot

% Solve the system using ode45
[t, y] = ode45(dynamics, tspan, IC);

% Extract states
G = y(:, 1);  % Blood glucose concentration
X = y(:, 2);  % Insulin action
I = y(:, 3);  % Plasma insulin concentration

% Plot results
figure;
subplot(3, 1, 1);
plot(t, G, 'b', 'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('Glucose G(t) (mg/dL)');
title('Blood Glucose Concentration');
grid on;

subplot(3, 1, 2);
plot(t, X, 'r', 'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('Insulin Action X(t)');
title('Insulin Action Dynamics');
grid on;

subplot(3, 1, 3);
plot(t, I, 'g', 'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('Plasma Insulin I(t) (mU/L)');
title('Plasma Insulin Concentration');
grid on;
