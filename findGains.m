function [Kp, Ki, L] = findGains(A, B, C, desired_controller_poles, desired_observer_poles)
% design_PI_controller_observer Designs PI controller and observer gains
%
% Syntax:
%   [Kp, Ki, L] = design_PI_controller_observer(A, B, C, desired_controller_poles, desired_observer_poles)
%
% Inputs:
%   A - State matrix of the plant (3x3)
%   B - Input matrix of the plant (3x1)
%   C - Output matrix of the plant (1x3)
%   desired_controller_poles - Desired closed-loop poles for the controller (vector)
%   desired_observer_poles - Desired poles for the observer (vector, typically faster than controller poles)
%
% Outputs:
%   Kp - Proportional gain matrix (1x3)
%   Ki - Integral gain scalar
%   L  - Observer gain matrix (3x1)

    % Validate input dimensions
    [nA, mA] = size(A);
    [nB, mB] = size(B);
    [nC, mC] = size(C);
    
    
    % 1. Augment the system with an integrator for the PI controller
    % Integral state: z(t) = integral of error (z_dot = e = r - y)
    
    % Augmented state matrix (A_aug) and input matrix (B_aug)
    A_aug = [A, B; 
             C, 0];
    B_aug = [B; 1];
    
    % 2. Check controllability of the augmented system
    controllability_matrix = ctrb(A_aug, B_aug);
    if rank(controllability_matrix) > (size(A_aug,1))
        disp("System is controllable")
    end
    
    % 3. Design the PI controller gains (Kp and Ki) using pole placement
    K_aug = place(A_aug, B_aug, desired_controller_poles);
    
    % Extract Kp and Ki from K_aug
    Kp = K_aug(1:nA);    % Proportional gains (1x3)
    Ki = K_aug(end);     % Integral gain (scalar)
    
    % 4. Check observability of the original system
    observability_matrix = obsv(A, C);
    if rank(observability_matrix) > nA
        disp("System is observable")
    end
    
    % 5. Design the Observer gain (L) using pole placement
    % The observer poles should be faster than the controller poles
    % To ensure faster state estimation
    
    % Transpose A and C for the 'place' function (which places poles for A')
    L_transposed = place(A', C', desired_observer_poles);
    L = L_transposed';   % Observer gain (3x1)
    
    % 6. Display the designed gains
    fprintf('Designed Proportional Gains (Kp):\n');
    disp(Kp);
    fprintf('Designed Integral Gain (Ki):\n');
    disp(Ki);
    fprintf('Designed Observer Gains (L):\n');
    disp(L);
    
    % 7. Optional: Return the gains if needed
    % The function already returns [Kp, Ki, L]
    
end
