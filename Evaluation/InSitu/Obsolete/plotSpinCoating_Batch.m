clear all
close all
clc

%%
wlPlot = [446 509 558 605]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
rangeDetection = [];

colorList = [[0, 0.4470, 0.7410];...
    [0.8500, 0.3250, 0.0980];...
    [0.9290, 0.6940, 0.1250];...
    [0.4940, 0.1840, 0.5560];...
    [0.4660, 0.6740, 0.1880];...
    [0.3010, 0.7450, 0.9330];...
    [0.6350, 0.0780, 0.1840]];

%%

fname = {};

counter = 1;
basedir = 'C:\TimTest\201216'; %40°C
fname{1} = '20201216_115750_TM_P3HTPCBM_S05_meas.spin';
fname{end+1} = '20201216_120212_TM_P3HTPCBM_S06_meas.spin';
fname{end+1} = '20201216_120616_TM_P3HTPCBM_S07_meas.spin';
fname{end+1} = '20201216_121008_TM_P3HTPCBM_S08_meas.spin';

for i=counter:length(fname)
    fname{i} = fullfile(basedir, fname{i});
end
counter = length(fname)+1;
rangeDetection(end+1) = length(fname)-sum(rangeDetection(1:end));

basedir = 'C:\TimTest\201221'; % 60°C
fname{end+1} = '20201221_111306_TM_P3HTBCBM_S05_meas.spin';
fname{end+1} = '20201221_112705_TM_P3HTBCBM_S06_meas.spin';
fname{end+1} = '20201221_113155_TM_P3HTBCBM_S07_meas.spin';

for i=counter:length(fname)
    fname{i} = fullfile(basedir, fname{i});
end
counter = length(fname)+1;
rangeDetection(end+1) = length(fname)-sum(rangeDetection(1:end));

basedir = 'C:\TimTest\210107'; %80°C
fname{end+1} = '20210107_101748_TM_P3HTPCBM_S04_meas.spin';
fname{end+1} = '20210107_102216_TM_P3HTPCBM_S05_meas.spin';
fname{end+1} = '20210107_103239_TM_P3HTPCBM_S07_meas.spin';
fname{end+1} = '20210107_103727_TM_P3HTPCBM_S08_meas.spin';

for i=counter:length(fname)
    fname{i} = fullfile(basedir, fname{i});
end
counter = length(fname)+1;
rangeDetection(end+1) = length(fname)-sum(rangeDetection(1:end));

for i=length(rangeDetection):-1:1
    rangeDetection(i) = sum(rangeDetection(1:i));
end
%%
timeRangeFFT = [60 100]; %Zeitbereich f�r die FFT (hier soll das Spektrum konstant sein)
wlDetectFFT = 550e-9; % Wellenl�nge, f�r welche die FFT bestimmt wird
speedRangeFFT = [700 1000]/60; % Bereich der Rotationsgeschwindigkeit, in welcher gesucht wird


%%
colorDetector = 1;
currentColor = colorList(colorDetector,:);
for kk=1:length(fname)
    disp(kk)
    %%
    createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
    referenceTimeSector = 2;    % which speed area should be used
    referenceTimeBefore = 1;    % Time before taking the reference
    referenceTime = 3;          % Time for taking reference

    %%
    disp(fname{kk})
    [spectra, time, wl, ref, dark, startTime] = readSpinCoater(fname{kk});  %liest die Spektren ein
    spectra = squeeze(spectra); % entfernt eine Dimension
    dark = squeeze(dark);
    ref = squeeze(ref);
    time = time-time(1);            % rechnet die Zeit um
    time = time/1e5;                % rechnet die Zeit um
    time = time-startTime;          % rechnet die Zeit um


    %%
    if (createReferenceSpectrum)
        fname_set = fname{kk};
        fname_set = [fname_set(1:regexp(fname_set, '_meas.spin')) 'comments.txt'];
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
    clearvars spectra
    clearvars dark
    clearvars ref
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
    
    %%
    movTime = round(1/xDat(ind)/mean(diff(time(indLowFFT:indHighFFT))));
    M = movmean(trans, movTime,2);
    clearvars trans

    
    
    for j=1:length(wlPlot)
        figure(j)
        [~,indWL] = min(abs(wl-wlPlot(j)));
        set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
        plot(time, M(indWL, :), 'Linewidth', 2, 'Color', currentColor);
        xlabel('Time in s')
        ylabel('Transmittance')
        hold on
    end
    
    if (kk == rangeDetection(colorDetector))
        colorDetector = colorDetector+1;
        currentColor = colorList(colorDetector,:);
    end
end





















