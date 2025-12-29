clc; clear; close all;

% Define Parameters
N0 = 1e-9; % Noise power (W)
BER_threshold = 1e-6; % Define target BER for error-free decoding
rho_values = 0:0.2:1; % Vary power splitting ratio from 0 to 1 in steps of 0.2

% Define a wide range of SNR values
SNR_values = logspace(-2, 6, 100000); % SNR in linear scale

% Compute BER from given equation
BER_values = 0.5 * (1 - sqrt(SNR_values ./ (1 + SNR_values)));

figure; hold on;
colors = lines(length(rho_values)); % Get distinct colors for each rho

for i = 1:length(rho_values)
    rho = rho_values(i); % Select rho value
    
    % Compute received power for each SNR
    P_r_values = (2 * N0 * SNR_values) ./ (1 - rho + eps); % Avoid division by zero
    
    % Compute information decoding power and energy harvesting power
    P_ID_values = (1 - rho) * P_r_values * 1e3; % Convert W to mW
    P_EH_values = rho * P_r_values * 1e3; % Convert W to mW

    % Find the minimum SNR that achieves BER ≤ BER_threshold
    index = find(BER_values <= BER_threshold, 1);

    if isempty(index)
        fprintf('For rho = %.1f: BER threshold not reached within SNR range.\n', rho);
    else
        SNR_min_ID = SNR_values(index); % Minimum required SNR
        P_r_min = P_r_values(index) * 1e3; % Convert W to mW
        P_ID_min = P_ID_values(index); % Minimum power for information decoding (mW)
        P_EH_min = P_EH_values(index); % Minimum power for energy harvesting (mW)

        % Print results
        fprintf('For rho = %.1f:\n', rho);
        fprintf('  Minimum SNR required for information decoding: %.2f dB\n', 10*log10(SNR_min_ID));
        fprintf('  Minimum received power (P_r_min): %.3f mW\n', P_r_min);
        fprintf('  Minimum decoding power (P_ID_min): %.3f mW\n', P_ID_min);
        fprintf('  Minimum energy harvesting power (P_EH_min): %.3f mW\n', P_EH_min);
    end

    % Plot BER vs. P_ID
    loglog(BER_values, P_ID_values, '-', 'LineWidth', 2, 'Color', colors(i, :), 'DisplayName', sprintf('P_{ID} (rho=%.1f)', rho));

    % Plot BER vs. P_EH
    loglog(BER_values, P_EH_values, '--', 'LineWidth', 2, 'Color', colors(i, :), 'DisplayName', sprintf('P_{EH} (rho=%.1f)', rho));
    
    % Mark minimum required power for ID and EH
    if ~isempty(index)
        plot(BER_values(index), P_ID_min, 'o', 'MarkerSize', 8, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k');
        plot(BER_values(index), P_EH_min, 's', 'MarkerSize', 8, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k');
    end
end

% Labels and Title
xlabel('Bit Error Rate (BER)');
ylabel('Power (mW)');
title('BER vs. Information Decoding & Energy Harvesting Power for Different \rho');
legend show;
grid on;
