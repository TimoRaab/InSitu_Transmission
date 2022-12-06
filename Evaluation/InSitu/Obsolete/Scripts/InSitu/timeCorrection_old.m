function [time] = timeCorrection(correctingTimeData, spec, wl, time)

    correctTime = correctingTimeData{1};
    timeDetectLowerThreshold= correctingTimeData{2};
    timeDetectUpperThreshold = correctingTimeData{3};
    timeDetectWavelength = correctingTimeData{4};
    timeDetectSkipNSeconds = correctingTimeData{5};


    if correctTime
        [~,indTimeDetectWl] = min(abs(wl-timeDetectWavelength));
        [~,indTimeDetect] = min(abs(time-(min(time)+timeDetectSkipNSeconds)));
        for indTimeLower=indTimeDetect:length(time)
            if spec(indTimeDetectWl,indTimeLower) < timeDetectLowerThreshold
                break
            end
        end
        for indTimeUpper=indTimeLower:-1:1
            if (spec(indTimeDetectWl,indTimeUpper) > timeDetectUpperThreshold)
                break
            end
        end
        time = time - time(indTimeUpper);
    end
    
end