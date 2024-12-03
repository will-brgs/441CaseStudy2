function D = DGenerate(mode,t, maxMag, tPeak,tStart, riseConstant, decayConstant)
D = zeros(size(t));
    
    % Monophasic curve
    if strcmpi(mode, 'monophasic')
        for i = 1:length(t)
            if t(i) <= tStart
                % No glucose influx before start time
                D(i) = 0;
            elseif t(i) > tStart && t(i) <= tPeak
                % Rising phase: quadratic polynomial
                D(i) = maxMag * ((t(i) - tStart) / (tPeak - tStart))^2;
            elseif t(i) > tPeak
                % Decaying phase: quadratic polynomial
                D(i) = maxMag * (1 - ((t(i) - tPeak) / (t(end) - tPeak))^2);
            end
        end
    end

    % Biphasic curve
    if strcmpi(mode, 'biphasic')
        for i = 1:length(t)
            if t(i) <= tStart
                % No glucose influx before start time
                D(i) = 0;
            elseif t(i) > tStart && t(i) <= tPeak
                % Rising phase for first peak
                D(i) = maxMag * ((t(i) - tStart) / (tPeak - tStart))^2;
            elseif t(i) > tPeak && t(i) <= tSecondPeak
                % Decay from first peak + rise to second peak
                D(i) = maxMag * (1 - ((t(i) - tPeak) / (tSecondPeak - tPeak))^2) ...
                     + secondMag * ((t(i) - tPeak) / (tSecondPeak - tPeak))^2;
            elseif t(i) > tSecondPeak
                % Decay from second peak
                D(i) = secondMag * (1 - ((t(i) - tSecondPeak) / (t(end) - tSecondPeak))^2);
            end
        end
    end