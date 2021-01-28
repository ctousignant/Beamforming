clear all;
close all;

%% Multiple Wide Null Adaptive Beamformer
% Inputs
N = 8;                            % Number of Elements
az_target = 20;                   % Target Azimuth
az_nulls = [-20 -25 -30 -40 -45]; % Null Azimuths -- TODO
fc = 22e6;                        % Carrier frequency

% Constants
c = physconst('LightSpeed'); % signal propagation speed
lambda = c/fc;               % wavelength

% Array Creation
antenna = monopole('GroundPlaneLength', 43, 'GroundPlaneWidth', 43, 'Height', lambda/4, 'Width', 0.1);
array = phased.ULA('NumElements',N,'Element', antenna, 'ElementSpacing', lambda/2);

% TODO
% Calculate locations for additional nulls
az_nulls_expanded = az_nulls;

% Steering Matrix
A = steervec(getElementPosition(array)/lambda, [az_target az_nulls_expanded]);

% Desired Response
r = [1 zeros(1, length(az_nulls_expanded))];

% If we have a non-singular square matrix (N-1 nulls)
% Honestly, we do not want to do this because we waste all of our
% degrees of freedom placing nulls, leading to a performance loss
% in the main beam
if ~diff(size(A))
    w = (r*inv(A))'; % Array Weights
    
% If singular matrix (less than N-1 nulls)
% so that a solution can still be found.
% We should be doing it this way, where we leave a few unplaced nulls to
% allow for extra unused degrees of freedom so that the main lobe doesn't
% suffer any performance degredation (apart from widening due to scanning)
else
    w = (r*pinv(A))'; % Array Weights
end

% Plot 2D Rectangular azimuth cut
figure
pattern(array,fc,-180:1:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','rectangular','Weights',w);
xlim([-90 90]);
hold on; legend off;
for i = 1:length(az_nulls_expanded)
    plot([az_nulls_expanded(i) az_nulls_expanded(i)],[-500 100],'r--','LineWidth',1)
end
for z = 1:length(az_target)
    plot([az_target(z) az_target(z)],[-500 100],'g--','LineWidth',1)
end
hold off;

% Plot 2D Polar azimuth cut
figure
pattern(array,fc,-180:1:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','polar','Weights',w);
hold on; legend off;
% TODO - get these lines plotting
for i = 1:length(az_nulls_expanded)
    plot([az_nulls_expanded(i) az_nulls_expanded(i)],[-500 100],'r--','LineWidth',1)
end
for z = 1:length(az_target)
    plot([az_target(z) az_target(z)],[-500 100],'g--','LineWidth',1)
end
hold off;

% Plot 3D
figure
rotate3d on
pattern(array,fc,-180:0.5:180,-90:.5:90,'CoordinateSystem','polar','Type','powerdb',...
        'PropagationSpeed',c,'Weights',w);
view([45 45]);





