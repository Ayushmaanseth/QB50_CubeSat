% ----- Deriving Neutral Densities During Cusp Upwellings -----



% Notes:
% =================================================================
% The script below analyses data from the EISCAT Svalbard Radar 42m.
% To run this script only two additional function are required.
% Functions: Leys and St Maurice. Needs to stored in the same directory
% as this script.
% This script should be placed in the directory above the data.
% The script can only analyse data from the ESR in a .txt format
% The script imports data from a text file that must have the same
% type of format seen in the instruction booklet.
% The script can only import data from the FPI in a .dat format.
% The script will automatically import the data from a directory.
% The txt and dat files should be stored in the same directory.
% Please ensure there is only one txt file and dat file in the folder.
% The data should be stored in folders by date the data were taken.
% Only folders containing the data that needs to be imported
% should be placed in the directory with the script.
% Data is stored in a struct called Results.
% Colour Plots of altitude, time and density are produced.
%
% Method used to calculate the neutral density:
% Vickers, Kosch, Sutton, Ogawa, La Hoz. (2013). Thermospheric atomic oxygen
% density estimates using the EISCAT Svalbard Radar. JOURNAL OF GEOPHYSICAL
% RESEARCH: SPACE PHYSICs. 118, pp. 1319?1330.
%
% Method used to remove outliers:
% Leys et al. (2013). Detecting outliers: Do not use standard deviation
% around the mean, use absolute deviation around the median. Journal of
% Experimental Social Psychology. 49 (4), 764 - 766.
%
% Method to determine ion velocities:
% St Maurice et al. (1982). Ion Frictional Heating at High Latitudes and
% Its Possible Use for an In Situ Determination of Neutral Thermospheric
% Winds and Temperatures. 87, 7580 - 7602.
% =================================================================

% Clear Command Line
clc ;

% Close all open figures
close all ;

% Clear all variables
clearvars ;

% Turn off warnings
warning('off','all');

% Add path to find required functions
addpath(pwd) ;

% Current Directory
Files = dir(pwd);

% User Inputs:

% Name of Data
% Question for window
Nprompt = {'Name of new dataset (no spaces):   '} ;
% Title of window
Ndlg_title = 'Data Name';
% Example parameters
defaultans = {'run1'};
% Popup window
NameInput = inputdlg(Nprompt,Ndlg_title, [1 100], defaultans) ;
% Variable
DataName = cell2mat(NameInput) ;

% Ensure name entered does not have a space.
% Check to see if there are spaces in the string
validName = isspace(DataName) ;
maxName = max(validName) ;
while maxName == 1
    f = warndlg('Name cannot have spaces!', 'Warning!!!');
    drawnow
    waitfor(f);
    Nprompt = {'Name of new dataset (no spaces):   '} ;
    Ndlg_title = 'Data Name';
    defaultans = {'run1'};
    NameInput = inputdlg(Nprompt,Ndlg_title, [1 100], defaultans) ;
    DataName = cell2mat(NameInput) ;
    validName = isspace(DataName) ;
    maxName = max(validName) ;
end

% Height Range inputs
% Displays a box
Hprompt = {'Min Height:','Step:', 'Max Height:'} ;
Hdlg_title = 'Enter height range (km):';
defaultans = {'300', '50', '400'};
HeightInput = inputdlg(Hprompt,Hdlg_title, [1 100],defaultans);
MinH = str2num(cell2mat(HeightInput(1))) * 1000 ;
MaxH = str2num(cell2mat(HeightInput(3))) * 1000 ;
Step = str2num(cell2mat(HeightInput(2))) * 1000 ;

% Warnings to ensure correct input
% Ensures the max height is always greater than the min height
% Ensure the heights do not match.
while MinH >= MaxH
    f = warndlg('Min height cannot be greater or equal to max height!', 'Warning!!!');
    drawnow
    waitfor(f);
    Hprompt = {'Min Height:','Step:', 'Max Height:'} ;
    Hdlg_title = 'Enter height range (km):';
    defaultans = {'300', '50', '400'};
    HeightInput = inputdlg(Hprompt,Hdlg_title, [1 100], defaultans);
    MinH = str2num(cell2mat(HeightInput(1))) * 1000 ;
    MaxH = str2num(cell2mat(HeightInput(3))) * 1000 ;
    Step = str2num(cell2mat(HeightInput(2))) * 1000 ;
