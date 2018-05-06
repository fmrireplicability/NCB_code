function analysis3d_matched_prop_stability_calc_alltasks_directed(thr)

% Four path snippets to stitch together with iter, group, sample size
path1 = 'sample';
path2 = '/iter';
path3 = '_';
path4 = '_stats/thresh_directed/matched_prop_';
path5 = {'/Volumes/REDACTED/fmri_stability/3back/cope4/','/Volumes/REDACTED/fmri_stability/ObLocRM/cope2/','/Volumes/REDACTED/fmri_stability/PPA/FNIRTcope1/','/Volumes/REDACTED/fmri_stability/SST/cope3/'};

if thr == 1
    thresh_level = 'con';
else
    thresh_level = 'lib';
end

outpath_to_dropbox = ['/Users/REDACTED/Dropbox/REDACTED/fmri_stability/analyses/matchedprop_alltasks_directed_' thresh_level '.mat']; % Change this to the path to dropbox

samples = {'16','25','36','49','64','81','100','121'};

% Horrible brittle code, order has to match path5 order
cross_group = struct('back3',zeros(500,length(samples)-1),...
                     'obloc',zeros(500,length(samples)-1),...
                     'PPA',zeros(500,length(samples)),...
                     'SST',zeros(500,length(samples)));
fn = fieldnames(cross_group);

% mask2 = read_avw([path5{2} 'mask.nii.gz']);
% mask = mask1.*mask2;

% Optionally, load in mask image, change all curMap defs to 
% curMap = curMap.* mask

for task = 1:length(path5)

    mask = read_avw([path5{task} 'mask.nii.gz']);

    for iter = 1:500

        for sample = 1:size(cross_group.(fn{task}),2)

            mapA1 = read_avw([path5{task} path1 samples{sample} path2 ... 
                num2str(iter) path3 'A' path4 thresh_level '.nii.gz']);
            mapB1 = read_avw([path5{task} path1 samples{sample} path2 ...
                num2str(iter) path3 'B' path4 thresh_level '.nii.gz']);

            mapA1 = int32(mapA1.*mask);% mapA1 = int32(mapA1>0);
            mapB1 = int32(mapB1.*mask);% mapB1 = int32(mapB1>0);

            numer = abs(mapA1(:)+mapB1(:));
            denom = abs(mapA1(:))+abs(mapB1(:));
            cross_group.(fn{task})(iter,sample) = sum(numer==2)/sum(denom>0);

        end

        disp(['Iteration' num2str(iter) ' done']);

    end
    
end

save(outpath_to_dropbox,'cross_group')