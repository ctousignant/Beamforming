function wideEnemyNulls = placeNulls(azEnemy, elEnemy, nullsPerEnemyAzimuth, nullSpacing)
% Default
wideEnemyNulls = [];

% If the nulls can be divided up evenly
if rem(nullsPerEnemyAzimuth, 1) == 0
    disp("The nulls will be split evenly between all enemies");
    % If there is an even number of nulls per enemy azimuth
    if rem(nullsPerEnemyAzimuth, 2) == 0
        disp("There is an even number of nulls per enemy");
        for i=1:length(azEnemy)
            azLow = azEnemy(i) - (nullSpacing(i) * (nullsPerEnemyAzimuth/2 - 0.5));
            azHigh = azEnemy(i) + (nullSpacing(i) * (nullsPerEnemyAzimuth/2 - 0.5));
            wideEnemyNulls = [wideEnemyNulls [linspace(azLow, azHigh, nullsPerEnemyAzimuth); ones(1,nullsPerEnemyAzimuth)*elEnemy(i)]];
        end
    % If there are an odd number of nulls per enemy azimuth
    else
        disp("There is an odd number of nulls per enemy");
        for i=1:length(azEnemy)
            azLow = azEnemy(i) - (nullSpacing(i) * floor(nullsPerEnemyAzimuth/2));
            azHigh = azEnemy(i) + (nullSpacing(i) * floor(nullsPerEnemyAzimuth/2));
            wideEnemyNulls = [wideEnemyNulls [linspace(azLow, azHigh, nullsPerEnemyAzimuth); ones(1,nullsPerEnemyAzimuth)*elEnemy(i)]];
        end
    end
% If the nulls cannot be divided up evenly
else
    disp("The number of nulls is odd and therefore will not be placed evenly");
    % Generate a list of how many nulls will be applied to each enemy azimuth
    numNulls = ones(1, length(azEnemy)) * floor(nullsPerEnemyAzimuth);
    remainingNulls = length(azEnemy) * (nullsPerEnemyAzimuth - floor(nullsPerEnemyAzimuth));
    for j=1:remainingNulls
        numNulls(j) = numNulls(j) + 1;
    end
    % Make a recursive call to determine null placement
    for i=1:length(azEnemy)
        wideEnemyNulls = [wideEnemyNulls placeNulls(azEnemy(i), elEnemy(i), numNulls(i), nullSpacing)];
    end
end

wideEnemyNulls = wrapTo180(wideEnemyNulls);
end

