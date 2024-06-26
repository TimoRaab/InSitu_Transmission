clear all
close all
clc


%%
endTime = 5;
averageTime = 3;
%%
% basedir = 'C:\Users\Timo\Desktop\210421';
% tempFileList = dir(basedir);
% 
% fileList = cell(0);
% for i=1:length(tempFileList)
%     if ~isempty(regexp(tempFileList(i).name, 'Blend', 'once'))
%         if ~isempty(regexp(tempFileList(i).name, 'meas.spin', 'once'))
%             fileList{end+1} = tempFileList(i).name;
%         end
%     end
% end

%%
%%
fileList = cell(0);
dummyLength = 0;
axisColor = [];
basedir = 'E:\Measurements\InSitu\SpinCoater\210902';
fileList{end+1} = fullfile(basedir, '20210902_135923_TR_Y6Test_Ref_C31_meas.spin');
fileList{end+1} = fullfile(basedir, '20210902_135923_TR_Y6Test_Ref_C32_meas.spin');
fileList{end+1} = fullfile(basedir, '20210902_135923_TR_Y6Test_Ref_D01_meas.spin');
axisColor = [axisColor;repmat([1 0 0], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% 
% 

% % basedir = 'E:\Measurements\InSitu\SpinCoater\210526';
fileList{end+1} = fullfile(basedir, '20210902_141145_TR_Y6Test_0_5CN_D02_meas.spin');
fileList{end+1} = fullfile(basedir, '20210902_141145_TR_Y6Test_0_5CN_D03_meas.spin');
fileList{end+1} = fullfile(basedir, '20210902_141145_TR_Y6Test_0_5CN_D04_meas.spin');
axisColor = [axisColor;repmat([1 0 1], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% 
% basedir = 'E:\Measurements\InSitu\SpinCoater\210618';
fileList{end+1} = fullfile(basedir, '20210902_142326_TR_Y6Test_1_0CN_D05_meas.spin');
fileList{end+1} = fullfile(basedir, '20210902_142326_TR_Y6Test_1_0CN_D06_meas.spin');
fileList{end+1} = fullfile(basedir, '20210902_142326_TR_Y6Test_1_0CN_D07_meas.spin');
axisColor = [axisColor;repmat([0 1 1], length(fileList)-dummyLength,1)];
dummyLength = length(fileList);
% % 
% fileList{end+1} = fullfile(basedir, '20210618_133050_TR_Y6PM6_A20_PM6_First_PM6_meas.spin');
% fileList{end+1} = fullfile(basedir, '20210618_133500_TR_Y6PM6_A24_PM6_First_PM6_meas.spin');
% axisColor = [axisColor;repmat([0 0 0], length(fileList)-dummyLength,1)];
% dummyLength = length(fileList);
% 
% fileList{end+1} = fullfile(basedir, '20210618_133050_TR_Y6PM6_A20_PM6_First_PM6_meas.spin');
% fileList{end+1} = fullfile(basedir, '20210618_133500_TR_Y6PM6_A24_PM6_First_PM6_meas.spin');
% axisColor = [axisColor;repmat([0 0 0], length(fileList)-dummyLength,1)];
% dummyLength = length(fileList);
% 
% fileList{end+1} = fullfile(basedir, '20210618_130038_TR_Y6PM6_A13_meas.spin');
% fileList{end+1} = fullfile(basedir, '20210618_130038_TR_Y6PM6_A17_meas.spin');
% axisColor = [axisColor;repmat([1.00 0.54 0.00], length(fileList)-dummyLength,1)];
% dummyLength = length(fileList);
% 
% fileList{end+1} = fullfile(basedir, '20210618_130038_TR_Y6PM6_A14_meas.spin');
% fileList{end+1} = fullfile(basedir, '20210618_130038_TR_Y6PM6_A18_meas.spin');
% axisColor = [axisColor;repmat([0.25 0.80 0.54], length(fileList)-dummyLength,1)];
% dummyLength = length(fileList);

%%
for ii=1:length(fileList)
    disp(['Number ' num2str(ii) ' von ' num2str(length(fileList))])
    fileList{ii} = correctPathForDate(fileList{ii});
    fname = fileList{ii};
    disp(fname)
    
    %% Correct for fname date
    correctedPath = correctPathForDate(fname);
%     splitter = regexp(correctedPath,filesep);

%     basedir = pathstring(1:splitter(end));
    fname = correctedPath;
    %%
    wlRange = [400e-9 700e-9]; % gibt den Wellenbereich zum plotten an
    timeRange = [-120 130]; % gibt den Zeitbereich zum plotten an
    wlPlot = [530 600]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
    timePlot = [1:5:20];

    timeRangeFFT = [34 44]; %Zeitbereich f�r die FFT (hier soll das Spektrum konstant sein)
    wlDetectFFT = 550e-9; % Wellenl�nge, f�r welche die FFT bestimmt wird
    speedRangeFFT = [3500 4500]/60; % Bereich der Rotationsgeschwindigkeit, in welcher gesucht wird

    %%
    createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
    referenceTimeSector = 2;    % which speed area should be used
    referenceTimeBefore = 1;    % Time before taking the reference
    referenceTime = 3;          % Time for taking reference

    %%
    [spectra, time, wl, ref, dark, startTime] = readSpinCoater(fname);  %liest die Spektren ein
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
        i = 1;
        while (isempty(regexp(temp_set{i}, 'Speed', 'once'))...
                || isempty(regexp(temp_set{i}, 'Time', 'once'))...
                || isempty(regexp(temp_set{i}, 'Acceleration', 'once')))
            i = i+1;
        end

        lowerLimit = i+1;

        while (regexp(temp_set{i}, '\r') ~= 1)
            i = i+1;
        end
        upperLimit = i-1;

        % if an to big speed section is giving, last section is used
        line4Reference = lowerLimit+referenceTimeSector-1;
        if line4Reference > upperLimit
            line4Reference = upperLimit;
        end

        % get starting time for reference
        time2Reference = 0;
        i = 0;
        while (lowerLimit+i < line4Reference)
            temp = strsplit(temp_set{lowerLimit+i}, '\t');
            time2Reference = time2Reference + str2double(temp{2});
            i = i+1;
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
    [~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes f�rs plotten
    [~,indWlMax] = min(abs(wl-max(wlRange)));
    [~,indTimeMin] = min(abs(time-min(timeRange))); 
    [~,indTimeMax] = min(abs(time-max(timeRange)));
    
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
    figure(5004);
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
    [~,indTAvgStart] = min(abs(time-(time(end)-endTime)));
    [~,indTAvgEnd] = min(abs(time-(time(end)-endTime+averageTime)));
    %%
    figure(77)
    plot(wl*1e9, mean(R(:,indTAvgStart:indTAvgEnd), 2), 'Color', axisColor(ii,:))
    drawnow
    hold on
    
    %%
    figure(78)
    tempMax = max(mean(R(:,indTAvgStart:indTAvgEnd), 2));
    tempMin = min(mean(R(:,indTAvgStart:indTAvgEnd), 2));
    plot(wl*1e9, (mean(R(:,indTAvgStart:indTAvgEnd), 2)-tempMin)./(tempMax-tempMin), 'Color', axisColor(ii,:))
    drawnow
    hold on
    
end