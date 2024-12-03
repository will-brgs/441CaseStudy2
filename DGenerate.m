function D = DGenerate(mode,t, maxMag, tPeak,tStart, riseConstant, decayConstant)
   
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

end