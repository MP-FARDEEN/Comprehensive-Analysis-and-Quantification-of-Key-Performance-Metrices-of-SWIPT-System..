clc; clear; close all;

% Parameters
SNR_dB = 0:2:30; % SNR range in dB
SNR_linear = 10.^(SNR_dB / 10); % Convert dB to linear scale
rho_values = [0.2, 0.4, 0.6, 0.8]; % Power splitting ratios
num_bits = 1e6; % Increase for better accuracy

BER_theoretical = zeros(length(rho_values), length(SNR_dB));
BER_simulated = zeros(length(rho_values), length(SNR_dB));

for idx = 1:length(rho_values)
    rho = rho_values(idx);
    
    for k = 1:length(SNR_linear)
        % Effective SNR based on power splitting
        gamma_eff = (1 - rho) * SNR_linear(k); 

        % Theoretical BER for Rayleigh fading
        BER_theoretical(idx, k) = 0.5 * (1 - sqrt(gamma_eff ./ (1 + gamma_eff)));

        % Monte Carlo Simulation
        h = (randn(1, num_bits) + 1j * randn(1, num_bits)) / sqrt(2); % Rayleigh fading
        noise_variance = 1 / (2 * (1 - rho) * SNR_linear(k)); % Proper noise scaling
        noise = sqrt(noise_variance) * (randn(1, num_bits) + 1j * randn(1, num_bits));

        % BPSK Modulation
        tx_bits = randi([0 1], 1, num_bits);
        tx_symbols = 2 * tx_bits - 1; % BPSK mapping (0 -> -1, 1 -> 1)

        % Received Signal
        rx_symbols = h .* tx_symbols + noise;  

        % Equalization
        rx_equalized = real(rx_symbols ./ h); 

        % Decision Rule
        rx_decision = rx_equalized > 0;
        
        % BER Calculation
        BER_simulated(idx, k) = sum(rx_decision ~= tx_bits) / num_bits;
    end
end

% Plot BER curves
figure; hold on;
colors = {'r', 'g', 'b', 'm'}; % Different colors for rho values

for idx = 1:length(rho_values)
    semilogy(SNR_dB, BER_theoretical(idx, :), '-', 'LineWidth', 2, 'Color', colors{idx}, ...
        'DisplayName', ['Theoretical \rho = ', num2str(rho_values(idx))]);
    semilogy(SNR_dB, BER_simulated(idx, :), 'o--', 'LineWidth', 4, 'Color', colors{idx}, ...
        'DisplayName', ['Simulated \rho = ', num2str(rho_values(idx))]);
end

xlabel('SNR (dB)'); ylabel('BER');
title('BER vs. SNR for SWIPT System with Power Splitting');
grid on; legend('show');
set(gca, 'YScale', 'log'); % Set y-axis to log scale
