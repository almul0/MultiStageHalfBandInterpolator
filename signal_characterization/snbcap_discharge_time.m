function [tsnbh_locs, tsnbl_locs] = snbcap_discharge_time(il, vbus, fs, rlocs, flocs)
    Csnb = (2*15)*1e-9;
    tsnbh_locs = zeros(size(flocs));
    tsnbl_locs = zeros(size(rlocs));
    last_sample = numel(il);
    Tsint = 1/fs;
    for  i=1:numel(flocs)
        n = flocs(i);       
        vsnb = abs(Tsint*il(n)/2/Csnb);
        while (vbus(n) >= vsnb && n <= last_sample)
            n = n+1;
            vsnb = abs(Tsint*sum(il(flocs(i):n))/2/Csnb);
        end
        tsnbh_locs(i,1) = n;            
    end
    for  i=1:numel(rlocs)
        n = rlocs(i);       
        vsnb = abs(Tsint*il(n)/2/Csnb);
        while (vbus(n) >= vsnb && n <= last_sample)
            n = n+1;
            vsnb = abs(Tsint*sum(il(rlocs(i):n))/2/Csnb);
        end
        tsnbl_locs(i,1) = n;          
    end
end