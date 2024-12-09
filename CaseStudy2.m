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

%%
A = [-p1, -Gb, 0;
     0, -p2, p3;
     0, 0, -n];
B = [0;
     0;
     1];
C = [1, 0, 0];

[K_p, K_i, L] = findGains(A, B, C, [-5.3, -5.2, -5.1, -3], [-1, -1.1, -1.2]);


% Aa = [-p1, -Gb, 0, 0;
%       0, -p2, p3, 0;
%       0, 0, -n, 0;
%       1, 0, 0, 0];
% Ba = [0; 
%       0; 
%       1; 
%       0];
% Br = [0; 0 ; 0; -1];
% Ca = [1, 0, 0, 0];
% Da = [0];
% 
% p4 = -300;
% Ka = place(Aa,Ba,[p1,p2,p3,p4]);
% 
% K_p = Ka(1:3);
% k_i = Ka(4);
% 

AAugmented = [A, zeros(3,1); 
                  C, 0];
BAugmented = [B; 0];

kAugmented = place(A, B, [-5.3, -5.2, -5.1]);
K_p = kAugmented(1:3);
K_i = kAugmented(end);


%%
for j = 3 % Varies mode from auto to exercise. change to 2 later
    if j == 1
        mode = 'Auto';
    elseif j==2
        mode = 'Exercise';
    elseif j==3
        mode = 'Uncontrolled';
    end
for i = 2 % Sweeps through D values, change to 4 later
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
    
%%
Dinterp = @(t) interp1(0:dt:tLim, D, t, 'linear', 'extrap');

% dynamics = @(t, y) [
%             -p1 * (y(1) - Gb) - y(2) * y(1);
%             -p2 * y(2) + p3 * (y(3) - Ib);
%             -n * y(3) ];

dynamics = @(t, y, u) [
    -p1 * (y(1) - Gb) - y(2) * y(1) + Dinterp(t);
     -p2 * y(2) + p3 * (y(3) - Ib);
    -n * y(3) + u];

% Pre-allocate storage for the states (G, X, I)
nonLinear = zeros(length(t), 3); % 3 columns for G(t), X(t), and I(t)
nonLinear(1, :) = IC;            % Set initial condition

u =  zeros(length(t), 1);
u(1) = 0; %initial u

vHat = IC;
% Manual simulation loop
for h = 1:(length(t)-1)
    % Current state
    vCurrent = nonLinear(h, :); % Row vector [G, X, I] at time step h
    
    vHatDot = A * vHat(h, :)' + B * u(h) + L * (vCurrent(1) - vHat(h, 1));
    vHat(h+1, :) = (vHat(h, :)' + vHatDot * dt)'; % Transpose back to row vector
    vHat(h+1, :) = max(vHat(h+1, :), 0); % ensure nonnegativity


    z = (Gb * ones(h,1)) - nonLinear(1:h,1);
    z = sum(z);

    %u(h+1) = K_p * vHat(h, :)' + K_i * z;

    u(h+1) = -K_p * vHat(h, :)';
    % if u(h+1, 1) <= 0
    %     u(h+1, 1) = 0;    
    % end
 
    dvdt = dynamics(t(h), vCurrent', u(h)); % Pass the current state as a column vector
    
    nonLinear(h+1, :) = vCurrent + dvdt' * dt; % Transpose dydt back to row vector
    
    if vHat(h+1, 1) <= 0
        vHat(h+1, 1) = 0;    
    end
    if vHat(h+1, 2) <= 0
        vHat(h+1, 2) = 0;    
    end
    if vHat(h+1, 3) <= 0
        vHat(h+1, 3) = 0;    
    end

    if all(nonLinear(h+1, 1) <= 0)
        nonLinear(h+1, 1) = 0;    
    end
    if all(nonLinear(h+1, 2) <= 0)
        nonLinear(h+1, 2) = 0;    
    end
    if all(nonLinear(h+1, 3) <= 0)
        nonLinear(h+1, 3) = 0;    
    end
    
    % vHat(h+1, :) = max(vHat(h+1, :), 0); %ensure nonnegativity
    % nonLinear(h+1, :) = max(nonLinear(h+1, :), 0);%THIS IS WHAT I ADDED LAST NIGHT
end

% Extract states
G = nonLinear(:, 1);  % Blood glucose concentration
X = nonLinear(:, 2);  % Insulin action
I = nonLinear(:, 3);  % Plasma insulin concentration

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
