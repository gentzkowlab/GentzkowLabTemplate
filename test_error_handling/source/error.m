% MATLAB script with intentional error

fprintf('MATLAB script starting...\n');
fprintf('This will produce some output...\n');
pause(1);

fprintf('\nOutputting multiple lines to test real-time logging:\n');
for i = 1:5
    fprintf('  Line %d of output\n', i);
    pause(0.5);
end

fprintf('\nNow encountering an error...\n');
pause(1);

% Intentional error
error('ERROR: Something went wrong in MATLAB!');
