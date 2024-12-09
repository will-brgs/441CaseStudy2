function states_dot = simFunc(t, A, B, Dinterp, K_p, K_i, L, r, states)

    p1 = 0.03;     % Rate of glucose decay
    p2 = 0.02;     % Rate of insulin action decay
    p3 = 0.01;     % Insulin sensitivity
    n = 0.1;       % Insulin clearance rate
    Gb = 100;      % Baseline glucose
    Ib = 10;       % Baseline plasma insulin
    
    v_real = states(1:3);
    v_hat = states(4:6);
    z = states(7);
    z_dot = r - v_real(1);

    % v_hat = max(v_hat, 0);
    % v_real = max(v_real, 0);


    dynamics = @(t, y, u) [
    -p1 * (y(1) - Gb) - y(2) * y(1) + Dinterp(t);
     -p2 * y(2) + p3 * (y(3) - Ib);
    -n * y(3) + u];


    u = -K_p * v_hat - K_i*z;

    %u = max(u, 0);
    
    v_hat_dot = A*v_hat + B*u + L*(v_real(1) - v_hat(1));

    % if u(h+1, 1) <= 0
    %     u(h+1, 1) = 0;    
    % end
 
    v_dot = dynamics(t, v_real(1:3), u); % Pass the current state as a column vector

    
    states_dot = [v_dot; 
                  v_hat_dot; 
                  z_dot];
    
    % if v_hat(1) <= 0
    %     v_hat(h+1, 1) = 0;    
    % end
    % if v_hat(2) <= 0
    %     v_hat(h+1, 2) = 0;    
    % end
    % if v_hat(3) <= 0
    %     v_hat(h+1, 3) = 0;    
    % end
    % 
    % if all(v_real(1) <= 0)
    %     v_real(h+1, 1) = 0;    
    % end
    % if all(v_real(2) <= 0)
    %     v_real(h+1, 2) = 0;    
    % end
    % if all(v_real(3) <= 0)
    %     v_real = 0;    
    % end
end