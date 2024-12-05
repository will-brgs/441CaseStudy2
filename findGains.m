%% findGains: Finds gains of K for U design
%% Introduction
% * Authors:                  Will Burgess, Mack LaRosa
% * Class:                    ESE 441
% * Date:                     Created 12/02/2024, Last Edited 12/09/2024

%% Set Up
syms s k_pa k_pb k_pc k_ia k_ib k_ic

%parameters
p1 = 0.03;
p2 = 0.02;
p3 = 0.01;
n = 0.1;
G_b = 100;
I_b = 10;


A_lin = [-p1, G_b, 0;
          0, s+p2, -p3;
          0, 0, s+n];

B = [0; 0; 1];
C = [1, 0, 0];

K_p = [k_pa; k_pb; k_pc];
K_i = [k_ia; k_ib; k_ic];

%% Part A
W_c_1 = [B, A_lin*B, A_lin*A_lin*B];

W_o_1 = [C; C*A_lin; C*A_lin*A_lin];

rank(W_c_1);
rank(W_o_1);

W_c_2 = [B, A_lin2*B, A_lin2*A_lin2*B];

W_o_2 = [C; C*A_lin2; C*A_lin2*A_lin2];

rank(W_c_2);
rank(W_o_2);

%% Part b
%Controller coefficients
des_poly = s^3 + 9*s^2 + 27*s + 27;
des_coeffs = coeffs(des_poly, s);


char_poly_a1 = det(s*eye(3) - (A_lin - B*K_p.'));
curr_coeffs_a1 = coeffs(char_poly_a1, s);

system = curr_coeffs_a1 == des_coeffs;
sol = solve(system, [k_pa, k_pb, k_pc]);

K_a1 = [double(sol.k_1);
        double(sol.k_2);
        double(sol.k_3)];


char_poly_a2 = det(s*eye(3) - (A_lin2 - B*K_p.'));
curr_coeffs_a2 = coeffs(char_poly_a2, s);

system = curr_coeffs_a2 == des_coeffs;
sol = solve(system, [k_pa, k_pb, k_pc]);

K_a2 = [double(sol.k_1);
        double(sol.k_2);
        double(sol.k_3)];

