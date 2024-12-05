%% Distrubtion Demo: Generates Plot to demonstate D(t) Utilized
%% Introduction
% * Authors:                  Will Burgess, Mack LaRosa
% * Class:                    ESE 441
% * Date:                     Created 12/02/2024, Last Edited 12/09/2024
%%
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
figure;
t = 0:0.1:240;
DMono = DGenerate('Monophasic',t,20,0,70,20,50);

DBi = DGenerate('Biphasic',t,15,0,70,15,30);

DLift = DGenerate('Lift',t,30,0,10,15,15, 0);

DRun = DGenerate('Run',t,30,0,5,1,50,-10);

subplot(2,2,1)
sgtitle('Evaluated Glucose Disturbance Models D(t)')
plot(t, DMono,'color',blu,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('D(t) (mg/dL)');
title(sprintf('Monophasic Eating'));
xlim([0 max(t)]), ylim([0 20]);  
grid on;

subplot(2,2,2)
plot(t, DBi,'color',org,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('D(t) (mg/dL)');
title(sprintf('Biphasic Eating'));
xlim([0 max(t)]), ylim([0 20]);  
grid on;

subplot(2,2,3)
plot(t, DLift,'color',purp,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('D(t) (mg/dL)');
title(sprintf('Weightlifthing Adrenaline'));
xlim([0 max(t)]), ylim([0 31]);  
grid on;

subplot(2,2,4)
plot(t, DRun,'color',grn,  'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('D(t) (mg/dL)');
title(sprintf('Sugarloaded Marathon'));
xlim([0 max(t)]), ylim([-12 31]);  
yline(0, '--','Color', org, 'LineWidth', 1.5);
grid on;

%% Save images
% filepath = "C:\Users\Will\OneDrive - Washington University in St. Louis\. Control Systems\Case Study 2\Figure Export";
% exportgraphics(fh1, fullfile(filepath, 'part1 different vars.jpg'), 'resolution', 300);