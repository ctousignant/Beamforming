% Multiple Null Synthesis Robust Least Squares Frequency Invariant Beamformer
% Date: 2/16/2021
clear all
close all

%% Inputs
N = 8;                % Number of Elements
azAlly = 50;          % Target Azimuth in degrees
elAlly = 0;
azEnemy = [-50 -30];  % Null Azimuths
elEnemy = [0 0];
fc = 22e6;            % Carrier frequency
nullSpacing = 5;      % TODO: Null spacing in degrees

%% Constants
c = physconst('LightSpeed');    % Speed of Light
lambda = c/fc;                  % Wavelength
diameter = lambda;              % Diameter of Array
reservedDOF = [1 1 1 2 2 2];    % Reserved Degrees of Freedom based on N [3 4 ... 8]


%% Globally Scoped Defines
beams = [];             % Combined list of null and peak directions
w = [];                 % The antenna weights
B = [];                 % Desired beamforming response
d = [];                 % Desired steering vector
V = [];                 % Null-Steering matrix
G = [];                 % Complex Conjugate transpose of combined steering vectors

%% Physical Array
antenna = monopoleRadial('Height',lambda/4,'RadialLength',lambda/4,'Width',.1,'RadialWidth',.1,'NumRadials',4);
array = phased.UCA('NumElements',N,'Element', antenna, 'Radius', lambda/2);

%% Null Widening/Placement
% Determine number of available nulls to place, leaving some free
availableNulls = N - 1 - reservedDOF(N-2);
requiredNulls = length(azEnemy);
if availableNulls < requiredNulls
    error("Error: With %i antennas, only %i nulls available. Requested %i nulls", N, availableNulls, requiredNulls);
end

% Determine how many nulls to assign to each requested enemy azimuth
nullsPerEnemyAzimuth = availableNulls / requiredNulls;

% Place all enemy nulls
wideEnemyNulls = placeNulls(azEnemy, elEnemy, nullsPerEnemyAzimuth, nullSpacing);

%% Antenna Weight Calculations through LS-Minimization
% Combine the lists of beam azimuths
beams = [wideEnemyNulls(1,:) azAlly];

% Determine the desired beamforming response
[~,l] = min(abs(beams-azAlly));
B = zeros(length(beams), 1);
B(l)=1/sqrt(2);

% Retrieve Steering Vectors
d = steervec(getElementPosition(array)/lambda, [azAlly; elAlly]);
V = steervec(getElementPosition(array)/lambda, wideEnemyNulls);
G = [V d]';

% LS Minimization
cvx_begin quiet
    % The variables we want to solve for are the N complex antenna weights
    variable w(N) complex   
    
    % Minimize the square of the L-2 Norm:
    % (||G*w - B||2)^2  (L-2 Norm = ||.||2)
    minimize((G*w-B)'*(G*w-B)) 
    
    % And subject the minimization to the following constraints
    subject to
        % Gain of 1 in the desired direction
        w'*d == 1
        % Honestly not really sure what this one does... lol
        w'*w <= 1
        % Gain of 0 in the null directions
        w'*V == zeros(1, length(wideEnemyNulls))
cvx_end

%% Plotting
% Plot 2D Rectangular azimuth cut
figure
pattern(array,fc,-180:.5:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','rectangular','Weights',w);
xlim([-180 180]);
hold on; legend off;
for i = 1:length(wideEnemyNulls)
    plot([wideEnemyNulls(1,i) wideEnemyNulls(1,i)],[-500 100],'r--','LineWidth',1)
end
for z = 1:length(azAlly)
    plot([azAlly(z) azAlly(z)],[-500 100],'g--','LineWidth',1)
end
hold off;

% Plot 2D Polar azimuth cut
figure
pattern(array,fc,-180:.5:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','polar','Weights',w);
hold on; legend off;
% TODO - get these lines plotting
for i = 1:length(azEnemy)
    plot([azEnemy(i) azEnemy(i)],[-500 100],'r--','LineWidth',1)
end
for z = 1:length(azAlly)
    plot([azAlly(z) azAlly(z)],[-500 100],'g--','LineWidth',1)
end
hold off;

% Plot 3D
figure
rotate3d on
pattern(array,fc,-180:.5:180,-90:.5:90,'CoordinateSystem','polar','Type','powerdb',...
        'PropagationSpeed',c,'Weights',w);
view([45 45]);



