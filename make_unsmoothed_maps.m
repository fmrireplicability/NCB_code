mask = read_avw('/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz');

for i = 1:1000
    
    empty = mask;
    empty(mask>0) = randn(numel(nonzeros(mask)),1);
    
    save_avw(empty,['unsmoothed_maps/null_uns' num2str(i) '.nii.gz'],'f',[2 2 2 1]);
    
end