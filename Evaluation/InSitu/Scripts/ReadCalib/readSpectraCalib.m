function spectra = readSpectraCalib(pathToFile)

    fid = fopen(pathToFile);
    siz = [2^32 2^16 2^8 1]';
    
    frames = sum(fread(fid, 4).*siz);
    yValues = sum(fread(fid, 4).*siz);
    xValues = sum(fread(fid, 4).*siz);
    spectra = fread(fid, frames*yValues*xValues, 'uint16', 0, 'ieee-be');
    spectra = reshape(spectra, [xValues,yValues,frames]);
end