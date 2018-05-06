# Loop through all zstat images

iters=`seq 1 500`
vers='A B'

#s='16'
samples='16 25 36 49 64 81 100 121'
#task='SST'
#cope='cope3'

#task='PPA'
#cope='cope1'

#task='3back'
#cope='cope4'
#samples='16 25 36 49 64 81 100'

task='ObLocRM'
cope='cope2'
samples='16 25 36 49 64 81 100'

curdir=$( pwd )
root=/Volumes/REDACTED/fmri_stability

for s in $samples; do

if [ ! -e ${curdir}/fwhm_dist_${task}_${s}.txt ]; then

	for iter in $iters; do

		for ver in $vers; do
		
			cd ${root}/${task}/${cope}/sample${s}/iter${iter}_${ver}_stats

			# For every zstat image, do

			temp=$( smoothest -z pe1.nii.gz -m ../../mask.nii.gz -V | awk /'mm'/ )

			x=$( echo $temp | cut -d'=' -f2 | cut -d'm' -f1 )
			y=$( echo $temp | cut -d'=' -f3 | cut -d'm' -f1 )
			z=$( echo $temp | cut -d'=' -f4 | cut -d'm' -f1 )

			#y=$( smoothest -z pe1.nii.gz -m ../../mask.nii.gz -V | awk /'mm'/ | awk -F"mm" '{print $2}' | awk -F"=" '{print $2}' )


			# Use magic to compute average, save to new file
			echo "scale=2; ($x+$y+$z)/3" | bc >> ${curdir}/fwhm_dist_${task}_${s}.txt

			# Use similar approach to characterize robust ranges of maps
			fslstats pe1.nii.gz -r >> ${curdir}/range_dist_${task}_${s}.txt
		
		done
	
	done

fi


cd ${curdir}

if [ ! -d ${root}/misc/scripts/null_smooth_maps/smooth_maps/${task} ]; then
	mkdir ${root}/misc/scripts/null_smooth_maps/smooth_maps/${task} 
fi
if [ ! -d ${root}/misc/scripts/null_smooth_maps/smooth_maps/${task}/${s} ]; then
	mkdir ${root}/misc/scripts/null_smooth_maps/smooth_maps/${task}/${s}
fi

# Parameterize distribution, sample niter values from distribution (matlab)
/Applications/MATLAB_R2014a.app/bin/matlab -nosplash -nodisplay -nojvm -r "draw_samples('$task',$s);quit;"

# For each of niter randn maps, choose sample, compute sigma
niters=`seq 0 999`

old_IFS=$IFS
IFS=$'\n'
fwhms=($(cat "${curdir}/sampled_fwhms_${task}_${s}.txt"))
maxs=($(cat "${curdir}/sampled_maxs_${task}_${s}.txt"))
mins=($(cat "${curdir}/sampled_mins_${task}_${s}.txt"))
IFS=$old_IFS

for nit in $niters; do

	#nullmap index
	ind=$( echo "$nit+1" | bc )

	temp=$( smoothest -z ${root}/misc/scripts/null_smooth_maps/unsmoothed_maps/null_uns$ind.nii.gz -m ${root}/${task}/${cope}/mask.nii.gz -V | awk /'mm'/ )
	tx=$( echo $temp | cut -d'=' -f2 | cut -d'm' -f1 )
	ty=$( echo $temp | cut -d'=' -f3 | cut -d'm' -f1 )
	tz=$( echo $temp | cut -d'=' -f4 | cut -d'm' -f1 )

	# More magic --> average
	avgfwhm=$( echo "scale=2; ($tx+$ty+$tz)/3" | bc )

	# Kernel sigma is (average2 - average1)*0.34
	sigma=$( echo "scale=2; (${fwhms[nit]} - $avgfwhm)*0.42" | bc )

	# Apply kernel to randn map (dilating the brain image to avoide smoothing 0s into edge voxels)
	fslmaths ${root}/misc/scripts/null_smooth_maps/unsmoothed_maps/null_uns$ind.nii.gz -kernel sphere 6 -dilM -s ${sigma} -mul ${root}/${task}/${cope}/mask.nii.gz outmap_$task
	

	# Use sample from robust range distribution to shift outmap to match
	tminmax=$( fslstats outmap_$task -r )
	outmap_min=$( echo $tminmax | cut -d' ' -f1 )
	outmap_max=$( echo $tminmax | cut -d' ' -f2 )
	outmap_range=$( echo "scale=2; ($outmap_max - $outmap_min)" | bc )
	
	sampled_range=$( echo "scale=2; (${maxs[nit]} - ${mins[nit]})" | bc )
	
	fslmaths outmap_$task -sub $outmap_min -div $outmap_range -mul $sampled_range -add ${mins[nit]} -mul ${root}/${task}/${cope}/mask.nii.gz ${root}/misc/scripts/null_smooth_maps/smooth_maps/${task}/${s}/null_smooth$ind

done

done
