function [M] = timeSmoothing(smoothingTimeData, trans, wl, time)
    smoothFFT = smoothingTimeData{1};
    speedValue = smoothingTimeData{2};
    speedValueTimes = smoothingTimeData{3};
    timeRangeFFT = smoothingTimeData{4};
    wlDetectFFT = smoothingTimeData{5}; 
    speedRangeFFT = smoothingTimeData{6}; 
    
    if smoothFFT
        M = fftSmoothing(trans, wl, time, wlDetectFFT, timeRangeFFT, speedRangeFFT);
    else
        if length(speedValueTimes)-length(speedValue) ~= 1
            error('55000: Wrong array Dimensions speed Value')
        end
        M = trans;
        for jjj=1:length(speedValue)
            [~,indSpeedValueLow] = min(abs(time-speedValueTimes(jjj)));
            [~,indSpeedValueHigh] = min(abs(time-speedValueTimes(jjj+1)));
            movTime = round(1/speedValue(jjj)/mean(diff(time)));
            M(:,indSpeedValueLow:indSpeedValueHigh) =...
                movmean(M(:,indSpeedValueLow:indSpeedValueHigh), movTime, 2);
        end 
    end
end
        
    
