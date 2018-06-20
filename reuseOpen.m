function f  = reuseOpen()
addpath(pwd) ;
Files = dir(pwd);
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

    ValidF = [];
    minTime = 10000000000;
    
    NumDates = length(Dates) ;
for no = 1 : NumDates
    
    % Date of folder
    DateSub = num2str(cell2mat(Dates(no)));
        
    % Change directory to the folder containing the data
    cd(DateSub) ;
    
    
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
    
    % Importing the data from the text file
    while ~feof(fid)
        % Get the line from the file
        tline = fgets(fid);
        %Split the line by space
        Line = strsplit(tline) ;
        
        % Check if the cells are empty
        tf1empty = isempty(Line{1,1}) ;
        tf2empty = isempty(Line{1,2}) ;
        Condition = tf1empty + tf2empty ;
        
        if Condition == 0
            % Find the date and time the data was taken.
            Date = Line{1,1} ;
            TimeRange = Line{1,2} ;
            % Convert time into numbers
            TimeSplit = strsplit(TimeRange,'-') ;
            DateNumStart = datenum(TimeSplit{1,1},'HH:MM:SS') ;
            DateNumFinal = datenum(TimeSplit{1,2},'HH:MM:SS') ;
            if minTime > DateNumStart
                minTime = DateNumStart;
            end
            
        end
    end
    % Close the file
    fclose(fid);
    disp(minTime);
    f = minTime;
    cd('..');
end
