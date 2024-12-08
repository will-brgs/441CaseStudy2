%% Ground Truth: Simulate system and disturbances with no control input
%% Introduction
% * Authors:                  Will Burgess, Mack LaRosa
% * Class:                    ESE 441
% * Date:                     Created 11/21/2024, Last Edited 12/09/2024
%% Housekeeping
clear
clc
code = "finished";
colors = get(gca, 'ColorOrder');
blu = colors(1,:);
org = colors(2,:);
purp = colors(4,:);
grn = colors(5,:);
red = colors(7,:);

close all
%%
% Parameters
p1 = 0.03;     % Rate of glucose decay
p2 = 0.02;     % Rate of insulin action decay
p3 = 0.01;     % Insulin sensitivity
n = 0.1;       % Insulin clearance rate
Gb = 100;      % Baseline glucose
Ib = 10;       % Baseline plasma insulin

actionIC = 0;

tLim = 240;
dt = 0.1;
t = 0:dt:tLim;

IC = [Gb, actionIC, Ib]; %should baseline insulin action be zero???

graph = 1; % set to 1 to genearte report graph of just glucose
%%
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
elseif i == 5 
D = zeros(length(t),1);
disturbance = 'None';
end

o = 0;
if o == 1
figure;
plot(t, D,'color',purp,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('D(t) (mg/dL)');
title(sprintf('Utlilized Glucoes Disturbance | %s', disturbance));
if i ~= 4
xlim([0 max(t)]), ylim([0 31]);  
elseif i == 4
xlim([0 max(t)]), ylim([-12 31]);  
yline(0, '--','Color', org, 'LineWidth', 1.5);
end
grid on;
end
%%
Dinterp = @(t) interp1(0:dt:tLim, D, t, 'linear', 'extrap');

 dynamics = @(t, y) [
     -p1 * (y(1) - Gb) - max(y(2),0) * y(1) + Dinterp(t);
     -p2 * max(y(2), 0) + p3 * (y(3) - Ib);
     -n * y(3)];

[t, y] = ode45(dynamics, t, IC);

y(:, 2) = max(y(:, 2), 0); % Clamp Insulin Action

%%
% Extract states
G = y(:, 1);  % Blood glucose concentration
X = y(:, 2);  % Insulin action
I = y(:, 3);  % Plasma insulin concentration


if graph == 0
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
plot(t, I,'color',grn,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('I(t) (mU/L)');
title('Plasma Insulin Concentration');
grid on;

sgtitle({'System State Responses', ...
    sprintf('Disturbance Type: %s', disturbance), ...
    sprintf('Inital Insulin-Action: %d', actionIC)},...
    'FontSize', 12, 'FontWeight', 'bold')

elseif graph == 1
if i == 1
figure
subplot(2,2,i)
plot(t, G,'color',blu,  'LineWidth', 1.5);
title(sprintf('Monophasic Nutrition'));
xlabel('Time (min)');
ylabel('G(t) (mg/dL)');
xlim([0,240])
ylim([-310,700])
yline(100, '--','Color', red, 'LineWidth', 1.5);
grid on

hold on
elseif i == 2
subplot(2,2,i)
hold on
plot(t, G,'color',org,  'LineWidth', 1.5);
title(sprintf('Biphasic Nutrition'));
xlabel('Time (min)');
ylabel('G(t) (mg/dL)');
xlim([0,240])
ylim([-200,700])
yline(100, '--','Color', red, 'LineWidth', 1.5);
grid on

elseif i == 3
subplot(2,2,i)
hold on
plot(t, G,'color',purp,  'LineWidth', 1.5);
title(sprintf('Weightlifthing Adrenaline'));
xlabel('Time (min)');
ylabel('G(t) (mg/dL)');
xlim([0,240])
ylim([-200,700])
yline(100, '--','Color', red, 'LineWidth', 1.5);
grid on
elseif i == 4
subplot(2,2,i)
hold on
plot(t, G,'color',grn,  'LineWidth', 1.5);
title(sprintf('Sugarloaded Marathon'));
xlabel('Time (min)');
ylabel('G(t) (mg/dL)');
xlim([0,240])
ylim([-260,700])
yline(100, '--','Color', red, 'LineWidth', 1.5);

grid on

end
sgtitle({'Ground Truth Glucose Response for Disturbance Models'})
end
end

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
