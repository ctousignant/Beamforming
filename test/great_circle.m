%//////////////////////////////////////////////////
% Program:  great_circle.m
% Author:   Chris Tousignant
% Function: Determine Azimuth of Peaks and Nulls
%           Using Great Circle Calculations 
%//////////////////////////////////////////////////
clear all
close all

% Map
figure
ax = axesm('MapProjection','mercator',...
           'MapLatLimit',[-75 80], 'MapLonLimit', [90 300], 'Grid','on','Frame', 'on');
setm(ax, 'meridianlabel', 'on', 'parallellabel', 'on')
land = shaperead('landareas', 'UseGeoCoords', true);
geoshow(ax, land, 'FaceColor', [0.5 0.7 0.5])
tightmap;

% Select Current Location
[current_lat, current_lon] = inputm(1);
plotm(current_lat, current_lon, 'bo');

% Select Peak
[target_lat, target_lon] = inputm(1);
plotm(target_lat, target_lon, 'go');
linem([current_lat; target_lat], [current_lon; target_lon], 'g-');

% Select Nulls
[null_lat, null_lon] = inputm(1);
plotm(null_lat, null_lon, 'ro');
linem([current_lat; null_lat], [current_lon; null_lon], 'r-');

% Determine Azimuth
target_az = azimuth(current_lat, current_lon, target_lat, target_lon);
null_az = azimuth(current_lat, current_lon, null_lat, null_lon);

% Plot points


