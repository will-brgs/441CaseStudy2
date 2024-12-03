function D = DGenerate(mode,t, maxMag, tStart,tPeak, sigma1, sigma2)
D = zeros(size(t));


if strcmpi(mode, 'monophasic')
for i = 1:length(t)
    if t >= tStart % zeros until start time
    if t(i) <= tPeak
        D(i) = maxMag * exp(-((t(i) - tPeak)^2) / (2 * sigma1^2));
    else
        D(i) = maxMag * exp(-((t(i) - tPeak)^2) / (2 * sigma2^2));
    end
    end
end
end

if strcmpi(mode, 'biphasic')
end


end