clear
clc

mo_yr = 'May 2017';
name = 'Stake 11 MATTSI';
ext = '.csv';
Run = 'Run #3';
V = -25:25;  %m/yr -- Just the first guess for v
HD = 0.01;  %meters; This is a constant for the whole simulation (and the value doesn't matter if DoCap = 0)
lambdas = 2.0; %W/m.degC, sand grains.
BW = 1; %BW = 0 if you don't have BW data;BW = 1 if you do have BW data and don't want to use it;BW = 2 if you do have BW data and want to use it
depthShift = 0.125; %m (Only need to worry about this if BW = 0 or 1)
E = 0; %E = 1 if you do want to subtract the offset from the original data file
Error = [0,0,0,0,0,0,0]; %Get from Offset excel file

%Where the data file is located
inpath = ['C:\Users\jvincent\Desktop\Charleston Wells Project\1Dtemppro\MATTSI\' mo_yr '/'];

%Where all output files and plots will be saved
outpath = ['C:\Users\jvincent\Desktop\Charleston Wells Project\1Dtemppro\MATTSI\' name '/' Run '/'];

%Make directories if they don't already exist
out2 = exist([outpath 'Output\'],'dir');
if out2 == 0
    mkdir([outpath 'Output\']);
end

%Single parameters that don't change with time (or with iterations)
previous = 0; %If previous = 1, use previous time step results as firstguess. Else, use firstguess for every time step
interval = 20.0; %minutes
dt = 60; %seconds
FunctionTolerance = 1E-06;
xTolerance = 1E-06;

%Single parameters that are used in calculations and don't need to be passed directly into the model runs
poros = 0.3;
rhof = 1025; %kg/m3
cf = 3993;   %J/kg.degC (seawater at 20 degC)
rhos = 1920; %kg/m3
cs = 1170;   %J/kg.degC
lambdaf = 0.596; %W/m.K, water

dx(1:10) = 0.01;  %10 cm
dx(11:26) = 0.025; %50 cm
dx(27:34) = 0.0625; %1 m
dx(35:48) = 0.125; %2.75 m

windowSize = 12; %number of hours in the moving average for smoothing

run MATTSI