% Multiple Wide Null Adaptive Beamformer
% Date: 1/27/2021
clear all;
close all;

%% Inputs
N = 8;                % Number of Elements
azAlly = -70;          % Target Azimuth in degrees
azEnemy = [-10 40];  % Null Azimuths
fc = 22e6;            % Carrier frequency
azDiff = azAlly - azEnemy;
for i=1:length(azDiff)
    if azDiff(i) > 90
        azDiff(i) = 180 - azDiff(i);
    end
end
nullSpacing = 1.033.^(abs(azDiff))*1.5;      % Null spacing in degrees
for i=1:length(nullSpacing)
    if nullSpacing(i) >= 5
      nullSpacing(i) = 5;
    end
end
%% Constants
c = physconst('LightSpeed'); % signal propagation speed
lambda = c/fc;               % wavelength
reservedDOF = [1 1 1 2 2 2]; % Reserved Degrees of Freedom based on N [3 4 ... 8]

%% Globally Scoped Defines
availableNulls = 0;
requiredNulls = 0;
nullsPerEnemyAzimuth = 0;
wideEnemyNulls = [];
steeringMatrix = [];
desiredResponse = [];
antennaWeights = [];

%% Physical Array
antenna = monopole('GroundPlaneLength', 43, 'GroundPlaneWidth', 43, 'Height', lambda/4, 'Width', 0.1);
array = phased.ULA('NumElements',N,'Element', antenna, 'ElementSpacing', lambda/2);

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
% wideEnemyNulls = zeros(length(azEnemy));
% for i = 1:length(azEnemy)
    wideEnemyNulls = placeNulls(azEnemy, nullsPerEnemyAzimuth, nullSpacing)
% end



%% Antenna Weight Calculations
% Steering Matrix
steeringMatrix = steervec(getElementPosition(array)/lambda, [azAlly wideEnemyNulls]);

% Desired Response
desiredResponse = [1 zeros(1, length(wideEnemyNulls))];

% If we have a non-singular square matrix (N-1 nulls)
% Honestly, we do not want to do this because we waste all of our
% degrees of freedom placing nulls, leading to a performance loss
% in the main beam
if ~diff(size(steeringMatrix))
    antennaWeights = (desiredResponse*inv(steeringMatrix))'; % Array Weights
    
% If singular matrix (less than N-1 nulls)
% so that a solution can still be found.
% We should be doing it this way, where we leave a few unplaced nulls to
% allow for extra unused degrees of freedom so that the main lobe doesn't
% suffer any performance degredation (apart from widening due to scanning)
else
    antennaWeights = (desiredResponse*pinv(steeringMatrix))'; % Array Weights
end

%% Plotting
% Plot 2D Rectangular azimuth cut
figure
pattern(array,fc,-180:.1:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','rectangular','Weights',antennaWeights);
xlim([-90 90]);
hold on; legend off;
for i = 1:length(wideEnemyNulls)
    plot([wideEnemyNulls(i) wideEnemyNulls(i)],[-500 100],'r--','LineWidth',1)
end
for z = 1:length(azAlly)
    plot([azAlly(z) azAlly(z)],[-500 100],'g--','LineWidth',1)
end
hold off;

% Plot 2D Polar azimuth cut
figure
pattern(array,fc,-180:.1:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','polar','Weights',antennaWeights);
hold on; legend off;
% TODO - get these lines plotting
for i = 1:length(wideEnemyNulls)
    plot([wideEnemyNulls(i) wideEnemyNulls(i)],[-500 100],'r--','LineWidth',1)
end
for z = 1:length(azAlly)
    plot([azAlly(z) azAlly(z)],[-500 100],'g--','LineWidth',1)
end
hold off;

% Plot 3D
figure
rotate3d on
pattern(array,fc,-180:0.5:180,-90:.5:90,'CoordinateSystem','polar','Type','powerdb',...
        'PropagationSpeed',c,'Weights',antennaWeights);
view([45 45]);