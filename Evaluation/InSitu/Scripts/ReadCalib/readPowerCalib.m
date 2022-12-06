function [powerData] = readPowerCalib(fname)
    
    fid = fopen(fname);
    siz = [2^32 2^16 2^8 1]';
    
    measureSize = sum(fread(fid, 4).*siz);
    powerData = fread(fid, measureSize, 'double', 0, 'ieee-be');
    fclose(fid);
end