file = uigetfile;
var = 'nden3d';

cmArrayDen = [];
cmArrayVMR = [];
cmArrayFinal = [];
ncArray = ncread(file,var);
interpArray = [];
ncArrayVMR = ncread('neutralVMR27.nc','O-vmr');
heightFinal = [];
newArray = ncArray .* ncArrayVMR;
heightFile = ncread('neutralHeight27.nc','ht3d') ./ 1000;   
dimensions = size(ncArray);
time_dim   = dimensions(4)        ;   % 4th element is always time in NC
height_dim = dimensions(3)        ;   % allows for different height resolutions
for i = 1:time_dim
    for j = 1:height_dim   % gory detail:
        cmArrayDen(:,:,j,i) = fliplr(rot90(ncArray(:,:,j,i),3));
        %cmArrayVMR(:,:,j,i) = fliplr(rot90(ncArrayVMR(:,:,j,i),3));
        cmArrayFinal(:,:,j,i) = fliplr(rot90(newArray(:,:,j,i),3));
        heightFinal(:,:,j,i) = fliplr(rot90(heightFile(:,:,j,i),3));
    end
end
cmLat = ncread(file, 'latitude')    ;
cmLon = ncread(file, 'longitude')   ;
cmPres = ncread(file, 'pressure_level') ./ 100 ;
cmTime = ncread(file, 'time') ./ 60;

interpArray = [];
%cmArrayDen;cmLat;cmLon;cmPres;cmTime = netcdfCmat2(file,var);

excel = xlsread('Final Project - All Data.xlsx');
time = [];

lat1 = excel(:,1);
lon1 = excel(:,2);
data1 = excel(:,3);
time1 = excel(:,4);

lat2 = excel(:,5);
lon2 = excel(:,6);
data2 = excel(:,7);
time2 = excel(:,8);

lat3 = excel(:,9);
lon3 = excel(:,10);
data3 = excel(:,11);
time3 = excel(:,12);

lat4 = excel(:,13);
lon4 = excel(:,14);
data4 = excel(:,15);
time4 = excel(:,16);

lat5 = excel(:,17);
lon5 = excel(:,18);
data5 = excel(:,19);
time5 = excel(:,20);

PhoenixLat = excel(:,21);
PhoenixLon = excel(:,22);

%time1c = time1(~isnan(time1));
%time2c = time2(~isnan(time2));
time3c = time3(~isnan(time3));

%time4c = time4(~isnan(time4));

%time = [time time1c time2c time3c time4c];
%finalTime = time(:);
heightRange = (15:10:300);
%cmDen1,cmDen2] = find_dens_interp_ao(time5,data5,time2,lat5,lon5,ncArray,cmLat,cmLon,cmTime);

interpArray = interpCmat(cmArrayFinal,heightFinal,heightRange);
%plottingINMSData(time1, data1, lon1, lat1, time2, data2, lon2, lat2, time3, data3,lon3, lat3, time4, data4, lon4, lat4, time5, data5, lon5, lat5, PhoenixLon, PhoenixLat, cmArrayFinal, cmArrayFinal, cmLon, cmLat);
