function EISCATdata = plottingEISCATData(EISCATdensity, error, cmatDensityArray)

%Function to plot EISCAT data (EISCATdensity) and it's uncertainties
%(error) together with CMAT2 density data for the same date and height

%generating CMAT2 data
cmat_eiscat = squeeze(cmatDensityArray(85, 1, 58, :));


timeEiscat = [1 : 0.5 : 20];
timeCmat = [0.1 : 0.1 : 24];
%timeCmat = [1 : 1 : 24]; % use for total mass density CMAT2 data with frequency
%of 60min

%Plotting the graph
figure

plot(timeCmat, cmat_eiscat, 'rx-') %plotting CMAT2 data
hold on
errorbar(timeEiscat, EISCATdensity, error) %plotting EISCAT data and uncertainties for EISCAT

xlabel('Time of the Day/ hours')
ylabel("Total Mass Density/ kg/m^3")
title('Comparison Between EISCAT Data from 27/01/2017 and CMAT2 Data from 01/01/2017')
xlim([0 24])
