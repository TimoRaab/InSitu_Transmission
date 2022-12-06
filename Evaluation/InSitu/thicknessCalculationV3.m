function [thickness] = thicknessCalculationV3(lambdaInd, weight)
    
    std4Thickness = 1e8;
    thickness = 1e8;

    [lambdaInd, lambdaSort] = sort(lambdaInd, 'descend');
    weight = weight(lambdaSort);
    
    maxValue = ceil(2*7000/max(lambdaInd));
    
    for j = 1:maxValue
        thicknessArray = NaN(length(lambdaInd), 2^(length(lambdaInd)-1));
        thicknessArray(1,:) = lambdaInd(1)*j;
        
        if length(lambdaInd) == 1
            thickness = NaN;
        else 

            thicknessArray = recursiveFind(2, lambdaInd(1)*j, lambdaInd, thicknessArray);
    
    
            [stdTemp, pos4std] = min(std(thicknessArray, weight));
            if (stdTemp < std4Thickness)
                orderDiff = diff(thicknessArray(:,pos4std)./lambdaInd);
                if sum(orderDiff==0)./length(lambdaInd) < 0.5
                    if sum(orderDiff > 1)./length(lambdaInd) < 0.5
                        std4Thickness = stdTemp;
                        meanTemp = mean(thicknessArray);
                        thickness = meanTemp(pos4std);
                    end
                end
            end
        end
    end
    thickness = thickness/2; %correct for back and forth
end



function [thicknessArray] = recursiveFind(currentLayer, refValue, lambdaInd, thicknessArray)
    if currentLayer < length(lambdaInd)
        thicknessArray = recursiveFind(currentLayer+1, refValue, lambdaInd, thicknessArray);
    end

    tempOrder = refValue./lambdaInd(currentLayer);

    thicknessArray(currentLayer,:) = repmat(...
        [repmat(floor(tempOrder)*lambdaInd(currentLayer), 1, 2^(length(lambdaInd)-currentLayer)) ...
        repmat(ceil(tempOrder)*lambdaInd(currentLayer), 1, 2^(length(lambdaInd)-currentLayer))],...
        1, 2^(currentLayer-2));
end
