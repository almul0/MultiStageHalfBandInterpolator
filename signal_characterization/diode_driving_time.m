function [tdhn, tdln] = diode_driving_time(zcl, tsnbhl, tsnbll)
    tdhn = zeros(size(tsnbhl));
    tdln = zeros(size(tsnbhl));
    for i=1:numel(tsnbhl)        
        if ( find(zcl>tsnbhl(i),1)) 
            tdhn(i) = zcl(find(zcl>tsnbhl(i),1))-tsnbhl(i);
        end
    end
    for i=1:numel(tsnbll)
        if ( find(zcl>tsnbll(i),1)) 
            tdln(i) = zcl(find(zcl>tsnbll(i),1))-tsnbll(i);
        end
    end
end