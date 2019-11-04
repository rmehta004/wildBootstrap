% Experiment parameters.
sampleSizes = 110:100:510;
alpha=0.05;
processes = ["indep_ar1", "corr_ar1", "econometric_proc", "dynamic_proc"];

% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')
tic
powers = zeros(length(sampleSizes), 2);

pool = parpool;
for process = processes
    
    dat = load(sprintf('data/%s_data.mat', process));
    fprintf("PROCESS: %s\n", process);

    % Load data generated in Python.
    X_full = dat.X_full;
    Y_full = dat.Y_full;
    numSims = size(X_full, 2);

    parfor i = 1:length(sampleSizes)
        tic
        n = sampleSizes(i);
        fprintf("SAMPLE_SIZE: %d\n", n);
        partialResults = zeros(numSims, 1);

        for s=1:numSims
            X = X_full(1:n, s);
            Y = Y_full(1:n, s);
            result = wildHSIC(X,Y); 
            partialResults(s) = result.reject;
        end           
        toc
        powers(i, :) = [n, mean(partialResults)];
    end
    filename = sprintf("power_curves/wildHSIC_powers_%s.mat", process);
    disp(powers)
    save(filename,'powers')
end
toc
delete(pool)
