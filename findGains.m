function [Kp, Ki, L] = findGains(A, B, C, desired_controller_poles, desired_observer_poles)
    [nA, ~] = size(A);

    % Augmented state matrix (original)
    % AAugmented = [A, B; 
    %               C, 0];
    % BAugmented = [B; 1];
    
    % Augmented state matrix (new)
    AAugmented = [A, zeros(3,1); 
                  C, 0];
    BAugmented = [B; 0];

    %verify controlability
    controlabilityMatrix = ctrb(AAugmented, BAugmented);
    if rank(controlabilityMatrix) > (size(AAugmented,1))
        disp("System is controllable")
    end
    
    kAugmented = place(AAugmented, BAugmented, desired_controller_poles);
    Kp = kAugmented(1:nA);
    Ki = kAugmented(end);
    
    %verify observability
    observMatrix = obsv(A,C);
    if rank(observMatrix) > nA
        disp("System is observable")
    end

    L = place(A', C', desired_observer_poles);
    L = L';
    
    fprintf('Designed Proportional Gains (Kp):\n');
    disp(Kp);
    fprintf('Designed Integral Gain (Ki):\n');
    disp(Ki);
    fprintf('Designed Observer Gains (L):\n');
    disp(L);
    
    
end
