% Plot Calibration

%%
clear all
close all
clc 

%% 
pathToData = 'F:\Measurements\SpectraMeasurement\20200731_105019_451-650nm';
tempFileList = dir(pathToData);

%% IMPORT Measurement Settings
fid = fopen(fullfile(pathToData, 'Settings_Calib.txt'));
tempData = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

tempData = tempData{1};


for i=1:length(tempData)
    if ~isempty(regexp(tempData{i}, '# Measurements', 'once'))
        break
    end
end
tempPosition = regexp(tempData{i}, '\t');
numberMeasurements = str2num(strrep(tempData{i}(tempPosition+1:end), ',', '.'));

for i=1:length(tempData)
    if ~isempty(regexp(tempData{i}, 'Exposure Time', 'once'))
        break
    end
end
tempPosition = regexp(tempData{i}, '\t');
exposureTime = str2num(strrep(tempData{i}(tempPosition+1:end-1), ',', '.')); %-1 to remove unit


for i=1:length(tempData)
    if ~isempty(regexp(tempData{i}, 'Wavelength', 'once'))
        break
    end
    if ~isempty(regexp(tempData{i}, 'Wavelenght', 'once')) % to correct for old data, where wavelength was misspelled
        break
    end
end
tempPosition = regexp(tempData{i}, '\t');
wavelengthStart = str2num(strrep(tempData{i}(tempPosition(1)+1:tempPosition(2)-2), ',', '.'));
wavelengthStop = str2num(strrep(tempData{i}(tempPosition(3)+1:tempPosition(4)-2), ',', '.'));
wavelengthStep = str2num(strrep(tempData{i}(tempPosition(5)+1:end-1), ',', '.'));
measuredWavelength = wavelengthStart:wavelengthStep:wavelengthStop;


for i=1:length(tempData)
    if ~isempty(regexp(tempData{i}, 'AverageSpectra', 'once'))
        break
    end
end
averageSpectra = 0;
tempPosition = regexp(tempData{i}, '\t');
if ~isempty(regexp(tempData{i}(tempPosition+1:end), 'T', 'once'))
    averageSpectra = 1;
end


%% import wavelength
fid = fopen(fullfile(pathToData, 'wavelength.dat'));
siz = [2^32 2^16 2^8 1]';
dim = sum(fread(fid, 4).*siz);
wavelength = fread(fid, dim, 'double', 0, 'ieee-be')*1e9;
fclose(fid);


%% Get maximum number of spectra
counter = 0;
for i=1:length(tempFileList)
    if ~isempty(regexp(tempFileList(i).name, 'SpectroData'))
        counter = counter+1;
    end
end

dataPoints = counter/2/numberMeasurements;


%%
maxCounts = NaN(counter/2,1);
maxPower = NaN(counter/2,1);
for i=1:dataPoints
%     disp(i)
% f1 = figure(1);
% set(f1, 'Position', [680 678 560 420])
% f2 = figure(2);
% set(f2, 'Position', [1483 666 560 420]);
    for j=1:numberMeasurements
        currentNumber = ((i-1)*numberMeasurements*2)+(j-1)*2;
%         powerOn = mean(readPowerCalib(fullfile(pathToData,...
%             ['PowerData_' num2str(currentNumber, '%05d') '.calib'])));
        powerOn = readPowerCalib(fullfile(pathToData,...
            ['PowerData_' num2str(currentNumber, '%05d') '.calib']));
%         powerOn = mean(powerOn(end-5:end));
        if averageSpectra
            spectraOff = readSpectraCalibAveraged(fullfile(pathToData, ...
                ['SpectroData_' num2str(currentNumber, '%05d') '.calib']));
        else
            %spectraOff = readSpectraCalib(fullfile(pathToData, ...
             %   ['SpectroData_' num2str(currentNumber, '%05d') '.calib']));
            %to be implemented
        end
        currentNumber = ((i-1)*numberMeasurements*2)+(j-1)*2+1;
%         powerOff = mean(readPowerCalib(fullfile(pathToData,...
%             ['PowerData_' num2str(currentNumber, '%05d') '.calib'])));
        powerOff = readPowerCalib(fullfile(pathToData,...
            ['PowerData_' num2str(currentNumber, '%05d') '.calib']));
%         powerOff = mean(powerOff(end-5:end));
        if averageSpectra
            spectraOn = readSpectraCalibAveraged(fullfile(pathToData, ...
                ['SpectroData_' num2str(currentNumber, '%05d') '.calib']));
        else
            %spectraOn = readSpectraCalib(fullfile(pathToData, ...
             %   ['SpectroData_' num2str(currentNumber, '%05d') '.calib']));
            %to be implemented
        end
        overallPower = max(powerOn-powerOff);
        overallSpectra = spectraOn-spectraOff;
        
        % fit spectra
        f = fit(wavelength, overallSpectra, 'gauss1',...
            'StartPoint', [max(overallSpectra), measuredWavelength(i)*1e9, 1]);
        coeffvals = coeffvalues(f);
       
        counts = sqrt(pi)*coeffvals(1)*abs(coeffvals(3));
        powerWavelength = overallPower/(sqrt(pi)*abs(coeffvals(3)));
        maxCounts((currentNumber-1)/2+1) = coeffvals(1);
        maxPower((currentNumber-1)/2+1) = overallPower/(sqrt(pi)*abs(coeffvals(3)));
        
        disp([num2str(coeffvals(2)) '\t' num2str(overallPower) '\t' num2str(counts)])
        
%         figure(1)
%         plot(powerOn)
%         hold on
%         figure(2)
%         plot(powerOff)
%         hold on
    end
%     pause
    close all
end


%%
maxCountsAvg = NaN(length(maxCounts)/numberMeasurements,1);
maxPowerAvg = NaN(length(maxCounts)/numberMeasurements,1);
for i=1:length(maxCountsAvg)
    maxCountsAvg(i) = mean(maxCounts((i-1)*numberMeasurements+1:(i-1)*numberMeasurements+numberMeasurements));
    maxPowerAvg(i) = mean(maxPower((i-1)*numberMeasurements+1:(i-1)*numberMeasurements+numberMeasurements));
end


efficiency = maxPowerAvg./maxCountsAvg;
plot(measuredWavelength(1:end), efficiency)
