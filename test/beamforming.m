clear all;
close all;

%% Beamformer
c = 299792458;        % signal propagation speed
fc = 22e6;       % signal carrier frequency
lambda = c/fc;  % wavelength

az_target = 110;     % target azimuth (degrees)
az_null = 80;       % interference direction (degrees)
ele_target = 0;    % target elevation (degrees)
ele_null = 0;      % null elevation (degrees)

antenna = monopoleRadial('Height',lambda/4,'RadialLength',lambda/4,'Width',.1,'RadialWidth',.1,'NumRadials',4);
%antenna = monopole('GroundPlaneLength', 43, 'GroundPlaneWidth', 43, 'Height', lambda/4, 'Width', 0.1)
%array = phased.ULA('NumElements',8,'Element', antenna, 'ElementSpacing', lambda/2);
array = phased.UCA('NumElements',8,'Element', antenna, 'Radius', lambda/2);

% Generalized sidelobe canceller
% Calculate the steering vector for null directions
wn = steervec(getElementPosition(array)/lambda,az_null);

% Calculate the steering vectors for lookout directions
wd = steervec(getElementPosition(array)/lambda,az_target);
% win = kaiser(8,4);
% wd = win.*wd;

% Compute the response of desired steering at null direction
rn = wn'*wd/(wn'*wn);

% Sidelobe canceler - remove the response at null direction
w = wd-wn*rn;

% Plot azimuth cut 2D
figure
pattern(array,fc,-180:0.2:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','rectangular','Weights',w);
hold on; legend off;
for i = 1:length(az_null)
    plot([az_null(i) az_null(i)],[-100 100],'r--','LineWidth',2)
end
for z = 1:length(az_target)
    plot([az_target(z) az_target(z)],[-100 100],'g--','LineWidth',2)
end
hold off;

% Zoom on null 2D
figure
pattern(array,fc,-180:0.2:180,0,'PropagationSpeed',c,'Type','powerdb',...
    'CoordinateSystem','rectangular','Weights',w);
hold on; legend off;
for a = 1:length(az_null)
    plot([az_null(a) az_null(a)],[-100 100],'r--','LineWidth',2)
end
for b = 1:length(az_target)
    plot([az_target(b) az_target(b)],[-100 100],'g--','LineWidth',2)
end

xlim([min(az_null-10) max(az_null+10)])
legend(arrayfun(@(k)sprintf('%d degrees',k),az_target,...
    'UniformOutput',false),'Location','SouthEast');

%resolution in degrees
patternRes = 3;

% 3-D
figure
rotate3d on
pattern(array,fc,-180:patternRes:180,-90:patternRes:90,'CoordinateSystem','polar','Type','powerdb',...
        'PropagationSpeed',c,'Weights',w);
title('Response at Carrier');

% % +1.5kHz
% %figure
% rotate3d on
% [pluspat, ~, ~] = pattern(array,(fc+1.5e3),-180:patternRes:180,-90:patternRes:90,'CoordinateSystem','polar','Type','powerdb',...
%         'PropagationSpeed',c,'Weights',w);
% %title('Response at +1.5kHz')
% 
% % -1.5kHz
% %figure
% rotate3d on
% [minuspat, azi, elev] = pattern(array,(fc-1.5e3),-180:patternRes:180,-90:patternRes:90,'CoordinateSystem','polar','Type','powerdb',...
%         'PropagationSpeed',c,'Weights',w);
% %title('Response at -1.5kHz')
% 
% minusdiff = defpat - minuspat;
% plusdiff = defpat - pluspat;
% 
% zrange = ([-5 5]);
% 
% figure
% mesh(azi, elev, plusdiff);
% ylabel('Elevation Angle (deg)')
% xlabel('Azimuth Angle (deg)')
% zlabel('Difference from Carrier Pattern (dB)')
% title('+1.5kHz Difference From Carrier Pattern')
% zlim(zrange);
% caxis(zrange);
% 
% figure
% mesh(azi, elev, minusdiff);
% ylabel('Elevation Angle (deg)')
% xlabel('Azimuth Angle (deg)')
% zlabel('Difference from Carrier Pattern (dB)')
% title('-1.5kHz Difference From Carrier Pattern')
% zlim(zrange);
% caxis(zrange);

bw = 1e6;
step = 1000;

figure
parallelResults = zeros(361,(bw/step)+1);
parfor i = 0:(bw/step)
    [parallelResults(:,i+1), ~, ~] = pattern(array,(fc-(bw/2)+(i*step)),-180:1:180,0,'PropagationSpeed',c,'Type','powerdb','CoordinateSystem','polar','Normalize',false,'Weights',w);
end

[~, plot_azimuth, ~] = pattern(array,(fc),-180:1:180,0,'PropagationSpeed',c,'Type','powerdb','CoordinateSystem','polar','Normalize',false,'Weights',w);
zrange = ([-75 15]);
plot_freq = fc-(bw/2):step:fc+(bw/2);
plot_freq = plot_freq./1e+6;
surf(plot_freq, plot_azimuth, parallelResults);
shading interp;
view(0,90);
c = colorbar;
c.Label.String = 'Gain (dBi)';
caxis(zrange);
ylabel('Azimuth Angle (deg)');
xlabel('Frequency (MHz)')
title('Affect of Transmission Bandwidth on Pattern (Elev. = 0 deg)');


% phi = az';
% theta = (90-el);
% MagE = efield';

%figure

%patternCustom(MagE,theta,phi);


%ax = gca;
%ax.Position = [-0.15 0.1 0.9 0.8];
%camva(4.5);
%campos([1000 -500 500]);

%show(antenna)
