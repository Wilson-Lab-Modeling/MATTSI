function FScript(outfile,T_outfile,InputArray,V,HD,DoCap)
% This program solves the advection-dispersion equation (Crank-Nicholson finite
% difference scheme), assigning specified T at the top (bottom water temperature)
% and specified T at the bottom (Temp from lowest instrument).
format long g

%Unpack array of variables from the InputArray made in the Input.m script
obsDepths = InputArray{1};
T = InputArray{2};
dx = InputArray{3};
dt = InputArray{4};
FunctionTolerance = InputArray{5};
xTolerance = InputArray{6};
previous = InputArray{7};
interval = InputArray{8};
lambdaStar = InputArray{9};
denom = InputArray{10};
  
date = T(1,1):datenum(0,0,0,0,20,0):T(length(T)-1,1);
T = T(:,2:end);

%Unit conversion variables
secondsPerHour = 3600;

intph = 60/interval;
intervalLength = secondsPerHour/intph;  % convert to find the length of the interval in secs
numTimeSteps = floor(intervalLength/dt);   % This is the number of time steps in an interval

numNodes = length(dx) + 1;
X = NaN(1,length(numNodes));
X(1) = 0;
for i = 2:numNodes
    X(i) = X(i-1) + dx(i-1);
end
diff = X - obsDepths(end);
tolerance = 0.001;
diff(abs(diff) < tolerance) = 0;
diff(diff < 0) = inf;
index = find(diff == min(diff));

Tinit = interp1(obsDepths,T(1,:),X(1:index),'pchip');

%Optimization Parameter Set Up
D = lambdaStar/denom;  %dispersion coefficient

% Observation nodes
obsNodes = dsearchn(X',obsDepths');
numNodes = length(Tinit);
logflag = 0;

cOld = Tinit'; %intial conditions
V = V/31536000;

%Set up initial guess and bounds (Vector to guess is called Dohd (Do, and halfdepth))
firstGuess = [0 0];    % [Do (m2/yr*conversion) halfdepth (m)]
lowerBound = [0 0];
upperBound = [DoCap*lambdaStar/denom HD];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time loop -- go in 1 hr chunks
startHour = 0;                       
kStart = startHour*intph*numTimeSteps;   %kstart is in time steps. hrs * intervals/hr *timesteps/interval

numIntervals = floor(length(T)/numTimeSteps);  %number of optimization intervals 
Dint = NaN(1,numIntervals);
err = NaN(1,numIntervals);
T_array = NaN(numNodes,numIntervals);

for i = 1:numIntervals

    if i == 1
        
        disp(V*31536000)
        disp(HD)
        
    end
    
    cBC1(1:numTimeSteps) = T(kStart+1:kStart+numTimeSteps,1); %Bottom water temperatures for this interval
    cBC2(1:numTimeSteps) = T(kStart+1:kStart+numTimeSteps,end); %Temperature from the lowest logger  ****

    [vDohd,RMSEval] = TMinRMSE2(D,cBC1,cBC2,cOld,T,dx,numNodes,dt,numTimeSteps,obsNodes,kStart,firstGuess,lowerBound,upperBound,V,X,logflag,FunctionTolerance,xTolerance);
    
    Doplot = vDohd(1)*denom/lambdaStar;
    halfdplot = vDohd(2);
    kk = log(2)./halfdplot;
    Dint(i) = (Doplot./kk).*(1-exp(-10*kk));
    
    err(i) = RMSEval;
    
    %Calculate the T profile using the halfdepth that you just got
    c = SolTransFE2(D,vDohd,V,cBC1,cBC2,cOld,dx,numNodes,dt,numTimeSteps,X);

    % Update cold and kstart for the beginning of the next time interval
    cOld = c;
    kStart = kStart+numTimeSteps;
    
    %previous = 1 uses previous timestep; else resets to first_guess
    if(previous == 1) 
       firstGuess = vDohd;
    end

    T_array(:,i) = c;
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Time Loop

% Narrow down the temperature array to the depths that match the obsDepths
T_array = T_array([1,obsNodes'],:);

% Save the results
dlmwrite(outfile,[date' Dint' err'],'delimiter',',','precision',15)
dlmwrite(T_outfile,[date' T_array'],'delimiter',',','precision',15)