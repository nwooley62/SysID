close all; clear all; clc;
warning('off','all')
% Create the transfer function and simulate the system
num = [0 9 6 6];
den = [1 -1.98 1.284 -0.272];
sys = filt(num, den, 1);

% Simulate the system with zero mean random input (1000 samples)
T = 1;
t = 0:T:999;
n = length(t);

% Random input and subsequent output for reference
rand_input = rand(n,1) - 0.5;
rand_output = lsim(sys, rand_input, t);
noise = 1e-5*(rand(n,1) - 0.5);

% 1. Drive plant witn one sinusoid
sin_input = sin(2*pi*(1/8)*t);
sin_output = lsim(sys, sin_input, t);
[BLS_sin, BLS_sin_cond] = BatchLeastSquares(sin_input, sin_output, t);

% 1. Drive plant with sun of two sinusoids
two_sin_input = sin(2*pi*(1/8)*t) + sin(2*pi*(1/16)*t);
two_sin_output = lsim(sys, two_sin_input, t);
[BLS_two_sin, BLS_two_sin_cond] = BatchLeastSquares(two_sin_input, two_sin_output, t);

% 1. Drive plant with sun of three sinusoids
three_sin_input = sin(2*pi*(1/8)*t) + sin(2*pi*(1/16)*t) + sin(2*pi*(1/38)*t);
three_sin_output = lsim(sys, three_sin_input, t);
[BLS_three_sin, BLS_three_sin_cond] = BatchLeastSquares(three_sin_input, three_sin_output, t);

figure(1)
hold on
grid on
subplot(3,1,1);
plot(t(1:300), sin_input(1:300));
title("Sinusoid Input Signals");
subplot(3,1,2);
plot(t(1:300), two_sin_input(1:300));
subplot(3,1,3);
plot(t(1:300), three_sin_input(1:300));

figure(2)
hold on
grid on
subplot(3,1,1);
plot(t, sin_output);
title("Sinusoid Output Signals");
subplot(3,1,2);
plot(t, two_sin_output);
subplot(3,1,3);
plot(t, three_sin_output);

% 2. Square wave with a period of 6
period = 6;
sq_input = square(2 * pi * (1 / period) * t);
sq_output = lsim(sys, sq_input, t);
[BLS_sq, BLS_sq_cond] = BatchLeastSquares(sq_input, sq_output, t);

% 2. Square wave with a period of 12
period = 12;
sq_input_12 = square(2 * pi * (1 / period) * t);
sq_output_12 = lsim(sys, sq_input_12, t);
[BLS_sq_12, BLS_sq_cond_12] = BatchLeastSquares(sq_input_12, sq_output_12, t);

% 2. Square wave with a period of 20
period = 20;
sq_input_20 = square(2 * pi * (1 / period) * t);
sq_output_20 = lsim(sys, sq_input_20, t);
[BLS_sq_20, BLS_sq_cond_20] = BatchLeastSquares(sq_input_20, sq_output_20, t);

figure(3)
hold on
grid on
subplot(3,1,1);
plot(t(1:100), sq_input(1:100));
title("Square Input Signals");
subplot(3,1,2);
plot(t(1:100), sq_input_12(1:100));
subplot(3,1,3);
plot(t(1:100), sq_input_20(1:100));

figure(4)
hold on
grid on
subplot(3,1,1);
plot(t, sq_output);
title("Square Output Signals")
subplot(3,1,2);
plot(t, sq_output_12);
subplot(3,1,3);
plot(t, sq_output_20);

% 3. Sliding window with step input
t_win = 1:1:70;
step_input = horzcat(zeros(1,60), ones(1,10));
step_output = lsim(sys, step_input, t_win);
[SW_output, SW_cond_num] = SlidingWindow(step_input, step_output, 50, t_win, 4);

% 4. Operparameterize numerator
[BLS_OP_num, BLS_OP_num_cond] = BatchLeastSquaresV2(rand_input, rand_output,4,3, t);

% 4. Operparameterize denomenator
[BLS_OP_den, BLS_OP_den_cond] = BatchLeastSquaresV2(rand_input, rand_output,3,4, t);

% 4. Operparameterize both
[BLS_OP_both, BLS_OP_both_cond] = BatchLeastSquaresV2(rand_input, rand_output,4,4, t);

% 5. Simulate the system with feedback
Gp = sys;
zero_input = zeros(1,n)';

% P controller with zero input
Gc = pidtune(sys, 'P');
[feedback_theta_p1, feedback_cond_num_p1] = ClosedLoopSystem(Gc, Gp, zero_input, noise, t, 6);

% P controller with random input
[feedback_theta_p2, feedback_cond_num_p2] = ClosedLoopSystem(Gc, Gp, rand_input, noise, t, 7);

% PI controller with zero input
Gc = pidtune(sys, 'PI');
[feedback_theta_pi1, feedback_cond_num_pi1] = ClosedLoopSystem(Gc, Gp, zero_input, noise, t, 8);

% PI controller with random input
[feedback_theta_pi2, feedback_cond_num_pi2] = ClosedLoopSystem(Gc, Gp, rand_input, noise, t, 9);


