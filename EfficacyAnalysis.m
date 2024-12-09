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
red = colors(7,:);

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


dt = 0.05;
tLim = 240;
t = 0:dt:tLim;

%% Deterine Observer/Controller
%syms kp ki
A = [-p1Base, -GbBase, 0;
     0, -p2Base, p3Base;
     0, 0, -nBase];
B = [0;
     0;
     1];
C = [1, 0, 0];



%% Find gains based on mode
for m = 1:2 % Varies mode from auto to exercise. change to 2 later
if m == 1
mode = 'Auto';
controllerPoles = [-0.4, -0.3, -0.2, -0.1];
observerPoles = [-2, -2.2, -2.4];
elseif m==2
mode = 'Exercise';
controllerPoles = 0.75 .* [-0.4, -0.3, -0.2, -0.1];
observerPoles = 0.75 .*[-2, -2.2, -2.4];
end
[Kp, Ki, L] = findGains(A, B, C, controllerPoles, observerPoles);

%% Initialize Saved Results
simLength = 30;
meanErrors = zeros(simLength,4);
maxErrors = zeros(simLength,4);

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
for k = 1:simLength % 
Gout = zeros(length(t),30);

p1 = p1Base  * (0.85 + (0.3 * rand));     % Rate of glucose decay
p2 = p2Base  * (0.85 + (0.3 * rand));     % Rate of insulin action decay
p3 = p3Base  * (0.85 + (0.3 * rand));     % Insulin sensitivity
n = nBase   * (0.85 + (0.3 * rand));       % Insulin clearance rate
Gb = GbBase;      % Baseline glucose
Ib = IbBase;       % Baseline plasma insulin
%% simulate ODE
Dinterp = @(t) interp1(0:dt:tLim, D, t, 'linear', 'extrap');

IC = [100; 0; 11; 100;0;10;0]; % Initial conditions: [G, X, I]
[t,states] = ode45(@(t,states) simFuncAnalysis(t, A, B, Dinterp, Kp, Ki, L, Gb, states,p1,p2,p3,n), t, IC);

% Extract states
G = states(:, 1);  % Blood glucose concentration
X = states(:, 2);  % Insulin action
I = states(:, 3);  % Plasma insulin concentration

%Gout(:,k) = G; 
%% Run analysis
baseline = Gb;

error = G - baseline;
meanError = mean(abs(error)); % mean error magnitude
maxError = max(error);
minError = min(error);

meanErrors(k,i) = meanError;

if (abs(maxError) >= abs(minError))
maxErrors(k,i) = maxError;
else
maxErrors(k,i) = minError;
end

end % end sims

end
%% Figures
%Boxplots
if m == 1
fh1 =figure;
else
fh3 = figure;
end
labels = {'Monophasic Nutrition', 'Biphasic Nutrition', 'Weightlifting Adrenaline', 'Sugarloaded Marathon'};

boxplot(meanErrors, 'Labels', labels);
ylabel('Mean Glucose Deviation (mg/dL)');
grid on;

% boxplot appearance change. not our code. taken from matlab doc
h = findobj(gca, 'Tag', 'Box');
for j = 1:length(h)
    set(h(j), 'Color', blu, 'LineWidth', 2);
end

% Customize  median lines
medianLines = findobj(gca, 'Tag', 'Median');
for j = 1:length(medianLines)
    set(medianLines(j), 'Color', red, 'LineWidth', 2); 
end


sgtitle(sprintf('Maximum Error Efficacy Analysis | %s Mode', mode),...
    'FontSize', 12, 'FontWeight', 'bold')
ylim([2,9]);
% Barplots
if m == 1
fh2 =figure;
else
fh4 = figure;
end
for i = 1:4
subplot(2,2,i)
b = bar(maxErrors(:,i));
xlabel('Simulation #')
ylabel('Deviation (mg/dL)')
if i ==1
title('Monophasic Nutriton')
b.FaceColor = blu;
elseif i ==2
title('Biphasic Nutriton')
b.FaceColor = org;

elseif i==3
title('Weightlifting Adrenaline')
b.FaceColor = purp;

elseif i==4
title('Sugarloaded Marathon')
b.FaceColor = grn;

end
end

sgtitle({'Maximum Error Efficacy Analysis', ...
    sprintf('Control Mode: %s', mode)},...
    'FontSize', 12, 'FontWeight', 'bold')
grid on
end
%% Save images
% filepath = "C:\Users\Will\OneDrive - Washington University in St. Louis\. Control Systems\Case Study 2\Figure Export";
% exportgraphics(fh1, fullfile(filepath, 'Analysis Mean Auto.jpg'), 'resolution', 300);
% exportgraphics(fh2, fullfile(filepath, 'Analysis Max Auto.jpg'), 'resolution', 300);
% exportgraphics(fh3, fullfile(filepath, 'Analysis Mean Exercise.jpg'), 'resolution', 300);
% exportgraphics(fh4, fullfile(filepath, 'Analysis Max Exercise.jpg'), 'resolution', 300);
% exportgraphics(fh5, fullfile(filepath, 'part2 delayed sine input u.jpg'), 'resolution', 300);
% exportgraphics(fh6, fullfile(filepath, 'part2 delayed sine sim.jpg'), 'resolution', 300);
% exportgraphics(fh7, fullfile(filepath, 'part2 zombies sim.jpg'), 'resolution', 300);
% exportgraphics(fh8, fullfile(filepath, 'part3 networked sim no control.jpg'), 'resolution', 300);
% exportgraphics(fh9, fullfile(filepath, 'part3 networked sim control.jpg'), 'resolution', 300);