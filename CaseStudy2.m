%% ESE441 Case Study 2: 
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

close all
%%
% Parameters
p1 = 0.03;     % Rate of glucose decay
p2 = 0.02;     % Rate of insulin action decay
p3 = 0.01;     % Insulin sensitivity
n = 0.1;       % Insulin clearance rate
Gb = 100;      % Baseline glucose
Ib = 10;       % Baseline plasma insulin

dt = 0.05;
tLim = 240;
t = 0:dt:tLim;

IC = [Gb, 0, Ib]; %should baseline insulin action be zero???

%% Deterine Observer/Controller
A = [-p1, -Gb, 0;
     0, -p2, p3;
     0, 0, -n];
B = [0;
     0;
     1];
C = [1, 0, 0];

%[K_p, K_i, L] = findGains(A, B, C, [-5.3, -5.2, -5.1, -3], [-1, -1.1, -1.2]);
[Kp, Ki, L] = findGains(A, B, C, [-5.0, -5.1, -5.2, -5.3], [-6, -6.2, -6.4]);

AAugmented = [A, zeros(3,1); 
              C, 0];
BAugmented = [B; 0];

kAugmented = place(A, B, [-5.3, -5.2, -5.1]);
Kp = kAugmented(1:3);
Ki = kAugmented(end);

%% Define Mode
for j = 1 % Varies mode from auto to exercise. change to 2 later
    if j == 1
        mode = 'Auto';
    elseif j==2
        mode = 'Exercise';
    elseif j==3
        mode = 'Uncontrolled';
    end
for i = 2 % Sweeps through D values, change to 4 later
%% Define Disturbance
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
elseif i== 5
D = zeros(length(t),1);
disturbance = 'No Disturbance';
end

p = 0;% set to 1 to see debug graph
if p == 1
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
    
%% Solve ODE with Control
Dinterp = @(t) interp1(0:dt:tLim, D, t, 'linear', 'extrap');

options = odeset('NonNegative', 1:6);
init = [120; 0; 11;120;0;11;0]; % Initial conditions: [G, X, I]
[t,states] = ode45(@(t,states) simFunc(t, A, B, Dinterp, Kp, Ki, L, Gb, states), t, init, options);

% Extract states
G = states(:, 1);
X = states(:, 2);
I = states(:, 3);

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

sgtitle({'System State Responses', ...
    sprintf('Disturbance Type: %s', disturbance), ...
    sprintf('Control Mode: %s', mode)},...
    'FontSize', 12, 'FontWeight', 'bold')
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
