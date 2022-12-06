function [spinCoatingMode, speedMatrix] = getSpeedValues(fname)

%% Name corrections
if isempty(regexp(fname, 'comments.txt', 'once'))
    fname = [fname(1:end-9) 'comments.txt'];
end

%% open file
fid = fopen(fname);
%% Get In-Situ Mode
% 0     normal mode
% 1     abort mode

spinCoatingMode = -1;
temp = fgetl(fid);
if ~isempty(regexp(temp, 'In-Situ Normal:', 'once'))
    spinCoatingMode = 0;
end
if ~isempty(regexp(temp, 'TODO', 'once'))
end

%% Find Speed Values
while isempty(regexp(fgetl(fid), 'Speed \(rpm\)', 'once'))
end

%% Make speed array [speed, time, acceleration]
speedMatrix = NaN(1,3);
counter = 1;
while true
    temp = fgetl(fid);
    if isempty(temp)
        break
    end
    speedMatrix(counter, :) = sscanf(temp, '%f', [1 3]);
    counter = counter+1;
end
%remove zero time lines
speedMatrix(speedMatrix(:,2)==0,:) = [];

fclose(fid);
    
end