%% Changelog
% v06
% - renewed time smoothing and time correction
% - read speed values from comments file
% - correct Time first removed due to new speed evaluation not making any
% sense any more
% v03
%   added time correction

%%
% clc;
close all
% clear all
%%
MeasCounter = 0;
basedir = 'C:\Users\Cerberus\Desktop\Calibration\InSitu\Speed'; % Dateipfad zu ordner
fname = '20220325_151739_TestCalib_Z00_meas.spin';
cellName = 'Z04';

tempPos = regexp(fname,'_');
tempFname = fname(tempPos(2)+1:end);
fname = replaceBetween(fname, tempPos(end-1)+1, tempPos(end)-1, cellName);
% fNameSaveStart = [cellName '_' fNameSaveStart];

%% Correct for fname date
correctedPath = correctPathForDate(fullfile(basedir, fname));
splitter = regexp(correctedPath,filesep);

% basedir = pathstring(1:splitter(end));
fname = correctedPath(splitter(end)+1:end);
% disp(['fname: ' fname])

%% 
smoothFFT = 1;
[spinCoatingMode, tempSpeedValues] = getSpeedValues(fullfile(basedir, fname));
speedValue = tempSpeedValues(:,1)'/60;
speedValueTimes = [0 tempSpeedValues(:,2)'];
for i=length(speedValueTimes):-1:1
    speedValueTimes(i) = sum(speedValueTimes(1:i));
end

% for override
% speedValue = [4000 3000]/60;
% speedValueTimes = [0 45 1000];

timeRangeFFT = [3 3 1]; % Defines area for FFT [TimeAreaStart+x, TimeAreaEnd-y, Length for FFT] 
wlDetectFFT = [800]*1e-9; %wavelength for fft
speedRangeValueDivider = 12; % 


%%
createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 1;    % which speed area should be used
referenceTimeBefore = 2;    % Time before taking the reference
referenceTime = 3;          % Time for taking reference




%% Import Data
[spectra, time, wl, ref, dark, startTime] = readSpinCoater(fullfile(basedir,fname));  %liest die Spektren ein
spectra = squeeze(spectra); % entfernt eine Dimension
dark = squeeze(dark);
ref = squeeze(ref);
time = time-time(1);            % rechnet die Zeit um
time = time/1e5;                % rechnet die Zeit um
time = time-startTime;          % rechnet die Zeit um

% %% Saturation Detection
% refMax = max(ref, [], 'all');
% disp(['Reference Max: ' num2str(refMax)])
% spectraMax = max(spectra, [], 'all');
% disp(['Spectra Max: ' num2str(spectraMax)]);
% disp('  ');
% 
% if (refMax < 2^16 && spectraMax < 2^16)
%     disp('Saturation OK')
% else
%     disp('Saturation Problem!')
%     disp('Check Data!');
% end

%% Detect Speeds via FFT
if smoothFFT
    for i=1:length(speedValue)
        tempSpeedList = [];
        tempSpeedListFit = [];
        indCounter = 1;
        for j = wlDetectFFT
            [~,tempIWL] = min(abs(wl-j));
            for k=speedValueTimes(i)+timeRangeFFT(1):timeRangeFFT(3):speedValueTimes(i+1)-timeRangeFFT(2)
                [~,tempILow] = min(abs(time-k));
                [~,tempIHigh] = min(abs(time-(k+timeRangeFFT(3))));
                [f_FFT, p_FFT] = plotFFT(time(tempILow:tempIHigh), ...
                    spectra(tempIWL, tempILow:tempIHigh),1,1, 'plot', 'off');
                
                [~,indSpeedMin] = min(abs(f_FFT-(speedValue(i)-speedValue(i)/speedRangeValueDivider)));
                [~,indSpeedMax] = min(abs(f_FFT-(speedValue(i)+speedValue(i)/speedRangeValueDivider)));
                [~,ind] = max(p_FFT(indSpeedMin:indSpeedMax));
                ind = ind + indSpeedMin -1;
                tempSpeedList(indCounter) = f_FFT(ind);

                tempFit = fit(f_FFT', p_FFT', 'gauss1', 'StartPoint', [max(p_FFT(indSpeedMin:indSpeedMax)) , f_FFT(ind), 1],...
                    'Lower', [0 300/60 0], 'Upper', [1e8 100 30]);
                tempSpeedListFit(indCounter) = tempFit.b1;
                indCounter = indCounter+1;

%                 close(5001)
%                 close(5002)
            end
        end
%         speedValue(i) = median(tempSpeedList);
    end
end

%% Detect Speeds via FFT with Smoothing
% if smoothFFT
%     for i=1:length(speedValue)
%         tempSpeedListFitSmooth = [];
%         indCounter = 1;
%         for j = wlDetectFFT
%             [~,tempIWL] = min(abs(wl-j));
%             timeSpeedListFitSmooth = speedValueTimes(i)+timeRangeFFT(1):0.1:speedValueTimes(i+1)-timeRangeFFT(2);
%             for k=timeSpeedListFitSmooth
%                 [~,tempILow] = min(abs(time-(k-timeRangeFFT(3)/2)));
%                 [~,tempIHigh] = min(abs(time-(k+timeRangeFFT(3)/2)));
%                 [f_FFT, p_FFT] = plotFFT(time(tempILow:tempIHigh), ...
%                     spectra(tempIWL, tempILow:tempIHigh),1,1, 'plot', 'off');
%                 
%                 [~,indSpeedMin] = min(abs(f_FFT-(speedValue(i)-speedValue(i)/speedRangeValueDivider)));
%                 [~,indSpeedMax] = min(abs(f_FFT-(speedValue(i)+speedValue(i)/speedRangeValueDivider)));
%                 [~,ind] = max(p_FFT(indSpeedMin:indSpeedMax));
%                 ind = ind + indSpeedMin -1;
% 
%                 tempFit = fit(f_FFT', p_FFT', 'gauss1', 'StartPoint', [max(p_FFT(indSpeedMin:indSpeedMax)) , f_FFT(ind), 1],...
%                     'Lower', [0 300/60 0], 'Upper', [1e8 100 30]);
%                 tempSpeedListFitSmooth(indCounter) = tempFit.b1;
%                 indCounter = indCounter+1;
% %                 close(5001)
% %                 close(5002)
%             end
%         end
% %         speedValue(i) = median(tempSpeedList);
%     end
% end

%% Detect Speeds via nFFT
if smoothFFT
    for i=1:length(speedValue)
        tempSpeedList = [];
        tempSpeedListnFit = [];
        indCounter = 1;
        for j = wlDetectFFT
            [~,tempIWL] = min(abs(wl-j));
            for k=speedValueTimes(i)+timeRangeFFT(1):timeRangeFFT(3):speedValueTimes(i+1)-timeRangeFFT(2)
%                 disp(k)
                [~,tempILow] = min(abs(time-k));
                [~,tempIHigh] = min(abs(time-(k+timeRangeFFT(3))));
                signal = spectra(tempIWL, tempILow:tempIHigh);
                tt = time(tempILow:tempIHigh);
                if mod(length(signal),2) ~= 0 
                    signal = signal(1:end-1);
                    tt = tt(1:end-1);
                end

                dt = median(diff(tt));
                f = linspace(-1/(2*dt),1/(2*dt),length(tt)+1);
                f = f(1:end-1);
                L = length(f);
                Y = nufft(signal-mean(signal), tt, f);
                P2 = abs(Y/L);
                P3 = fftshift(P2);
                P1 = P3(1:L/2+1);
                fShift = fftshift(f);
                fShift = abs(fShift(1:L/2+1));
     

                tempFit = fit(fShift', P1', 'gauss1', 'StartPoint', [max(p_FFT(indSpeedMin:indSpeedMax)) , f_FFT(ind), 1],...
                    'Lower', [0 300/60 0], 'Upper', [1e8 100 30]);
                tempSpeedListnFit(indCounter) = tempFit.b1;
                indCounter = indCounter+1;
            end
        end
%         speedValue(i) = median(tempSpeedList);
    end
end

%%
for i=1:length(speedValue)
    disp(['Section ' num2str(i) ': ' num2str(speedValue(i)*60) 'rpm'])
end

% plot(tempSpeedList*60);

if ~ishandle(205)
    figure(205)
    plot([timeRangeFFT(1), speedValueTimes(end)-speedValueTimes(end-1)-timeRangeFFT(2)], [speedValue(end) speedValue(end)]*60, 'LineWidth', 2)
end
hold on
plot([timeRangeFFT(1):timeRangeFFT(3):speedValueTimes(end)-speedValueTimes(end-1)-timeRangeFFT(2)] + timeRangeFFT(3)/2,...
    tempSpeedListFit*60, 'LineWidth', 2);
plot([timeRangeFFT(1):timeRangeFFT(3):speedValueTimes(end)-speedValueTimes(end-1)-timeRangeFFT(2)] + timeRangeFFT(3)/2,...
    tempSpeedListnFit*60, 'LineWidth', 2);
% plot(timeSpeedListFitSmooth, tempSpeedListFitSmooth*60, 'LineWidth',2)

ylabel('Rotation Speed in rpm')
xlabel('Time in s')

set(gca, 'Linewidth', 2, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)

disp(['Speed Value Median FFT: ' num2str(median(tempSpeedListFit)*60)])
disp(['Speed Value Median nFFT: ' num2str(median(tempSpeedListnFit)*60)])

% disp(['Speed Value Mean FFT: ' num2str(mean(tempSpeedListFit)*60)])
% disp(['Speed Value Mean nFFT: ' num2str(mean(tempSpeedListnFit)*60)])

disp(['average: ' num2str(mean([median(tempSpeedListFit)*60, median(tempSpeedListnFit)*60]))])
    
