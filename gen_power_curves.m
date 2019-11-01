% Experiment parameters.
sampleSizes = 10:10:20;
numSims=35;
alpha=0.05;
processes = ["indep_ar1"];

% Setup.
% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
rng('default')
tic
powers = zeros(length(sampleSizes),1);

for process = processes
    
    dat = load(sprintf('data/%s_data.mat', process));

    % Load data generated in Python.
    X_full = dat.X_full;
    Y_full = dat.Y_full;

    pool = parpool;
    parfor i = 1:length(sampleSizes)
        tic
        n = sampleSizes(i);
        partialResults = zeros(numSims,1);
        bootstrapedValuesShift=[];

        for s=1:numSims
            X = X_full(1:n, s);
            Y = Y_full(1:n, s);
            result = wildHSIC(X,Y) 
            partialResults(i) = result.reject;
        end           
        toc
        powers(i) = mean(partialResults,1);
    end
    filename = sprintf("power_curves/wildHSIC_powers_%s.mat", process);
    save(filename,'powers')
end
toc
delete(pool)
