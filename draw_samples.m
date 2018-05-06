function draw_samples(task,sample)

sample=num2str(sample);

ranges = load(['range_dist_' task '_' sample '.txt']);
sampled_mins = randn(1000,1)*std(ranges(:,1))+mean(ranges(:,1));
sampled_maxs = randn(1000,1)*std(ranges(:,2))+mean(ranges(:,2));

fid = fopen(['sampled_mins_' task '_' sample '.txt'],'w');
fprintf(fid,'%f\n',sampled_mins);
fclose(fid);

fid = fopen(['sampled_maxs_' task '_' sample '.txt'],'w');
fprintf(fid,'%f\n',sampled_maxs);
fclose(fid);

fwhms = load(['fwhm_dist_' task '_' sample '.txt']);
sampled_fwhms = randn(1000,1)*std(fwhms)+mean(fwhms);

fid = fopen(['sampled_fwhms_' task '_' sample '.txt'],'w');
fprintf(fid,'%f\n',sampled_fwhms);
fclose(fid);