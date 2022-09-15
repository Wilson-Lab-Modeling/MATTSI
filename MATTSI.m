format long g

% Read in the temperature data from the input file
[TemperatureData,time] = xlsread([inpath name ext]);
Time = zeros(length(time)-1,1);
for i = 2:length(time)
    Time(i-1) = datenum(time(i,:));
end

%This section determines the observation depths and subtracts the logger
%offset from the original data if use indicates it
if BW == 0
    obsDepths = TemperatureData(1,:) -  depthShift;
    TemperatureData = TemperatureData(2:end,:);
    if E == 1  
        Error = repmat(Error(:,2:end),length(TemperatureData),1);
        TemperatureData = TemperatureData - Error;
    end
elseif BW == 1
    obsDepths = TemperatureData(1,2:end) - depthShift;
    TemperatureData = TemperatureData(2:end,2:end);
    if E == 1
        Error = repmat(Error(:,2:end),length(TemperatureData),1);
        TemperatureData = TemperatureData - Error;
    end
else
    obsDepths = TemperatureData(1,:);
    TemperatureData = TemperatureData(2:end,:);
    if E == 1
        Error = repmat(Error,length(TemperatureData),1);
        TemperatureData = TemperatureData - Error;
    end
end

TemperatureData = [Time,TemperatureData];

%Define Variables for smoothing, interpolation, and parameterization
timestep = datevec(TemperatureData(2,1)-TemperatureData(1,1));
obsph = 60/(timestep(4)*60+timestep(5)+timestep(6)/60); %observations per hour
windowSize = (windowSize*obsph)+1; % number of observations in the moving average
stepsize = dt/86400; %one minute, in days
lambdaStar = lambdaf^poros*lambdas^(1-poros);
denom = poros*rhof*cf + (1-poros)*rhos*cs;

%Smooth the data: helps remove noise from errors
TemperatureData = filter(ones(1,windowSize)/windowSize,1,TemperatureData,[],1);
TemperatureData = TemperatureData(windowSize:end,:);

%Interpolate data set
TData = interp1(TemperatureData(:,1),TemperatureData,TemperatureData(1,1):stepsize:TemperatureData(end,1));

%Write smoothed/interpolated data set to file
dlmwrite([outpath 'Output/' name '_' datestr(TemperatureData(1,1),'mm-dd-yyyy') '_T.txt'],TData,'delimiter',',','precision',15)

%Definte cell array of variables to send into FScript
InputArray = {obsDepths,TData,dx,dt,FunctionTolerance,xTolerance,previous,interval,lambdaStar,denom};

%Do the runs
for i = 1:length(V)

    for j = 1:length(HD)
        
        if HD(j) == 0.01
            DoCap = 0;
        else
            DoCap = 500;
        end

        close all
        file = ['V' sprintf('%03d',V(i)) '_HD' sprintf('%03d',HD(j)*100) '.txt'];
        OF = [outpath 'Output/' name '_' datestr(TemperatureData(1,1),'mm-dd-yyyy') '_Output_' file];
        T_OF = [outpath 'Output/' name '_' datestr(TemperatureData(1,1),'mm-dd-yyyy') '_TOutput_' file];

        FScript(OF,T_OF,InputArray,V(i),HD(j),DoCap);

    end

end