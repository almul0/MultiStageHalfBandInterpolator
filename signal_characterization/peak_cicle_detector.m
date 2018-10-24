function [ilpkh_locs, ilpkl_locs] = peak_cicle_detector(il, fs, fsw)
    cicle_n = round(0.7*fs/fsw);
    [~,ilpkh_locs]= findpeaks(il,'MinPeakDistance',cicle_n);    
    [~,ilpkl_locs]= findpeaks(-1*il,'MinPeakDistance',cicle_n);   
end