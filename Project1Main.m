close all; clear all; clc;
warning('off','all')
%1. Create the transfer function and simulate the system
num = [0 9 6 6];
den = [1 -1.98 1.284 -0.272];
sys = filt(num, den)

%2. Simulate the system with zero mean random input (1000 samples)
T = 1;
t = 0:T:999;
n = length(t)

input = rand(n,1) - 0.5;
output = lsim(sys, input, t);
input_mean = mean(input)
variance = var(output)

figure(1);
plot(t, output);

% Declare variables for later use with other functions
changeParam= 411; %round(rand()*700 + 3); % Random change during simulation
lambda = [1, 0.99, 0.9];
noise = (5/3)* (rand(n,1) - 0.5);
graphCount=1;

% Simulation for change of parameters
num = [0 9 2 6];
den = [1 -1.98 1.284 -0.272];
sys = filt(num, den);
output2 = lsim(sys, input, t);

output_std=std(output)
noise_std=std(noise)

% 4 Batch LS Function and drive system to identify parameters
theta_bls = BatchLeastSquares(input, output, t);

%5. Basic recursive function of LS algorithm
theta_rls = RecursiveLeastSquares(input, output, t, graphCount);
graphCount = graphCount + 2;

%6. Recursive LS with exponential forgetting & sudden change
theta_forgetting = RLS_forgetting(input, output, output2, lambda, changeParam, t, graphCount);
graphCount = graphCount + 6;

%7. Random zero-mean noise to the output (independent of input)
theta_noise = RLS_noise(input, output, noise, output2, lambda, changeParam, t, graphCount);
graphCount = graphCount + 6;

%8. Sliding window (N=10) least squares 
theta_window_10 = SlidingWindow(input, output, 10, t, graphCount);
graphCount = graphCount + 2;
%8. Sliding window (N=100) least squares
theta_window_100 = SlidingWindow(input, output, 100, t, graphCount);
graphCount = graphCount + 2;

%8. Sliding window (N=10) with forgetting factor & sudden change
theta_SW_forgetting_10 = SW_forgetting(input, output, output2, lambda, 10, changeParam, t, graphCount);
graphCount = graphCount + 6;
%8. Sliding window (N=100) with forgetting factor & sudden change
theta_SW_forgetting_100 = SW_forgetting(input, output, output2, lambda, 100, changeParam, t, graphCount);
graphCount = graphCount + 6;

%8. Sliding window (N=10) with noise
theta_SW_noise_10 = SW_noise(input, output, noise, output2, lambda, 10, changeParam, t, graphCount);
graphCount = graphCount + 6;
%8. Sliding window (N=100) with noise
theta_SW_noise_100 = SW_noise(input, output, noise, output2, lambda, 100, changeParam, t, graphCount);
graphCount = graphCount + 6;
