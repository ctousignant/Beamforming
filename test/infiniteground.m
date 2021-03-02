clear all;
close all;

c = 299792458;        % signal propagation speed
fc = 22e6;       % signal carrier frequency
lambda = c/fc;  % wavelength
numAntennas = 7; % number of antennas

az_target = 90;     % target azimuth (degrees)
az_null = -20;       % interference direction (degrees)
ele_target = 0;    % target elevation (degrees)
ele_null = 0;      % null elevation (degrees)

antenna = monopoleRadial('Height',lambda/4,'RadialLength',lambda/4,'Width',.1,'RadialWidth',.1,'NumRadials',4, 'Tilt', [40], 'TiltAxis', [0 0 1]);
%phArray = phased.ULA('NumElements',numAntennas,'Element', antenna, 'ElementSpacing', lambda/2);
phArray = phased.UCA('NumElements',numAntennas,'Element', antenna,  'Radius', lambda/2);

%linArray = linearArray('Element', antenna, 'ElementSpacing', lambda/2, 'NumElements', numAntennas);
%createGeometry(linArray);

d = dipole('Length',1e-3,'Width',1e-5);
rf = reflector('Exciter',d, 'GroundPlaneLength',inf,'Spacing',0.002);



for i = 1:numAntennas
   element{i} = antenna;
end

element{end+1} = rf;

elementpos = (getElementPosition(phArray))';
elementpos = -elementpos;
elementpos(:,3) = .1;
elementpos(end+1,:) = [0 0 0.001]; %for some reason the reflector can't be at 0 on the z-axis

confArray = conformalArray('Element',element,'ElementPosition',elementpos);

% Generalized sidelobe canceller
% Calculate the steering vector for null directions
wn = steervec(getElementPosition(phArray)/lambda,az_null);

% Calculate the steering vectors for lookout directions
wd = steervec(getElementPosition(phArray)/lambda,az_target);
% win = kaiser(8,4);
% wd = win.*wd;

% Compute the response of desired steering at null direction
rn = wn'*wd/(wn'*wn);

% Sidelobe canceler - remove the response at null direction
w = wd-wn*rn;

magw = abs(w);
phasew = rad2deg(angle(w));
magw(end + 1) = 0;
phasew(end + 1) = 0;
figure
confArray.AmplitudeTaper = magw;
confArray.PhaseShift = phasew;
show(confArray);
figure
%x = pattern(linArray, fc, -180:1:180,-90:1:90);
tic
pattern(confArray, fc, -180:1:180,20, 'Normalize', true);
toc
figure
pattern(phArray,fc,-180:1:180,20,'CoordinateSystem','polar','Type','powerdb','PropagationSpeed',c,'Weights',w,  'Normalize', true);



