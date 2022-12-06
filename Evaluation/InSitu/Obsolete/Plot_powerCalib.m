close all
clear all
clc


%%
basedir = 'F:\Measurements\PowerMeasurement\20200701_170854_Split_FullPower';

d = dir(basedir);

removeFirst = 10;

%get Size Measurement
for i=1:length(d)
    if ~isempty(regexp(d(i).name, '.calib'))
        tempData = readPowerCalib(fullfile(basedir, d(i).name));
        break
    end
end

counter = 0;
for i=1:length(d)
    if ~isempty(regexp(d(i).name, '.calib'))
        counter = counter + 1;
    end
end

powerArray = NaN(counter, length(tempData));
counter = 0;
for i=1:length(d)
    if ~isempty(regexp(d(i).name, '.calib'))
        counter = counter + 1;
        powerArray(counter,:) = readPowerCalib(fullfile(basedir, d(i).name));
    end
end
        
        
        
%%
powerArray = powerArray(:, 1+removeFirst:end);
        
powerMean = mean(powerArray, 2);        
average = mean(abs(diff(powerMean)));
disp(average)
        
        
        
        
        
        
        