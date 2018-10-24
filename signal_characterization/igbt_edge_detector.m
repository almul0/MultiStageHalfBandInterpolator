function [rlocs, flocs] = igbt_edge_detector(vo, vbus)    
    rlocs = find(vo(1:end-1)<(vbus(1:end-1)/4) & vo(2:end)>=(vbus(2:end)/4));
    flocs = find(vo(1:end-1)>=(vbus(1:end-1)*3/4) & vo(2:end)<(vbus(2:end)*3/4));
end