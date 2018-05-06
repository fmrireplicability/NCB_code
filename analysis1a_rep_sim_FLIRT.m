%function stability_working_fn()

% Four path snippets to stitch together with iter, group, sample size
path1 = 'sample';
path2 = '/iter';
path3 = '_';
path4 = '_stats/';
path5 = {'/Volumes/REDACTED/fmri_stability/PPA/cope1/'};

outpath_to_dropbox = '/Users/REDACTED/Dropbox/REDACTED/fmri_stability/analyses/rep_sim_FLIRT.mat'; % Change this to the path to dropbox

samples = {'16','25','36','49','64','81','100','121'};

cross_group = zeros(500,length(samples));

% Optionally, load in mask image, change all curMap defs to 
% curMap = curMap.* mask

for iter = 1:500

    for sample = 1:length(samples)

        mapA1 = read_avw([path5{1} path1 samples{sample} path2 ... 
            num2str(iter) path3 'A' path4 'pe1.nii.gz']);
        mapB1 = read_avw([path5{1} path1 samples{sample} path2 ...
            num2str(iter) path3 'B' path4 'pe1.nii.gz']);
        
        curA = mapA1; curB = mapB1;
        curA(curB==0) = 0;
        curB(curA==0) = 0;

        temp = corrcoef(nonzeros(curA),nonzeros(curB));
        cross_group(iter,sample) = temp(1,2);
        
    end
        
    disp(['Iteration' num2str(iter) ' done']);
    
end

save(outpath_to_dropbox,'cross_group')