close all
clear all
clc
genpath(pwd);

%%
basedir = 'F:\Measurements\InSitu\SpinCoater\180824';
fname = '20180824_130650_P3HT_20mg_CB_3000rpm_s10_meas.spin';

wlRange = [420e-9 700e-9];

figName = 'Sample 10';

pathString = 'F:\Pictures\180824';
names = {'Drying_S10'};

saveFig = true;

%%
d = dir(basedir);


%%
for i=length(d):-1:1
    if isempty(regexp(d(i).name, fname(1:end-9),'once'))
        d(i) = [];
    end
end

[~, ind] = sort({d.date});
d = d(ind);

%%
[dark, ref, wl] = readAdditional(fullfile(basedir, [fname(1:end-9) 'add.spin']));
dark = squeeze(dark);
dark = mean(dark,2);
ref = squeeze(ref);
ref = mean(ref,2);

%%
counter = 0;
for i=1:length(d)
    if regexp(d(i).name, 'a\d+')
        counter = counter+1;
        if counter == 1 %% get the dimension
            specTemp = ReadSpectraSpinCoating(fullfile(basedir, d(i).name));
        end
    end
end

%% Read Information
comments = cell(0);
fcomm = [fname(1:end-9) 'comments.txt'];
fid = fopen(fullfile(basedir, fcomm));
comments{end+1} = fgetl(fid);
while comments{end} ~= -1
    temp = fgetl(fid);
    if ~isempty(temp)
        comments{end+1} = temp;
    end
end
fclose(fid);
comments = comments(1:end-1)';

% Look for periodic time
c = 1;
while isempty(regexp(comments{c}, 'Periodic Time', 'once'))
    c = c+1;
end
periodicTiming = str2double(comments{c}(16:end-1));

% Look for duration
c = 1;
while isempty(regexp(comments{c}, 'Duration after', 'once'))
    c = c+1;
end
durAfter = str2double(comments{c}(17:end-1));

% Look for spin at end
c = 1;
while isempty(regexp(comments{c}, 'Spin at end', 'once'))
    c = c+1;
end
spinAtEnd = isempty(regexp(comments{c}(17:end), 'false', 'once'));

%%
offset = 0;
if spinAtEnd
    c = 1;
    spec = NaN([counter-1, size(specTemp,1)]);
    for i=1:length(d)
        if regexp(d(i).name, 'a\d+')
            if c ~= counter
                spec(i-offset,:) = mean(squeeze(...
                    ReadSpectraSpinCoating(fullfile(basedir, d(i).name))),2);
                c = c+1;
            else
                specSpin = ReadSpectraSpinCoating(fullfile(basedir, d(i).name));
            end
        else
            offset = offset+1;
        end
    end
else 
    spec = NaN([counter, size(specTemp,1)]);
    for i=1:length(d)
        if regexp(d(i).name, 'a\d+')
            spec(i-offset,:) = mean(squeeze(...
                ReadSpectraSpinCoating(fullfile(basedir, d(i).name))),2);
        else
            offset = offset+1;
        end
    end
end
       
clearvars specTemp
%%
[~,indWlMin] = min(abs(wl-min(wlRange)));
[~,indWlMax] = min(abs(wl-max(wlRange)));

spec = spec-dark';
ref = ref'-dark';

tr = spec./ref;


%%
legendString = [];
for i=1:size(tr,1)
    plot(wl(indWlMin:indWlMax), tr(i,indWlMin:indWlMax))
    hold on
end
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)
xlabel('Wavelength in m');
ylabel('Transmission');
legend(cellstr([num2str(periodicTiming*(1:size(tr,1))') repmat('s', size(tr,1), 1)])', 'NumColumns', 4, 'Location', 'best');
title(figName)

%%
if saveFig
    mkdir(pathString);
    saveFiguresFast([1], pathString, names);
end