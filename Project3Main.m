close all; clear all; clc;
warning('off','all')
% Create the transfer function and simulate the system
num = [0 9 6 6];
den = [1 -1.98 1.284 -0.272];
sys = filt(num, den, 1);

T = 1;
t = 0:T:1999;
n = length(t);

graphCount = 0;

% 1. Generate a zero-mean unit-variance random input, obtain output by
% simulation
rand_input = randn(n,1);
rand_output = lsim(sys, rand_input, t);


input_mean = mean(rand_input)
input_variance = var(rand_input)
output_variance = var(rand_output)

figure(1)
hold on; grid on;
subplot(2,1,1);
plot(t,rand_input);
title("Random Input");
subplot(2,1,2);
plot(t,rand_output);
title("Output");
graphCount = graphCount + 1;

% 2. Create zero-mean noise with standard deviations equivales of 0.01, 0.03
% and 0.10 the standard deviation of the noise free output
noise = (rand(n,1) - 0.5);
dev = std(rand_output);
noise_1 = ((dev * 0.01) / std(noise)) * (rand(n,1) - 0.5);
noise_2 = ((dev * 0.03) / std(noise)) * (rand(n,1) - 0.5);
noise_3 = ((dev * 0.10) / std(noise)) * (rand(n,1) - 0.5);

output_1 = rand_output + noise_1;
output_2 = rand_output + noise_2;
output_3 = rand_output + noise_3;

output_std = std(rand_output)
noise_1_std = std(noise_1)
noise_2_std = std(noise_2)
noise_3_std = std(noise_3)

figure(2)
hold on; grid on;
subplot(3,1,1);
plot(t,noise_1);
title("Noise 0.01x");
subplot(3,1,2);
plot(t,noise_2);
title("Noise 0.03x");
subplot(3,1,3);
plot(t,noise_2);
title("Noise 0.10x");
graphCount = graphCount + 1;

% 3. Using a recursive data-collection least squares algorithm, identify
% the system parameters under each noise

[theta_RLS, cond_num_RLS] =     RecursiveLeastSquares(rand_input, rand_output, t, graphCount);
graphCount = graphCount + 2;
[theta_RLS_1, cond_num_RLS_1] = RecursiveLeastSquares(rand_input, output_1, t, graphCount);
graphCount = graphCount + 2;
[theta_RLS_2, cond_num_RLS_2] = RecursiveLeastSquares(rand_input, output_2, t, graphCount);
graphCount = graphCount + 2;
[theta_RLS_3, cond_num_RLS_3] = RecursiveLeastSquares(rand_input, output_3, t, graphCount);
graphCount = graphCount + 2;

% 4. Using a recursive data collection least squares algorithm with
% forgetting factor, estimate the parameters under each noise

lambda = [0.9, 0.99, 1];
[theta, cond_num] = RLS_forgetting_V2(rand_input, rand_output, lambda, t, graphCount);
graphCount = graphCount + 6;
[theta_forget_1, cond_num_forget_1] = RLS_forgetting_V2(rand_input, output_1, lambda, t, graphCount);
graphCount = graphCount + 6;
[theta_forget_2, cond_num_forget_2] = RLS_forgetting_V2(rand_input, output_2, lambda, t, graphCount);
graphCount = graphCount + 6;
[theta_forget_3, cond_num_forget_3] = RLS_forgetting_V2(rand_input, output_3, lambda, t, graphCount);
graphCount = graphCount + 6;

% 5. Using an unbiased method from the MATLAB toolbox (IV4 method),
% identify the parameters at the three different noise levels

data = iddata(rand_output, rand_input, T);
sys_0 = iv4(data, [ 3, 3, 1]);

data_1 = iddata(output_1, rand_input, T);
sys_1 = iv4(data_1, [ 3, 3, 1]);

data_2 = iddata(output_2, rand_input, T);
sys_2 = iv4(data_2, [ 3, 3, 1]);

data_3 = iddata(output_3, rand_input, T);
sys_3 = iv4(data_3, [ 3, 3, 1]);






