function [timestamps] = timeCorrection(correctingTimeData, spec, wl, time)

    correctTime = correctingTimeData{1};
    timeDetectLowerThreshold= correctingTimeData{2};
    timeDetectUpperThreshold = correctingTimeData{3};
    timeDetectWavelength = correctingTimeData{4};
    timeDetectSkipNSeconds = correctingTimeData{5};

    
    if length(timeDetectLowerThreshold) ~= length(timeDetectUpperThreshold) ||...
        length(timeDetectLowerThreshold) ~= length(timeDetectSkipNSeconds)
        error('55001: Wrong array Dimensions in time correction array')
    end
    
    timestamps = zeros(size(timeDetectLowerThreshold));
    
    if correctTime
        [~,indTimeDetectWl] = min(abs(wl-timeDetectWavelength));
        for i=1:length(timeDetectLowerThreshold)        
            [~,indTimeDetect] = min(abs(time-+timeDetectSkipNSeconds(i)));
            for indTimeLower=indTimeDetect:length(time)
                if spec(indTimeDetectWl,indTimeLower) < timeDetectLowerThreshold(i)
                    break
                end
            end
            for indTimeUpper=indTimeLower:-1:1
                if (spec(indTimeDetectWl,indTimeUpper) > timeDetectUpperThreshold(i))
                    break
                end
            end

            timestamps(i) = time(indTimeUpper);
        end
    end
    
end