end

% Ensure these variables are not left blank
while isempty(MinH) || isempty(MaxH)  || isempty(Step)
    f = warndlg('These fields cannot be left blank!', 'Warning!!!');
    drawnow
    waitfor(f);
    Hprompt = {'Min Height:','Step:', 'Max Height:'} ;
    Hdlg_title = 'Enter height range (m):';
    HeightInput = inputdlg(Hprompt,Hdlg_title, [1 100]);
    MinH = str2num(cell2mat(HeightInput(1)));
    MaxH = str2num(cell2mat(HeightInput(3)));
    Step = str2num(cell2mat(HeightInput(2)));
end

% Ensure these variables are not negative
while MinH < 0 || MaxH < 0  || Step < 0
    f = warndlg('Cannot have negative values!', 'Warning!!!');
    drawnow
    waitfor(f);
    Hprompt = {'Min Height:','Step:', 'Max Height:'} ;
    Hdlg_title = 'Enter height range (m):';
    HeightInput = inputdlg(Hprompt,Hdlg_title, [1 100]);
    MinH = str2num(cell2mat(HeightInput(1)));
    MaxH = str2num(cell2mat(HeightInput(3)));
    Step = str2num(cell2mat(HeightInput(2)));
end

% Time Range Inputs
Tprompt = {'Start:', 'Step', 'Final:'} ;
Tdlg_title = 'Enter time range (0 - 23.9 hours):';
defaultans = {'7', '1', '10'} ;
TimeInput = inputdlg(Tprompt,Tdlg_title, [1 100], defaultans);
TI = str2num(cell2mat(TimeInput(1)));
TF = str2num(cell2mat(TimeInput(3)));
TStep = str2num(cell2mat(TimeInput(2)));

% Warnings to ensure correct input
% Ensures the final time is always greater than the intial time
% Ensure the times do not match.
while TI >= TF
    f = warndlg('Intial time cannot be greater or equal to final time!', 'Warning!!!');
    drawnow
    waitfor(f);
    Tprompt = {'Start:', 'Step', 'Final:'} ;
    Tdlg_title = 'Enter time range (0 - 23.9 hours):';
    defaultans = {'0.5', '1', '23.5'} ;
    TimeInput = inputdlg(Tprompt,Tdlg_title, [1 100], defaultans);
    TI = str2num(cell2mat(TimeInput(1)));
    TF = str2num(cell2mat(TimeInput(3)));
    TStep = str2num(cell2mat(TimeInput(2)));
end

% Ensure the variables are not left blank
while isempty(TI) || isempty(TF)  || isempty(TStep)
    f = warndlg('These fields cannot be left blank!', 'Warning!!!');
    drawnow
    waitfor(f);
    Tprompt = {'Start:', 'Step', 'Final:'} ;
    Tdlg_title = 'Enter time range (0 - 23.9 hours):';
    defaultans = {'0.5', '1', '23.5'} ;
    TimeInput = inputdlg(Tprompt,Tdlg_title, [1 100], defaultans);
    TI = str2num(cell2mat(TimeInput(1)));
    TF = str2num(cell2mat(TimeInput(3)));
    TStep = str2num(cell2mat(TimeInput(2)));
end

% To ensure time is within a day
while TI < 0 || TF > 24
    f = warndlg('Hours out of range', 'Warning!!!');
    drawnow
    waitfor(f);
    Tprompt = {'Start:', 'Step', 'Final:'} ;
    Tdlg_title = 'Enter time range (0 - 23.99 hours):';
    defaultans = {'0.5', '1', '23.5'} ;
    TimeInput = inputdlg(Tprompt,Tdlg_title, [1 100], defaultans);
    TI = str2num(cell2mat(TimeInput(1)));
    TF = str2num(cell2mat(TimeInput(3)));
    TStep = str2num(cell2mat(TimeInput(2)));
