function D = DGenerate(mode,t, maxMag1, tStart,tPeak, sigma1, sigma2, offset)
D = zeros(size(t));


if strcmpi(mode, 'Monophasic')
for i = 1:length(t)
    if t(i) >= tStart % zeros until start time
    if t(i) <= tPeak
        D(i) = maxMag1 * exp(-((t(i- tStart) - tPeak)^2) / (2 * sigma1^2));
    else
        D(i) = maxMag1 * exp(-((t(i- tStart) - tPeak)^2) / (2 * sigma2^2));
    end
    end
end
end

if strcmpi(mode, 'Biphasic')
    maxMag2 = maxMag1 - 4;
    t1 = tPeak;
    t2 = tPeak + 80;
for i = 1:length(t)
    if t(i) < tStart
       D(i) = 0; % Zero before the start time
    else
        D(i) = maxMag1 * exp(-((t(i) - t1)^2) / (2 * sigma1^2)) + ...
               maxMag2 * exp(-((t(i) - t2)^2) / (2 * sigma2^2)); % Combined peaks
    end
end
end


if strcmpi(mode, 'Lift') % no zero padding, instantaneous impulse
for i = 1:length(t) 
    if t(i) <= tPeak
        D(i) = maxMag1 * exp(-((t(i- tStart) - tPeak)^2) / (2 * sigma1^2));
    else
        D(i) = maxMag1 * exp(-((t(i- tStart) - tPeak)^2) / (2 * sigma2^2));
    end
end
end

if strcmpi(mode, 'Run') % allows for negatives
    maxMag1 = maxMag1 + 10;
    for i = 1:length(t)
        if t(i) <= tPeak
            D(i) = maxMag1 * exp(-((t(i) - tPeak)^2) / (2 * sigma1^2));
        else
            D(i) = maxMag1 * exp(-((t(i) - tPeak)^2) / (2 * sigma2^2)) + offset;
        end
    end
    D(D > maxMag1-10) = maxMag1 - 10;
end


end