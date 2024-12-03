function D = DGenerateOld(mode,t, maxMag, tPeak,tStart, riseConstant, decayConstant)
   
D = zeros(size(t));
if strcmpi(mode, 'monophasic')    
    for i = 1:length(t)
        if t(i) <= tStart
            D(i) = 0;
        elseif t(i) > 20 && t(i) <= tPeak
            D(i) = maxMag * (1 - exp(-(t(i) - 20) / riseConstant));
        elseif t(i) > tPeak
            D(i) = maxMag * exp(-(t(i) - tPeak) / decayConstant);
        end
    end
end

if strcmpi(mode, 'biphasic')    
        P2Mag = maxMag * 0.5; 
        P2Time = tPeak + 30;
        P2Decay = decayConstant * 1.5; % Slower decay for the second peak

        for i = 1:length(t)
            if t(i) <= tStart
                D(i) = 0;  % No influx before start time
            elseif t(i) > tStart && t(i) <= tPeak
                % Primary peak rise phase
                D(i) = maxMag * (1 - exp(-(t(i) - tStart) / riseConstant));
            elseif t(i) > tPeak && t(i) <= P2Time
                % Primary peak decay phase
                D(i) = maxMag * exp(-(t(i) - tPeak) / decayConstant);
            elseif t(i) > P2Time
                % Secondary peak decay phase
                D(i) = P2Mag * exp(-(t(i) - P2Time) / P2Decay);
            end
        end
end