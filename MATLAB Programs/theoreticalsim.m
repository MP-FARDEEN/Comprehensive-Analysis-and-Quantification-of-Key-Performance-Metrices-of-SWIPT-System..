% Parameters
fc = 2e9;               % Carrier frequency (2 GHz)
A = 1;                  % Amplitude of the BPSK signal
G = 10;                 % Gain of the power amplifier
rho = 0.5;              % Power splitting factor for EH path
SNR_dB = 0:2:20;        % Signal-to-noise ratio in dB
SNR_linear = 10.^(SNR_dB/10); % Linear SNR scale
fading_magnitude = 0.8; % Fading channel magnitude
theta_i = pi/4;         % Initial phase of the transmitted signal
n_iterations = 1e5;     % Number of bits for simulation
bit_rate = 1e6;         % Bit rate (1 Mbps)

% Generate Binary Data
data_bits = randi([0, 1], 1, n_iterations); % Binary data stream {0, 1}

% BPSK Modulation
bpsk_signal = 2*data_bits - 1; % Map 0 -> -1, 1 -> +1

% Transmitter Signal Model
t = (0:n_iterations-1)/bit_rate;  % Time vector
st = A * cos(2 * pi * fc * t + theta_i); % Modulated signal s(t)
s_RF = A * cos(2 * pi * fc * t + theta_i); % RF upconversion signal s_RF(t)
stx = G * s_RF; % Amplified signal stxn(t)

% Initialize arrays to store results
BER = zeros(size(SNR_dB)); % Array to store BER for each SNR
P_harvested = zeros(size(SNR_dB)); % Array to store harvested power for each SNR

% Loop over each SNR value
for k = 1:length(SNR_linear)
    % AWGN + Rayleigh Fading Channel for the current SNR
    noise = sqrt(1 / SNR_linear(k)) * randn(size(stx)); % Noise with current SNR
    rayleigh_fading = fading_magnitude * exp(1j * theta_i); % Fading channel h(t)
    received_signal = abs(rayleigh_fading) * stx + noise; % Channel output
    
    % Power Splitter for EH and ID Paths
    r_EH = sqrt(rho) * received_signal; % Energy Harvesting Path r_EH(t)
    r_ID = sqrt(1 - rho) * received_signal; % Information Decoding Path r_ID(t)
    
    % Energy Harvesting Path - Rectification
    r_rect = abs(r_EH); % Rectified signal

    % Information Decoding Path - Down Conversion
    downconverted_signal = r_ID .* cos(2 * pi * fc * t); % Mixing with LO

    % Low-pass Filter to Remove High Frequency Component
    r_base = sqrt(1 - rho) * abs(rayleigh_fading) * G * A * cos(theta_i + angle(rayleigh_fading)); % Baseband signal after LPF

    % BPSK Demodulation
    bpsk_demodulated = sign(r_base .* cos(theta_i + angle(rayleigh_fading))); % Demodulated signal

    % BER Calculation
    errors = sum(bpsk_demodulated ~= (2*data_bits - 1)); % Count errors
    BER(k) = errors / n_iterations;

    % Harvested Power Calculation
    P_harvested(k) = (rho * A^2) * abs(rayleigh_fading)^2 * G; % Harvested power
end

% Plot BER vs SNR
figure;
subplot(2,1,1);
semilogy(SNR_dB, BER, 'b-o', 'LineWidth', 2);
title('BER vs SNR');
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
grid on;

% Plot Harvested Power vs SNR
subplot(2,1,2);
plot(SNR_dB, P_harvested, 'r-o', 'LineWidth', 2);
title('Harvested Power vs SNR');
xlabel('SNR (dB)');
ylabel('Harvested Power (Watts)');
grid on;
