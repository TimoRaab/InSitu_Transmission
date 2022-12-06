%% Changelog

%%
clc;
% close all
clear all
%%
MeasCounter = 0;
lengthTime = 0;

%%
fileList = cell(0);
dummyLength = 0;
axisColor = [];
basedir = 'E:\Measurements\InSitu\SpinCoater\210706';
fileList{end+1} = fullfile(basedir, '20210706_143004_TR_Y6PM6_Reference_B12_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_143004_TR_Y6PM6_Reference_B13_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_143004_TR_Y6PM6_Reference_B14_meas.spin');
axisColor = [axisColor;repmat([1 0 0], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);

% basedir = 'E:\Measurements\InSitu\SpinCoater\210628';
% fileList{end+1} = fullfile(basedir, '20210706_143855_TR_Y6PM6_Reference_45ul_B15_meas.spin');
% fileList{end+1} = fullfile(basedir, '20210706_143855_TR_Y6PM6_Reference_45ul_B16_meas.spin');
axisColor = [axisColor;repmat([0.7 0 0], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% 
% basedir = 'E:\Measurements\InSitu\SpinCoater\210526';
fileList{end+1} = fullfile(basedir, '20210706_144442_TR_Y6PM6_Additiv_15ul_B17_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_144442_TR_Y6PM6_Additiv_15ul_B18_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_144442_TR_Y6PM6_Additiv_15ul_B19_meas.spin');
% fileList{end+1} = fullfile(basedir, '20210526_121922_TR_Y6PM6_Test_N16_meas.spin');
% fileList{end+1} = fullfile(basedir, '20210526_121922_TR_Y6PM6_Test_N17_meas.spin');
axisColor = [axisColor;repmat([0 0 1], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% 
% 
% % basedir = 'E:\Measurements\InSitu\SpinCoater\210526';
fileList{end+1} = fullfile(basedir, '20210706_145853_TR_Y6PM6_Y6First_B22_Y6_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_150317_TR_Y6PM6_Y6First_B23_Y6_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_150651_TR_Y6PM6_Y6First_B24_Y6_meas.spin');
axisColor = [axisColor;repmat([0 1 0], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% 
% % basedir = 'E:\Measurements\InSitu\SpinCoater\210526';
fileList{end+1} = fullfile(basedir, '20210706_151038_TR_Y6PM6_PM6First_B25_PM6_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_151425_TR_Y6PM6_PM6First_B26_PM6_meas.spin');
fileList{end+1} = fullfile(basedir, '20210706_151806_TR_Y6PM6_PM6First_B27_PM6_meas.spin');
axisColor = [axisColor;repmat([1 0 1], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% 
basedir = 'E:\Measurements\InSitu\SpinCoater\210618';
fileList{end+1} = fullfile(basedir, '20210618_132216_TR_Y6PM6_A23_Y6_First_Y6_meas.spin');
fileList{end+1} = fullfile(basedir, '20210618_132632_TR_Y6PM6_A16_Y6_First_Y6_meas.spin');
axisColor = [axisColor;repmat([0 1 1], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% 
fileList{end+1} = fullfile(basedir, '20210618_133050_TR_Y6PM6_A20_PM6_First_PM6_meas.spin');
fileList{end+1} = fullfile(basedir, '20210618_133500_TR_Y6PM6_A24_PM6_First_PM6_meas.spin');
axisColor = [axisColor;repmat([0 0 0], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);

%%
wlRange = [410e-9 895e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-120 130]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 726 820]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
timePlot = [1:5:20];

timeRangeFFT = [-15 -5]; %Zeitbereich f�r die FFT (hier soll das Spektrum konstant sein)
wlDetectFFT = 550e-9; % Wellenl�nge, f�r welche die FFT bestimmt wird
speedRangeFFT = [1000 5000]/60; % Bereich der Rotationsgeschwindigkeit, in welcher gesucht wird

timeDetectLowerThreshold= 0.3;
timeDetectUpperThreshold = 0.95;
timeDetectWavelength = 550e-9;
timeDetectSkipNSeconds = 5;


%%
createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 2;    % which speed area should be used
referenceTimeBefore = 1;    % Time before taking the reference
referenceTime = 3;          % Time for taking reference


%%
transTimed = 0;
for qq=1:length(fileList)
%%

%% Correct for fname date
fileList{qq} = correctPathForDate(fileList{qq});
fname = fileList{qq};
disp(['Number ' num2str(qq) ' von ' num2str(length(fileList))])
[spectra, time, wl, ref, dark, startTime] = readSpinCoater(fileList{qq});  %liest die Spektren ein
spectra = squeeze(spectra); % entfernt eine Dimension
dark = squeeze(dark);
ref = squeeze(ref);
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes f�rs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
time = time-time(1);            % rechnet die Zeit um
time = time/1e5;                % rechnet die Zeit um
time = time-startTime;          % rechnet die Zeit um
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));

%% Saturation Detection
refMax = max(ref, [], 'all');
disp(['Reference Max: ' num2str(refMax)])
spectraMax = max(spectra, [], 'all');
disp(['Spectra Max: ' num2str(spectraMax)]);
disp('  ');

if (refMax < 2^16 && spectraMax < 2^16)
    disp('Saturation OK')
else
    disp('Saturation Problem!')
    disp('Check Data!');
end

%%
if (createReferenceSpectrum)
    tempPos = regexp(fname, '_');
    fname_set = [fname(1:tempPos(end)) 'comments.txt'];
    temp_fid = fopen(fname_set);
    temp_set = fscanf(temp_fid, '%c');
    fclose(temp_fid);
    temp_set = strsplit(temp_set, '\n')';

    %check for correct lines to read
    indTimeLower = 1;
    while (isempty(regexp(temp_set{indTimeLower}, 'Speed', 'once'))...
            || isempty(regexp(temp_set{indTimeLower}, 'Time', 'once'))...
            || isempty(regexp(temp_set{indTimeLower}, 'Acceleration', 'once')))
        indTimeLower = indTimeLower+1;
    end

    lowerLimit = indTimeLower+1;

    while (regexp(temp_set{indTimeLower}, '\r') ~= 1)
        indTimeLower = indTimeLower+1;
    end
    upperLimit = indTimeLower-1;

    % if an to big speed section is giving, last section is used
    line4Reference = lowerLimit+referenceTimeSector-1;
    if line4Reference > upperLimit
        line4Reference = upperLimit;
    end

    % get starting time for reference
    time2Reference = 0;
    indTimeLower = 0;
    while (lowerLimit+indTimeLower < line4Reference)
        temp = strsplit(temp_set{lowerLimit+indTimeLower}, '\t');
        time2Reference = time2Reference + str2double(temp{2});
        indTimeLower = indTimeLower+1;
    end

    time2Reference = time2Reference + referenceTimeBefore;

    [~, indTimeRefStart] = min(abs(time-time2Reference));
    [~, indTimeRefStop] = min(abs(time-(time2Reference+referenceTime)));

    %keep old reference for stuff
    refMeasured = ref;
    ref = spectra(:, indTimeRefStart:indTimeRefStop);
end

%%
trans = (spectra-mean(dark,2))./(mean(ref,2)-mean(dark,2)); % Berechnet die Transmission
%trans = trans(indWlMin:indWlMax, indTimeMin:indTimeMax);
% wl = wl(indWlMin:indWlMax);
% time = time(indTimeMin:indTimeMax);
clearvars spectra;

%% timeDetect
[~,indTimeDetectWl] = min(abs(wl-timeDetectWavelength));
[~,indTimeDetect] = min(abs(time-(min(time)+timeDetectSkipNSeconds)));
for indTimeLower=indTimeDetect:length(time)
    if trans(indTimeDetectWl,indTimeLower) < timeDetectLowerThreshold
        break
    end
end
for indTimeUpper=indTimeLower:-1:1
    if (trans(indTimeDetectWl,indTimeUpper) > timeDetectUpperThreshold)
        break
    end
end
time = time - time(indTimeUpper);

%%
[~,indLowFFT] = min(abs(time-min(timeRangeFFT)));
[~,indHighFFT] = min(abs(time-max(timeRangeFFT)));          
[~,indWlFFT] = min(abs(wl-wlDetectFFT));
plotFFT(time(indLowFFT:indHighFFT), trans(indWlFFT,indLowFFT:indHighFFT), 1,1)

f = figure(5002);
xDat = f.Children(1).Children(1).XData;
yDat = f.Children(1).Children(1).YData;
figure(5000);
close
figure(5001);
close
figure(5002);
close

[~,indSpeedMin] = min(abs(xDat-min(speedRangeFFT)));
[~,indSpeedMax] = min(abs(xDat-max(speedRangeFFT)));

[~,ind] = max(yDat(indSpeedMin:indSpeedMax));
ind = ind + indSpeedMin -1;

%% Hier wird ein moving average angewendet
movTime = round(1/xDat(ind)/mean(diff(time(indLowFFT:indHighFFT))));
M = movmean(trans, movTime,2);
R = smoothdata(M,1, 'sgolay', 20);

%%   
R = R(indWlMin:indWlMax,:);
wl = wl(indWlMin:indWlMax);
[~,ind1] = min(abs(time - 0));
[~,ind2] = min(abs(time - 1));

if lengthTime == 0
    lengthTime = ind2-ind1+1;
    timeQ = time(ind1):380e-6:time(ind2);
end


VR = interp2(time(ind1:ind2), wl, R(:,ind1:ind2), timeQ, wl);


if numel(transTimed) ~= length(fileList)*numel(VR)
    transTimed = NaN([length(fileList), size(VR)]);
end
    
transTimed(qq, :, :) = VR;

% if numel(transTimed) ~= length(fileList)*numel(M(:,ind1:ind2))
%     transTimed = NaN([length(fileList), size(M(:,ind1:ind2))]);
% end
%     
% transTimed(qq, :, :) = M(:,ind1:ind2);


end
% % pause
%% Spectra verlauf
figure
for ii=1:1:size(transTimed,3)
    for jj=1:length(fileList)
        plot(wl*1e9, transTimed(jj,:,ii), 'Color', axisColor(jj,:));
%         plot(wl*1e9, transTimed(jj,:,ii));
        hold on
        ylim([0 1])
        xlim([405 890])
    end
title(time(ind1+ii-1))
    hold off
pause(0.05)
end

%% Spectra verlauf normiert
figure
for ii=1:5:size(transTimed,3)
    for jj=1:length(fileList)
        mUp = max(transTimed(jj, :, ii));
        mLow = min(transTimed(jj, :, ii));
        plot(wl*1e9, (transTimed(jj,:,ii)-mLow)./(mUp-mLow), 'Color', axisColor(jj,:));
%         plot(wl*1e9, (transTimed(jj,:,ii)-mLow)./(mUp-mLow));
        hold on
        ylim([0 1])
        xlim([405 890])
    end
title(time(ind1+ii-1))
    hold off
pause(0.05)
end

%% Plot minimum Positions
figure(1000)
figure(1001)
wlSplit = 700;
for jj=1:length(fileList)
    [~,indWlSplit] = min(abs(wl-wlSplit*1e-9));
    [transDataUpper,minPosUpper] = min(transTimed(jj, indWlSplit:end, :), [], 2);
    
    transDataUpper = squeeze(transDataUpper);
    minPosUpper = squeeze(minPosUpper);
    
    figure(1001)
%     yyaxis left
    plot(timeQ, wl(minPosUpper+indWlSplit-1)*1e9,'-', 'Color', axisColor(jj,:));
%     plot(timeQ, wl(minPosUpper+indWlSplit-1)*1e9);
     xlabel('Time in s')
    ylabel('Min Transmission Wavelength in nm');
%     yyaxis right
%     plot(timeQ, transDataUpper,'--', 'Color', axisColor(jj,:));
%     ylabel('Transmission');
    title(['Min Transmission Position above ' num2str(wlSplit) 'nm']);
    hold on
    
    [transDataLower,minPosLower] = min(transTimed(jj, indWlMin:indWlSplit, :), [], 2);
    transDataLower = squeeze(transDataLower);
    minPosLower = squeeze(minPosLower);
    
    figure(1000)
%     yyaxis left
    plot(timeQ, wl(minPosLower+indWlMin-1)*1e9, 'Color', axisColor(jj,:));
    xlabel('Time in s')
    ylabel('Min Transmission Wavelength in nm');
%     yyaxis right
%     plot(timeQ, transDataUpper,'--', 'Color', axisColor(jj,:));
%     ylabel('Transmission');
    title(['Min Transmission Position below ' num2str(wlSplit) 'nm']);
    hold on
    
end