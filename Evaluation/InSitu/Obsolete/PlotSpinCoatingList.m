clc;
close all
clear all

%%
readSpectra = false;
savePic = true;
pathString = 'F:\Pictures\180815';
names = {'WLCut_605nm'...
    'WLCut_558nm'...
    'WLCut_509nm'...
    'WLCut_446nm'...
    '3DMap_S01'...
    '3DMap_S02'...
    '3DMap_S03'...
    '3DMap_S04'...
    '3DMap_S05'...
    '3DMap_S06'...
    'WLCut_S01'...
    'WLCut_S02'...
    'WLCut_S03'...
    'WLCut_S04'...
    'WLCut_S05'...
    'WLCut_S06'...
    };
vars = [101 ...
    102 ...
    103 ...
    104 ...
    801 ...
    802 ...
    803 ...
    804 ...
    805 ...
    806 ...
    201 ...
    202 ...
    203 ...
    204 ...
    205 ...
    206 ...
    ];
%%
basedir = 'F:\Measurements\InSitu\SpinCoater\180815';
fname{1} = '20180815_161803_P3HT_20mg_1_meas.spin';
fname{end+1} = '20180815_162237_P3HT_20mg_2_meas.spin';
fname{end+1} = '20180815_162700_P3HT_20mg_3_meas.spin';
fname{end+1} = '20180815_163143_P3HT_20mg_4_meas.spin';
fname{end+1} = '20180815_163608_P3HT_20mg_5_meas.spin';
fname{end+1} = '20180815_164020_P3HT_20mg_6_meas.spin';




legendTemp = {'S01 - 1500rpm';...
    'S02 - 1500rpm';...
    'S03 - 1500prm';...
    'S04 - 1000rpm';...
    'S05 - 1000rpm';...
    'S06 - 1000rpm';...
    };
% legendTemp = [];


wlRange = [420e-9 700e-9];
timeRange = [-1 15];
wlPlot = [605 558 509 446]*1e-9;
counter = 0;
%%
if exist('fname', 'var')
    for i=1:length(fname)
        [spectra, time, wl, ref, dark, startTime] = readSpinCoater(fullfile(basedir,fname{i}));
        spectra = squeeze(spectra);
        dark = squeeze(dark);
        ref = squeeze(ref);
        [~,indWlMin] = min(abs(wl-min(wlRange)));
        [~,indWlMax] = min(abs(wl-max(wlRange)));
        wl = wl(indWlMin:indWlMax);
        time = time-time(1);
        time = time/1e5;
        time = time-startTime;
        [~,indTimeMin] = min(abs(time-min(timeRange)));
        [~,indTimeMax] = min(abs(time-max(timeRange)));
        if ~exist('tList', 'var')
            trList = cell(length(fname),1);
            dList = cell(length(fname),1);
            rList = cell(length(fname),1);
            tList = cell(length(fname),1);
        end
        dList{i} = mean(dark(indWlMin:indWlMax,:),2);
        rList{i} = mean(ref(indWlMin:indWlMax,:),2);
        trList{i} = (spectra(indWlMin:indWlMax,indTimeMin:indTimeMax)-dList{i})...
            ./(rList{i}-dList{i});
        tList{i} = time(indTimeMin:indTimeMax);
        
        if readSpectra
            specSample = ReadSpectraSpinCoating(fullfile(basedir, fname_spec{i}));
            specSample = squeeze(specSample);
            if ~exist('sList', 'var')
                sList = NaN(length(fname_spec), indWlMax-indWlMin+1);
            end
            sList(i,:) = mean(specSample(indWlMin:indWlMax,:),2);
        end
    end
end
        
clearvars dark ref spectra time specSample

%%
wlCutsNumbering = 100;
for i=1:length(wlPlot)
    [~, indTemp] = min(abs(wl-wlPlot(i)));
    figure(wlCutsNumbering+i)
    for j=1:length(trList)
        plot(tList{j}, trList{j}(indTemp,:));
        xlabel('Time in seconds')
        ylabel(['Transmission']);
        set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)
        titleString = [num2str(wlPlot(i)*1e9) 'nm'];
        title(titleString)
        hold on
    end
    if isempty(legendTemp)
        for j=1:length(fname)
            legendTemp = [legendTemp; fname{j}(end-12:end-10)];
        end
    end
    [~, l1] = legend(legendTemp, 'Location', 'best');
    hL=findobj(l1,'type','line');
    set(hL,'linewidth',2);
end

%%
imagescNumbering = 800;
for i=1:length(trList)
    figure(800+i)
    imagesc(tList{i}, wl, trList{i})
    c = colorbar();
    caxis([0 1.2])
    c.Label.String = 'Transmission';
    c.Label.FontSize = 12;
    titleString = ['Sample ' num2str(i, '%02.f')];
    title(titleString)
    xlabel('Time in s');
    ylabel('Wavelength in m');
    set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)
end
    
%%
wlCutsSamplewiseNumbering = 200;
for j=1:length(trList)
    figure(wlCutsSamplewiseNumbering+j);
    for i=1:length(wlPlot)
        [~, indTemp] = min(abs(wl-wlPlot(i)));
        plot(tList{j}, trList{j}(indTemp,:));
        hold on
    end
    set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)
    xlabel('Time in seconds')
    ylabel(['Transmission']);
    titleString = ['Sample ' num2str(j, '%02.f')];
%     [m1, m2] = regexp(fname{j}, '[Ss]\d+');
%     titleString = ['Sample ' fname{j}(m1+1:m2)];
    title(titleString)
    [~,l1] = legend([num2str(wlPlot'*1e9) repmat(' nm',length(wlPlot),1)],...
        'Location','best');
    hL=findobj(l1,'type','line');
    set(hL,'linewidth',2);
end

%%
if savePic
    mkdir(pathString);
    saveFiguresFast(vars, pathString, names);
end