end

% Ensure these variables are not negative
while TI < 0 || TStep < 0  || TF < 0
    f = warndlg('Cannot have negative values!', 'Warning!!!');
    drawnow
    waitfor(f);
    Hprompt = {'Min Height:','Step:', 'Max Height:'} ;
    Hdlg_title = 'Enter height range (m):';
    HeightInput = inputdlg(Hprompt,Hdlg_title, [1 100]);
    MinH = str2num(cell2mat(HeightInput(1)));
    MaxH = str2num(cell2mat(HeightInput(3)));
    Step = str2num(cell2mat(HeightInput(2)));
end


InputTimeInNum = datenum(TI+":0:0");
minTimePossible = reuseOpen();

while minTimePossible > InputTimeInNum
    f = warndlg('The data for the following time frame is not available, please enter a new time frame');
    drawnow
    waitfor(f);
    Tprompt = {'Start:', 'Step', 'Final:'} ;
    Tdlg_title = 'Enter time range (0 - 23.99 hours):';
    defaultans = {'0.5', '1', '23.5'} ;
    TimeInput = inputdlg(Tprompt,Tdlg_title, [1 100], defaultans);
    TI = str2num(cell2mat(TimeInput(1)));
    TF = str2num(cell2mat(TimeInput(3)));
    TStep = str2num(cell2mat(TimeInput(2)));
    InputTimeInNum = datenum(TI+":0:0");
end

% Number of dates (number of directories)to be processed
% Which objects in the folder are directories
validDir = [Files.isdir] ;
Directories = Files(validDir) ;
All_Dates = arrayfun(@(x) x.name,Directories,'uni',false) ;
% Remove directories starting with .
ADLen = length(All_Dates) ;
ADN = 1 ;
for AD = 1 : ADLen(1)
    % For each folder in the directory find the name
    fname = num2str(cell2mat(All_Dates(AD)));
    fnameLen = length(fname) ;
    % Separate the name of the file into its separate chars
    for fn = 1:fnameLen(1)
        fchar(fn) = fname(fn) ;
    end
    % If the 1st char is not a . add to date
    if strcmp(fchar(1),'.') == 0
        Dates(ADN) = All_Dates(AD) ;
        ADN = ADN + 1 ;
    end
end

