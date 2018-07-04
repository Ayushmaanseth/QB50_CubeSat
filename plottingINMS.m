function INMSdata = plottingINMSData(time1, data1, data1lon, data1lat, time2, data2, data2lon, data2lat, time3, data3, data3lon, data3lat, time4, data4, data4lon, data4lat, time5, data5, data5lon, data5lat, PhoenixLong, PhoenixLat, cmDensity1, cmDensity2, cmLon, cmLat)

%Function plots INMS data alongside CMAT2 contour map of number density 
% each data1, data2, etc is a list of counts from INMS at time time1,
% time2, etc

%data1lon, data1lat, etc correspond to coordinates where INMS data is
%collected

%PhoenixLat and PhoenixLong are the coordinates off the satellite for a
%specific day

%cmDensity1 and cmDensity2 are 4D arrays of density (can be any other
%parameter)

%cmLon and cmLat are latitude and longitude arrays in CMAT2 (correspond to
%cmDensity1 and cmDensity2 data)

% correction for cmat2 longitude
cmLon2 = cmLon; 
cmLon2(21) = 360;

for i = 1:240  
    cmDensity1(:, 21, :, i) = cmDensity1(:, 1, :, i);
end

for i = 1:240  
    cmDensity2(:, 21, :, i) = cmDensity2(:, 1, :, i);
end

data1lon_corrected = data1lon;
data2lon_corrected = data2lon;
data3lon_corrected = data3lon;
data4lon_corrected = data4lon;
data5lon_corrected = data5lon;
PhoenixLong_corrected = PhoenixLong;

%changing all negative values of longitude to positive in 0 to 360 scale
for t = 1:length(data1lon_corrected)
    if data1lon_corrected(t) < 0 
        data1lon_corrected(t) = 360 + data1lon_corrected(t) ;
    end
end


for t = 1:length(data2lon_corrected)
    if data2lon_corrected(t) < 0 
        data2lon_corrected(t) = 360 + data2lon_corrected(t) ;
    end
end

for t = 1:length(data3lon_corrected)
    if data3lon_corrected(t) < 0 
        data3lon_corrected(t) = 360 + data3lon_corrected(t) ;
    end
end

for t = 1:length(data4lon_corrected)
    if data4lon_corrected(t) < 0 
        data4lon_corrected(t) = 360 + data4lon_corrected(t) ;
    end
end

for t = 1:length(data5lon_corrected)
    if data5lon_corrected(t) < 0 
        data5lon_corrected(t) = 360 + data5lon_corrected(t) ;
    end
end

for t = 1:length(PhoenixLong_corrected)
    if PhoenixLong_corrected(t) < 0 
        PhoenixLong_corrected(t) = 360 + PhoenixLong_corrected(t) ;
    end
end

figure

% first set of INMS data
subplot(2,5,1)
contourf(cmLon2, cmLat, squeeze(cmDensity1(:,:,63,10)), 50) %cmat2 contour map
hold on
scatter(PhoenixLong_corrected(1:200), PhoenixLat(1:200)) %satellite path
hold on
plot(data1lon_corrected, data1lat, 'g*') %INMS data
xlabel('Longitude')
ylabel('Latitude')
title('15th of January at 1 UT')

% second set of INMS data
subplot(2,5,2)
contourf(cmLon2, cmLat, squeeze(cmDensity1(:,:,63,130)), 50) %cmat2 contour map
hold on
scatter(PhoenixLong_corrected(2136:2336), PhoenixLat(2136:2336)) %satellite path
hold on
plot(data2lon_corrected, data2lat, 'g*') %INMS data
xlabel('Longitude')
ylabel('Latitude')
title('16th of January at 13 UT')

% third set of INMS data
subplot(2,5,3)
contourf(cmLon2, cmLat, squeeze(cmDensity1(:,:,63,230)), 50)
hold on
scatter(PhoenixLong_corrected(4121:4320), PhoenixLat(4121:4320))
hold on
plot(data3lon_corrected, data3lat, 'g*')
xlabel('Longitude')
ylabel('Latitude')
title('17th of January at 23 UT')

% forth set of INMS data
subplot(2,5,4)
contourf(cmLon2, cmLat, squeeze(cmDensity1(:,:,63,90)), 50)
hold on
scatter(PhoenixLong_corrected(4802:5001), PhoenixLat(4802:5001))
hold on
plot(data4lon_corrected, data4lat, 'g*')
xlabel('Longitude')
ylabel('Latitude')
title('26th of January at 9 UT')

% fifth set of INMS data
subplot(2,5,5)
contourf(cmLon2, cmLat, squeeze(cmDensity2(:,:,63,150)), 50)
hold on
scatter(PhoenixLong_corrected(6604:6802), PhoenixLat(6604:6802))
hold on
plot(data5lon_corrected, data5lat, 'g*')
xlabel('Longitude')
ylabel('Latitude')
title('10th of February at 15 UT')


colorbar %shows the colorbar for contour plots

%INMS counts plotted against time 

subplot(2,5,6)
plot(time1,data1)
hold on
scatter(time1, data1, 'g*')
xlabel('Time/ min')
ylabel('Counts')
title('15th of January')

subplot(2,5,7)
plot(time2,data2)
hold on
scatter(time2, data2, 'g*')
xlabel('Time/ min')
ylabel('Counts')
title('16th of January')

subplot(2,5,8)
plot(time3,data3)
hold on
scatter(time3, data3, 'g*')
xlabel('Time/ min')
ylabel('Counts')
title('17th of January')

subplot(2,5,9)
plot(time4,data4)
hold on
scatter(time4, data4, 'g*')
xlabel('Time/ min')
ylabel('Counts')
title('26th of January')

subplot(2,5,10)
plot(time5,data5)
hold on
scatter(time5, data5, 'g*')
xlabel('Time/ min')
ylabel('Counts')
title('10th of February')


end
