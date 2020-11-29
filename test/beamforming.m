clear all;
close all;

%% Beamformer
c = 3e8;        % signal propagation speed
fc = 22e6;       % signal carrier frequency
lambda = c/fc;  % wavelength

thetaad = 30;           % look directions (degrees)
thetaan = 70;           % interference direction (degrees)

antenna = monopole('GroundPlaneLength', 43, 'GroundPlaneWidth', 43, 'Height', 43, 'Width', 0.25)
ula = phased.ULA('NumElements',8,'Element', antenna, 'ElementSpacing', lambda/2);

% Generalized sidelobe canceller
% Calculate the steering vector for null directions
wn = steervec(getElementPosition(ula)/lambda,thetaan);

% Calculate the steering vectors for lookout directions
wd = steervec(getElementPosition(ula)/lambda,thetaad);
% win = kaiser(8,4);
% wd = win.*wd;

% Compute the response of desired steering at null direction
rn = wn'*wd/(wn'*wn);

% Sidelobe canceler - remove the response at null direction
w = wd-wn*rn;

% Plot the pattern
figure
pattern(ula,fc,-180:0.2:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','rectangular','Weights',w);
hold on; legend off;
for i = 1:length(thetaan)
    plot([thetaan(i) thetaan(i)],[-100 100],'r--','LineWidth',2)
end
for z = 1:length(thetaad)
    plot([thetaad(z) thetaad(z)],[-100 100],'g--','LineWidth',2)
end
hold off;

% Zoom
figure
pattern(ula,fc,-180:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','rectangular','Weights',w);
hold on; legend off;
for a = 1:length(thetaan)
    plot([thetaan(a) thetaan(a)],[-100 100],'r--','LineWidth',2)
end
for b = 1:length(thetaad)
    plot([thetaad(b) thetaad(b)],[-100 100],'g--','LineWidth',2)
end
xlim([min(thetaan-10) max(thetaan+10)])
legend(arrayfun(@(k)sprintf('%d degrees',k),thetaad,...
    'UniformOutput',false),'Location','SouthEast');

% 3-D
figure
rotate3d on
pattern(ula,fc,'CoordinateSystem','polar','Type','powerdb',...
        'PropagationSpeed',c,'Weights',w(:,1));
view(50,20);
ax = gca;
%ax.Position = [-0.15 0.1 0.9 0.8];
camva(4.5);
campos([1000 -500 500]);