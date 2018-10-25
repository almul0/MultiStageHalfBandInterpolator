function [tdh_locs, tdl_locs] = diode_driving_time(zcl, tsnbhl, tsnbll)
    tdh_locs = zeros(size(tsnbhl));
    tdl_locs = zeros(size(tsnbhl));
    for i=1:numel(tsnbhl)        
        if ( find(zcl>tsnbhl(i),1)) 
            tdh_locs(i) = zcl(find(zcl>tsnbhl(i),1));
        end
    end
    for i=1:numel(tsnbll)
        if ( find(zcl>tsnbll(i),1)) 
            tdl_locs(i) = zcl(find(zcl>tsnbll(i),1));
        end
    end
end