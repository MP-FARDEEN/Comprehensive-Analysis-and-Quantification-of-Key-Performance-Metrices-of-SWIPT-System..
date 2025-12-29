clc; clear; close all;

% Define parameters
rho = 0.1:0.1:1; % Power splitting ratio (starting from 0.1 to avoid zero power)
P_t = 10; % Transmit power in Watts
L_p = 0.125; % Path loss factor
N0 = 1e-9; % Noise power
num_trials = 1000; % Number of channel realizations for averaging

% Initialize arrays for storing averaged values
P_EH_avg = zeros(size(rho));
BER_avg = zeros(size(rho));

for trial = 1:num_trials
    % Generate Rayleigh fading channel
    h = sqrt(1/2) * (randn(1, length(rho)) + 1j * randn(1, length(rho)));

    % Compute Received Power (Pr)
    P_r = abs(h).^2 * P_t * L_p + N0;

    % Compute Energy Harvested (P_EH)
    P_EH = rho .* P_r;

    % Compute SNR at information decoding path
    SNR = ((1 - rho) .* P_r) ./ (2 * N0);

    % Compute BER using given formula
    BER = 0.5 * (1 - sqrt(SNR ./ (1 + SNR)));

    % Accumulate results for averaging
    P_EH_avg = P_EH_avg + P_EH;
    BER_avg = BER_avg + BER;
end

% Compute average values
P_EH_avg = P_EH_avg / num_trials;
BER_avg = BER_avg / num_trials;

% Sort data to ensure a smooth plot
[BER_sorted, idx] = sort(BER_avg);
P_EH_sorted = P_EH_avg(idx);

% Plot BER vs. Energy Harvested
figure;
plot(BER_sorted, P_EH_sorted * 1e3, 'bo-', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 6);
xlabel('Bit Error Rate (BER)');
ylabel('Energy Harvested (mW)');
title('BER vs. Energy Harvested');
grid on;
set(gca, 'XScale', 'log'); % Log scale for BER
ylim([min(P_EH_sorted * 1e3), max(P_EH_sorted * 1e3)]); % Set y-axis range dynamically

