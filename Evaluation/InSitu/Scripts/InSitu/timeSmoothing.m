function [M] = timeSmoothing(speedValue, speedValueTimes, trans, time, order)

    if length(speedValueTimes)-length(speedValue) ~= 1
        error('55000: Wrong array Dimensions speed Value')
    end
    M = trans;
    for jjj=1:length(speedValue)
        [~,indSpeedValueLow] = min(abs(time-speedValueTimes(jjj)));
        [~,indSpeedValueHigh] = min(abs(time-speedValueTimes(jjj+1)));
        movTime = round(1/speedValue(jjj)/mean(diff(time)));
        if speedValue(jjj) > 10/60
            M(:,indSpeedValueLow:indSpeedValueHigh) =...
                movmean(M(:,indSpeedValueLow:indSpeedValueHigh), movTime*order, 2);
        end
    end 
end
        
    
