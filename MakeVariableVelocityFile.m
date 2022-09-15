clear
clc

format long
 
name = 'Well 9 with offset';
Run = 'Run #1';
t = 'May 2018';
name2 = ' V No BW No Flushing with Error';
name3 = ' Q No BW No Flushing with Error';
axesLabels = datenum(2017,11:5,1,0,0,0);

% path = ['C:/Users/cgeorge/Google Drive/Research/MATTSI Output/South Carolina Wells/' name '/' Run '/'];
path = ['C:\Users\jvincent\Desktop\Charleston Wells Project\1Dtemppro\MATTSI\Well 9 with offset\Run #2\'];

inpath = [path '\Output\'];
out = exist([path '/V/'],'dir');
if out == 0
    mkdir([path '/V/']);
end

count = 0;
files = ls([inpath '*_O*']);
%files = ls([inpath '*_O*']);
time = importdata([inpath files(1,:)]);
time = time(:,1);
RMSE = zeros(length(time),5);

for i = 1:length(time)
    disp(i)
    
    err = 5.0;
    
    for j = 1:size(files,1)
        
        fid = fopen([inpath files(j,:)]);
        parts = strsplit(files(j,:),'_');
        output = textscan(fid,'%f %f %f',1,'Delimiter',',','HeaderLines',i-1);
        if output{1,3} < err
            dates = output{1};
            Dint = output{2};
            err = output{3};
            V = str2double(parts{4}(2:end));
            HD = str2double(parts{5}(3:5))/100;
%             if HD > 0.01
%                 kk = log(2)./output{3};
%                 Dint = (output{2}./kk).*(1-exp(-10*kk));
%             else
%                 Dint = 0;
%             end

        end
        fclose(fid);
        
    end
    
    RMSE(i,:) = [dates,V,HD,Dint,err];
    
end
dlmwrite([path '/V/' name name2 '.txt'],RMSE,'delimiter',',','precision',15);
% dlmwrite(['C:/Users/cgeorge/Google Drive/Research/Data/South Carolina Wells/' t '/V/' name name2 '.txt'],RMSE,'delimiter',',','precision',15);

% RMSE = dlmread(['C:/Users/cgeorge/Google Drive/Research/Data/South Carolina Wells/' t '/V/' name name2 '.txt']);
subplot(3,1,1)
plot(RMSE(:,1),RMSE(:,2),'LineWidth',1.5)
ylabel('Velocity (m/yr)','FontSize',16)
title(name,'FontSize',16)
set(gca,'Xtick',axesLabels,'YDir','Reverse','FontSize',14);
datetick('x',' ','keeplimits','keepticks')
axis([RMSE(1,1) RMSE(end,1) -40 50])

subplot(3,1,2)
plot(RMSE(:,1),RMSE(:,3),'LineWidth',1.5)
ylabel('Half-Depth (m)','FontSize',16)
set(gca,'Xtick',axesLabels,'FontSize',14);
datetick('x',' ','keeplimits','keepticks')
axis([RMSE(1,1) RMSE(end,1) 0 1.0])

a = subplot(3,1,3);
plot(RMSE(:,1),RMSE(:,5),'LineWidth',1.5)
ylabel('RMSE','FontSize',16)
xlabel('Date','FontSize',16)
set(gca,'Xtick',axesLabels,'FontSize',14);
datetick('x','mm/dd','keeplimits','keepticks')
axis([RMSE(1,1) RMSE(end,1) 0 0.1])
rotateXLabels(a,45)

print([path '/V/' name name2 '.tiff'],'-dtiff');
% print(['H:/cgeorge/Research/Data/South Carolina Wells/' t '/V/' name name2 '.tiff'],'-dtiff');

Time = cellstr(datestr(time,'mm/dd/yyyy HH:MM:SS'));
Q = [Time,num2cell((RMSE(:,2)/31557600)*0.3)];
cell2csv([path '/V/' name name3 '.csv'],Q,',');