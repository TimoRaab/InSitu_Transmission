function spectra = readSpectraCalibAveraged(pathToFile)

    fid = fopen(pathToFile);
    siz = [2^32 2^16 2^8 1]';
    
    frames = 1;
    yValues = 1;
    xValues = sum(fread(fid, 4).*siz);
    spectra = fread(fid, frames*yValues*xValues, 'double', 0, 'ieee-be');
    spectra = reshape(spectra, [xValues,yValues,frames]);
    
    fclose(fid);
end