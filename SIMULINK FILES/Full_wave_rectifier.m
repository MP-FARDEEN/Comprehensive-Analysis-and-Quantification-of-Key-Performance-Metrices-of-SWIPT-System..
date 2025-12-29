function rectifiedSignal = rectifier(demodulatedSignal)
    % Rectify the input signal
    rectifiedSignal = abs(demodulatedSignal); % Full-wave rectification
end
