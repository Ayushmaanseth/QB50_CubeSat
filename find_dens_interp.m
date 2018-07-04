function [density_interp_2d, density_interp_3d] = find_dens_interp_ao(time5, data5, time, latitude, longitude, arrayDen, cmLat, cmLon, cmTime)

%  This function takes in the latitude and longitude of the satellite as
% well as density (arrayDen) matrix to calculate density of the atmosphere
% that corresponds to the satellite's path
% e.g. >> INMSdata = plottingINMSData(time1, data1, lon1_2, lat1_2, time2, data2, lon2_2, lat2_2, time3, data3, lon3_2, lat3_2, time4, data4, lon4_2, lat4_2, time5, data5, lon5_2, lat5_2, PhoenixLong6, PhoenixLat6, cmNumDensityO, cmNumDensityO, cmLon2, cmLat2)

% For 16th of February 2018 Unix time is 25313760

%changing negative longitude to positive values
longitude3 = longitude;

for t = 1:length(longitude3)
    if longitude3(t) < 0 
        longitude3(t) = 360 + longitude3(t) ;
    end
end


% selecting time, latitude and longitude of the satellite for the times
% that match cmat2 model

n = 6; %Frequency of CMAT2 data (in min)
time2 = time(1 : n : end);
time3 = time2 + 25313760; %Atomic Oxygen 16th of Feb 2018
latitude2 = latitude(1: n : end);
longitude2 = longitude(1: n : end);


for t = 1:length(longitude2)
    if longitude2(t) < 0 
        longitude2(t) = 360 + longitude2(t) ;
    end
end

%adjusting contour map format
cmLon2 = cmLon;
cmLon2(21) = 360;

for i = 1:240  
    arrayDen(:, 21, :, i) = arrayDen(:, 1, :, i);
    
end

 %interpolating in 2D and 3D to obtain density values   
    density_interp_2d = interp2(cmLon2, cmLat, arrayDen(:, :, 58, 230), longitude3, latitude);
    density_interp_3d = interp3(cmLon2, cmLat, cmTime, squeeze(arrayDen(:, :, 58, :)), longitude2, latitude2, time3);
    
    
    
   time4 = time3 - 25313760; %16th of Feb 2018
   
   
   %Plotting density predictins against time of the day
   
   figure
   
   subplot(2,1,1)
   
   p1 = scatter(time4, density_interp_3d);
   hold on
   p2 = scatter(time5, data5*10^10, 'g*');
   legend('show')
   hold on
   p3 = plot(time4, density_interp_3d);
   legend([p1 p2],'CMAT2 Data','INMS Data')
   
   title('Atomic Oxygen Number Density for Phoenix Orbit on the 26th of January')
   xlabel('Time of the Day/ min')
   ylabel('Atomic Oxygen Number Density/ m^-3')
   xlim([500 600]) %limits to select range to match INMS data
   
   
   
   subplot(2,1,2)
   plot(time, density_interp_2d)
   hold on
   scatter(time, density_interp_2d)
   title('Atmospheric Density for Phoenix Orbit for the 15th of January (assuming no change in atmosphere with time)')
   xlabel('Time/ min')
   ylabel('Atomic Oxygen Number Density/ m^-3')
   xlim([0 100])
    
   figure
   
   plot(time4, density_interp_3d)
   hold on
   scatter(time4, density_interp_3d)
   hold on
   plot(time, density_interp_2d)
   hold on 
   scatter(time, density_interp_2d)
   legend('show')
   title('Aomic Oxygen Number Density for Phoenix Orbit for the 10th of February')
   xlabel('Time/ min')
   ylabel('Atomic Oxygen Number Density/ m^-3')
   xlim([900 1000])
    

end
