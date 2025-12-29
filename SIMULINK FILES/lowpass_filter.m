function y = lowpass_filter(x, fc, Ts)
    % Low-pass filter for complex input signals after downconversion
    % x: Complex input signal (from downconversion)
    % fc: Cutoff frequency of the low-pass filter (Hz)
    % Ts: Sample time (seconds)

    % Declare the output as complex to handle complex input
    y = complex(0);

    % Persistent variable to store the previous output (y[n-1])
    persistent prev_y;
    
    % Initialize prev_y to 0 if this is the first run
    if isempty(prev_y)
        prev_y = complex(0);  % Initialize as complex zero
    end
    
    % Calculate the filter coefficient (alpha) based on the cutoff frequency and sample time
    alpha = 2 * pi * fc * Ts / (2 * pi * fc * Ts + 1);
    
    % Apply the low-pass filter equation: y[n] = alpha * x[n] + (1 - alpha) * y[n-1]
    y = alpha * x + (1 - alpha) * prev_y;
    
    % Store the current output for use in the next iteration (y[n-1] = y[n])
    prev_y = y;
end
