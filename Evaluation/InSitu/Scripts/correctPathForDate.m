function [pathDateCorrected] = correctPathForDate(pathstring)
pathDateCorrected = pathstring;

if ~isfile(pathstring)
    splitter = regexp(pathstring,filesep);

    basedir = pathstring(1:splitter(end));
    fname = pathstring(splitter(end)+1:end);
    
    d = dir(basedir);
    
    tempPos = regexp(fname,'_');
    tempFname = fname(tempPos(2)+1:end);
    
    for i=1:length(d)
        if ~isempty(regexp(d(i).name, tempFname))
            pathDateCorrected = fullfile(basedir, d(i).name);
            return;
        end
    end
    error('404: File identifier not found');
end