% Start of calculations
% The calculations will be run separately for each date
% Number of dates to analyse
NumDates = length(Dates) ;
for no = 1 : NumDates
    
    % Date of folder
    DateSub = num2str(cell2mat(Dates(no)));
        
    % Change directory to the folder containing the data
    cd(DateSub) ;
    
    % Display which folder is being processed
    disp(['Processing - ' DateSub]) ;
    
    % Find the text file in the directory
    Alltxt = dir('*.txt') ;
    % Ignore file that begins with a .
    Anumfiles = length(Alltxt);
    ADN = 1 ;   
    
    %disp(isvector(Anumfiles)); -> Uncomment for debugging
    
    for AD = 1 : Anumfiles(1)
        fname = Alltxt(AD).name;
        % Separate the file name into chars
        fnameLen = length(fname) ;
        for fn = 1
            fchar(fn) = fname(fn) ;
        end
        % Logical array created to find where
        if strcmp(fchar(1),'.') == 0
            ValidF(AD) = 1 ;
        else
            ValidF(AD) = 0 ;
        end
    end
    % Filter for valid files
    ValidF = logical(ValidF') ;
    % Valid Files
    Datatxt = Alltxt(ValidF);
    
    % Import txt data
    % Open the file
    fid = fopen(Datatxt.name);
    
    % Index so data from the file is stored appropiately
    index = 1 ;
    TindexS = 1 ;
    TindexF = 43 ;
    
    % Information to user
    disp('Importing Data:') ;
    
    % Information to user
    disp(['Importing - ' Datatxt.name ' from ' DateSub]) ;
    
    % Importing the data from the text file
    while ~feof(fid)
        % Get the line from the file
        tline = fgets(fid);
        %Split the line by space
        Line = strsplit(tline) ;
        disp(Line{1,2});
        % Check if the cells are empty
        tf1empty = isempty(Line{1,1}) ;
        tf2empty = isempty(Line{1,2}) ;
        Condition = tf1empty + tf2empty ;
        % If tf1 is empty and tf2 is not
        % Line contains the variables
        if Condition == 1
            % Altitude
            Alt(index) = str2num(Line{1,2}) ;
            % Electron Density
            NeLog(index) = str2num(Line{1,3}) ;
            % Electron temperature
            Te(index) = str2num(Line{1,4}) ;
            % Ion Temperature
            Ti(index) = str2num(Line{1,5}) ;
            % Ion Velocity
            Vo(index) = str2num(Line{1,6}) ;
            % Electron density error
            dNeLog(index) = str2num(Line{1,7});
            % Electron temperature error
            dTe(index) = str2num(Line{1,8}) ;
            % Ion temperature error
            dTi(index) = str2num(Line{1,9}) ;
            % Ion velocity error
            dVo(index) = str2num(Line{1,10}) ;
            index = index + 1 ;
            % If tf1 and tf2 are not empty
            % Line contains time and date information
        elseif Condition == 0
            % Find the date and time the data was taken.
            Date = Line{1,1} ;
            TimeRange = Line{1,2} ;
            % Convert time into numbers
            TimeSplit = strsplit(TimeRange,'-') ;
            DateNumStart = datenum(TimeSplit{1,1},'HH:MM:SS') ;
            DateNumFinal = datenum(TimeSplit{1,2},'HH:MM:SS') ;
            % Average time found as time in file is given as a range
            TimeAvg = 0.5 * (DateNumStart + DateNumFinal)  ;
            % Reformat the time
            TimeFormatted = datestr(TimeAvg, 'HH:MM:SS') ;
            % Store the time by hour, minute and second
            Hoursplit = strsplit(TimeFormatted,':') ;
            hour(TindexS:TindexF) = str2num(cell2mat(Hoursplit(1,1)));
            min(TindexS:TindexF) = str2num(cell2mat(Hoursplit(1,2))) ;
            sec(TindexS:TindexF) = str2num(cell2mat(Hoursplit(1,3))) ;
            % Index
            TindexS = TindexS + 43 ;
            TindexF = TindexF + 43 ;
        end
    end
    % Close the file
    fclose(fid);
    
    % Information to user
    disp(['Import Complete - ' Datatxt.name ' from ' DateSub]) ;
    
    % Import Tn Temperatures
    % Find the dat file in the directory
    AllDat = dir('*.dat') ;
    % Ignore file that begins with a .
    Anumfiles = length(AllDat);
    ADN = 1 ;
    for AD = 1 : Anumfiles(1)
        fname = AllDat(AD).name;
        % Separate the file name into chars
        fnameLen = length(fname) ;
        for fn = 1
            fchar(fn) = fname(fn) ;
        end
        % Logical array created to find where
        if strcmp(fchar(1),'.') == 0
            ValidF(AD) = 1 ;
        else
            ValidF(AD) = 0 ;
        end
    end
    % Filter for valid files
    ValidF = logical(ValidF') ;
    % Valid Files
    DataDat = AllDat(ValidF);
    
    % Information to user
    disp(['Importing - ' DataDat.name ' from ' DateSub]) ;
    
    % Importing .dat file from FPI
    FPI = dlmread(DataDat.name, '', 13, 0) ;
    
    % Information to user
    disp(['Import Complete - ' DataDat.name ' from ' DateSub]) ;
    disp('Import Complete') ;
    
    % All data imported stored in one struct for easy access
    % Altitude
    Data.gdalt = Alt' ;
    % Electron density
    Data.Ne = NeLog' ;
    % Ion temperature
    Data.Ti = Ti' ;
    % Electron temperature
    Data.Te = Te' ;
    % Time in the FPI
    Data.TnTime = FPI(:,1) ;
    % Neutral temperature
    Data.Tn = FPI(:, 7) ;
    %Ion velocity
    Data.Vo = Vo' ;
    % Electron density error
    Data.dNe = dNeLog' ;
    % Ion temperature error
    Data.dTi = dTi' ;
    % Electron temperature error
    Data.dTe = dTe' ;
    % Neutral temperature error
    Data.dTn = FPI(:, 8) ;
    % Ion velocity error
    Data.dVo = dVo' ;
    % Date when the data was taken
    Data.Date = Date ;
    % Hour of day
    Data.hour = hour' ;
    % Minute of hour
    Data.min = min' ;
    % Second of minute
    Data.sec = sec' ;
    % UT time
    Data.ut = (hour + (min/60) + (sec/3600))' ;
    
    % Defining the structure the results will be stored in
    Results = struct ;
    
    % These indexs are for creating the matrix at the end of the script.
    % The matrix is used to stored the data so a grid can be plotted.
    
    indexi = 1 ;
    
    % Time
    for i = TI:TStep:TF
        
        % Info to user
        disp(['Started processing hour ' num2str(i) ' on ' Date ]) ;
        
        % Constants
        mass = 2.66e-26 ;
        dmass = 6.6421557e-31 ;
        k = 1.38e-23 ;
        dk = 0.00000079e-23 ;
        
     
        % Filtering for valid time
        validTime = (Data.ut <= i + TStep/2) & (Data.ut >= i - TStep/2) ;
        % Removes all NaN values
        validNe = ~isnan(Data.Ne) & ~isnan(Data.dNe);
        validT = ~isnan(Data.Ti) & ~isnan(Data.Te) & ~isnan(Data.dTi) & ~isnan(Data.dTe) ;
        validAlt = ~isnan(Data.gdalt) ;
        validV0 = ~isnan(Data.Vo) ;
        validData = validTime & validNe & validT & validV0 & validAlt ;
        
        % Variables with invalid data removed
        Ne = Data.Ne(validData) ;
        Ne = 10.^(Ne) ;
        dNe = Data.dNe(validData) ;
        Ti = Data.Ti(validData) ;
        dTi = Data.dTi(validData) ;
        Te = Data.Te(validData) ;
        dTe = Data.dTe(validData) ;
        Alt = Data.gdalt(validData) * 1000 ;
        Vo = Data.Vo(validData) ;
        dVo = Data.dVo(validData) ;
        ut = Data.ut(validData) ;
        
        % Calculation of equation 1 in Vickers et al 2013
        % This calculates the ion collison frequency
        % Calculation of 2nd part of eq 1
        T = Ti + Te ;
        dT = sqrt(dTi.^2 + dTe.^2) ;
        
        f = k .* Ne .* T ;
        df = sqrt(((k .* T).^2 .* dNe.^2) + ((Ne .* T).^2 .* dk.^2) + ((Ne .* k).^2 .* dT.^2)) ;
        
        % Removal of outliers using the Leys 2013 Method
        validOutliers = Leys(f);
        Ne = Ne(validOutliers) ;
        dNe = dNe(validOutliers) ;
        Ti = Ti(validOutliers) ;
        dTi = dTi(validOutliers) ;
        Te = Te(validOutliers) ;
        dTe = dTe(validOutliers) ;
        Alt = Alt(validOutliers) ;
        Vo = Vo(validOutliers) ;
        dVo = dVo(validOutliers) ;
        df = df(validOutliers) ;
        f = f(validOutliers) ;
        ut = ut(validOutliers) ;
        
        % Calculation of the gradient in eq 1
        % Plot altitude against pressure
        optionspNe = fitoptions;
        % Calculated errors are taken into account when determining the fit
        optionspNe.Weights = df ;
        disp(optionspNe.Weights);
        % Polyfit 5 added
        [pNefit, gof] = fit(Alt, f,'poly5', optionspNe) ;
        subplot(2,1,1);
        plot(pNefit, Alt, f) ;
        title( ['Plasma Pressure against Altitude at hour ' num2str(i) ' on ' Data.Date ], 'fontsize', 14) ;
        xlabel('Altitude (m)', 'fontsize', 12) ;
        ylabel('Plasma Pressure (pa)', 'fontsize', 12) ;
        pause;
        
        subplot(2,1,2);
        % Plot of residuals also shown
        plot(pNefit, Alt, f,'Residuals') ;
        title('Residuals', 'fontsize', 14) ;
        xlabel('x', 'fontsize', 12) ;
        ylabel('y', 'fontsize', 12) ;
        % Polyfit coefficents from calculated curve
        pNeCoeff = [pNefit.p1  pNefit.p2  pNefit.p3  pNefit.p4  pNefit.p5 pNefit.p6] ;
        % The equation of the gradient of the fit calculated
        Der = polyder(pNeCoeff) ;
        
        % Index for matrix where results are stored
        % Calculations continued for height analysis
        indexH = 1;
        for H = MinH:Step:MaxH
            
            % Valid height range
            validgdAlt = (Alt <= H + Step/2) & (Alt >= H  - Step/2) ;
            
            % Variables with valid altitude
            Nez = Ne(validgdAlt)  ;
            dNez = dNe(validgdAlt) ;
            Tiz = Ti(validgdAlt) ;
            dTiz = dTi(validgdAlt) ;
            Tez = Te(validgdAlt) ;
            dTez = dTe(validgdAlt) ;
            Voz = Vo(validgdAlt) ;
            dVoz = dVo(validgdAlt) ;
            Altz = Alt(validgdAlt);
            utz = ut(validgdAlt);
            
            % Find the value of the gradient at a point
            grad = polyval(Der,Altz) ;
            % Error on the gradient
            dgrad = gof.rmse ;
            
            % Gravity acceleration at the altitude
            g = 9.81 * (6371000./(6371000 + Altz)).^2 ;
            
            % Continuation of equation 1 from Vickers et al 2013
            Dom = (Nez .* mass) ;
            Vin2 = grad ./ Dom ;
            sinI = sind(82) ;
            Vin1 = ((g .* sinI) + Vin2) ;
            % Ion collision frequency
            Vin = Vin1 ./Voz ;
            Vin = abs(Vin) ;
            
            % Calcuation of equation 2 in Vickers et al 2013
            % Additional input of the neutral temperature
            % Can no longer assume Ti = Tn as conditions are not quiet
            % Also isotropy can no longer be assumed so Ti =! Ti||
            % A factor of 1.7 is used.
            validTnTime = (Data.TnTime <= i + 0.25) & (Data.TnTime >= i - 0.25) ;
            Tn = Data.Tn(validTnTime) ;
            Tn = mean(Tn) ;
            Tiz = 1.7 * Tiz ;
            Tiz = mean(Tiz) ;
            n_D1 = (1 - (0.064 .* log10(0.5 .* (Tn + Tiz)))).^ 2 ;
            n_D = 3.67e-17 .* (0.5 .* (Tn + Tiz)).^ 0.5 .* n_D1 ;
            % Neutral density
            n = Vin ./n_D ;
            
            % Removal of infinte data and outliers
            validn = isfinite(n) ;
            nfinal = n(validn & Leys(n));
            Nez = Nez(validn & Leys(n));
            Voz = Voz(validn & Leys(n));
            
            % Results stored in a matrix
            nfinalmed = median(nfinal) ;
            JouleHeating(indexH,indexi) = median(Nez.^2 .* (StMaurice(Tiz).^2)) ;
            Density(indexH,indexi) = nfinalmed ;
            LogDensity(indexH,indexi) = log10(nfinalmed) ;
            ElectronDensity(indexH,indexi) = median(Nez) ;
            VelocityIons(indexH,indexi) = median(StMaurice(Tiz)) ;
            VinA(indexH,indexi) = median(Vin) ;
            ATn(indexH,indexi) = median(Tn) ;
            ATi(indexH,indexi) = median(Ti) ;
            ATe(indexH,indexi) = median(Te) ;
            
            % Indexes for matrix
            indexH = indexH + 1 ;
            
        end
        % Indexes for matrix
        indexi = indexi + 1 ;
        
        % Information to user
        disp(['Completed processing hour ' num2str(i) ' on ' Data.Date]) ;
    end
    
    % Close all open figures
    close all ;
    
    % Stored the data in the results struct under the date the data was taken
    % The name will be the name in the folder
    % x is used as the name cannot begin with a number
    x = 'x' ;
    % This variable is put at the front of the folder name
    v = [x DateSub] ;
    
    % Storing the data in the results struct
    Results.(v).Density = Density ;
    Results.(v).Name = DataName ;
    Results.(v).Sub = DateSub ;
    Results.(v).JouleHeating = JouleHeating;
    Results.(v).ElectronDensity = ElectronDensity ;
    Results.(v).VelocityIons = abs(VelocityIons) ;
    Results.(v).Date = Date ;
    Results.(v).Time = TI:TStep:TF  ;
    Results.(v).TimeStep = TStep ;
    Results.(v).Height = MinH:Step:MaxH  ;
    Results.(v).HeightStep = Step ;
    Results.(v).LogDensity = LogDensity ;
    Results.(v).TempNeutral = ATn ;
    Results.(v).TempIon = ATi ;
    Results.(v).Tempelec = ATe ;
    Results.(v).Vin = VinA ;
    % So to easily find varibles
    Results.(v) = orderfields(Results.(v)) ;
    
    % Close all open figures
    close all;
    
    % Generate graphs
    % Density against time and altitude
    figure;
    % Colour Plot
    W = imagesc(Results.(v).LogDensity) ;
    NameND = title([DataName ' Log Neutral Density ' Results.(v).Date], 'fontsize', 14) ;
    ylabel('Altitude (km)', 'fontsize', 12) ;
    xlabel('Time (hours)', 'fontsize', 12) ;
    set(gca,'YDir','normal','YTick', 1 :length(MinH:Step:MaxH), 'YTickLabel', (MinH:Step:MaxH)/1000 , 'XTick', 1 : length(TI:TStep:TF), 'XTickLabel', TI:TStep:TF);
    cD = colorbar ;
    cD.Label.String = 'Log Density (1/m^3)' ;
    cD.FontSize = 12 ;
    % Save image as a jpeg
    saveas(gcf,[DataName '_Log_Neutral_Density_' Results.(v).Date],'jpeg') ;
    % Save image as a fig
    saveas(gcf,[DataName '_Log_Neutral_Density_' Results.(v).Date],'fig') ;
    
    % Joule Heating against time and altitude
    figure ;
    X = imagesc(Results.(v).JouleHeating) ;
    NameJH = title([DataName ' Proportional Joule Heating ' Results.(v).Date], 'fontsize', 14) ;
    ylabel('Altitude (km)', 'fontsize', 12) ;
    xlabel('Time (hours)', 'fontsize', 12) ;
    set(gca,'YDir','normal','YTick', 1 :length(MinH:Step:MaxH), 'YTickLabel', (MinH:Step:MaxH)/1000 , 'XTick', 1 : length(TI:TStep:TF), 'XTickLabel', TI:TStep:TF);
    cH = colorbar ;
    cH.Label.String = 'Proportional Joule Heating (J)';
    cH.FontSize = 12 ;
    saveas(gcf,[DataName '_Proportional_Joule_Heating_' Results.(v).Date],'jpeg') ;
    saveas(gcf,[DataName '_Proportional_Joule_Heating_' Results.(v).Date],'fig') ;
    
    % Electron density against time and altitude
    figure ;
    Y = imagesc(Results.(v).ElectronDensity) ;
    NameED = title([DataName ' Electron Density ' Results.(v).Date], 'fontsize', 14) ;
    ylabel('Altitude (km)', 'fontsize', 12) ;
    xlabel('Time (hours)', 'fontsize', 12) ;
    set(gca,'YDir','normal','YTick', 1 :length(MinH:Step:MaxH), 'YTickLabel', (MinH:Step:MaxH)/1000 , 'XTick', 1 : length(TI:TStep:TF), 'XTickLabel', TI:TStep:TF);
    cH = colorbar ;
    cH.Label.String = 'Electron Density (1/m^3)';
    cH.FontSize = 12 ;
    saveas(gcf,[DataName '_Electron_Density_' Results.(v).Date],'jpeg') ;
    saveas(gcf,[DataName '_Electron_Density_' Results.(v).Date],'fig') ;
    
    % Ion velocity against time and altitude
    figure ;
    Z = imagesc(Results.(v).VelocityIons) ;
    NameVI = title([DataName ' Ion Velocity ' Results.(v).Date], 'fontsize', 14) ;
    ylabel('Altitude (km)', 'fontsize', 12) ;
    xlabel('Time (hours)', 'fontsize', 12) ;
    set(gca,'YDir','normal','YTick', 1 :length(MinH:Step:MaxH), 'YTickLabel', (MinH:Step:MaxH)/1000, 'XTick', 1 : length(TI:TStep:TF), 'XTickLabel', TI:TStep:TF);
    cH = colorbar ;
    cH.Label.String = 'Ion Velocity (m/s)';
    cH.FontSize = 12 ;
    saveas(gcf,[DataName '_Ion_Velocity_' Results.(v).Date],'jpeg') ;
    saveas(gcf,[DataName '_Ion_Velocity_' Results.(v).Date],'fig') ;
    
    % Neutral temperature against time and altitude
    figure;
    Z = imagesc(Results.(v).TempNeutral) ;
    NameTn = title([DataName ' Tn ' Results.(v).Date], 'fontsize', 14) ;
    ylabel('Altitude (km)', 'fontsize', 12) ;
    xlabel('Time (hours)', 'fontsize', 12) ;
    set(gca,'YDir','normal','YTick', 1 :length(MinH:Step:MaxH), 'YTickLabel', (MinH:Step:MaxH)/1000 , 'XTick', 1 : length(TI:TStep:TF), 'XTickLabel', TI:TStep:TF);
    cH = colorbar ;
    cH.Label.String = 'Tn (k)';
    cH.FontSize = 12 ;
    saveas(gcf,[DataName '_Tn_' Results.(v).Date],'jpeg') ;
    saveas(gcf,[DataName '_Tn_' Results.(v).Date],'fig') ;
    
    % Ion temperature against time and altitude
    figure;
    Z = imagesc(Results.(v).TempIon) ;
    NameTi = title([DataName ' Ti ' Results.(v).Date], 'fontsize', 14) ;
    ylabel('Density(1/m^3)', 'fontsize', 12) ;
    xlabel('Time (hours)', 'fontsize', 12) ;
    set(gca,'YDir','normal','YTick', 1 :length(MinH:Step:MaxH), 'YTickLabel', (MinH:Step:MaxH)/1000 , 'XTick', 1 : length(TI:TStep:TF), 'XTickLabel', TI:TStep:TF);
    cH = colorbar ;
    cH.Label.String = 'Ti (k)';
    cH.FontSize = 12 ;
    saveas(gcf,[DataName '_Ti_' Results.(v).Date],'jpeg') ;
    saveas(gcf,[DataName '_Ti_' Results.(v).Date],'fig') ;
    
    % Close all open figures
    close all ;
    
    % Information to user
    disp(['Processing - ' DateSub ' Complete']) ;
    fprintf(1, '\n');
    
    % Return back to original directory
    cd('../') ;
    
end

% Close all other windows
close all ;

% Save data in directory where this script is contained
save(DataName, 'Results') ;

% Clear all variables
clearvars ;

% Reload only required variables
% find the files in the directory
Data = dir('*.mat') ;
% Find the number of files in the directory.
numMat = length(Data) ;
x = 0 ;
% Find the most recently created .mat file
for i = 1: numMat
    if datenum(Data(i).date) > x ;
        x = datenum(Data(i).date) ;
        y = i ;
    end
end
% Load the most recently created .mat file
FileMat = Data(y).name ;
load (FileMat) ;

% Clear extra variables for clarity
clear x ;
clear i ;
clear y ;
clear numMat ;
clear Data ;

% Info to user
finalmess = msgbox('     Calculation Completed!     ','Success!');
drawnow
waitfor(finalmess);
clear finalmess ;

