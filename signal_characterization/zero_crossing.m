function [zlocs] = zero_crossing(z, mzd, approximate)
    zprev = z(1);
    zlocs = zeros(size(z));
    zlocsi = 0;
    for i=2:size(z,1)
%        if (zprev == 0 && z(i) ~= 0)           
%            zlocs(zlocsi) = (i-1)+zero_crossing_d(zprev,z(i));
%            zlocsi = zlocsi+1;
%        elseif ( z(i) ~= 0 && sign(zprev) ~= sign(z(i)) )
%            zclocs(i) = (i-1)+zero_crossing_d(zprev,z(i));
%        end
        if ( zlocsi == 0 || (i - zlocs(zlocsi)) >= mzd )
            if ( (sign(zprev) ~= sign(z(i)) || zprev == 0) && z(i) ~= 0 )
                zlocsi = zlocsi+1;
                if (approximate)
                    zlocs(zlocsi) = (i-1)+zero_crossing_d(zprev,z(i));
                else
                    zlocs(zlocsi) = i;
                end
            end
        end
        zprev = z(i);
    end
    zlocs = zlocs(1:zlocsi-1);
    
end

function [zc_d] = zero_crossing_d(zn, zn1)
    zc_d = -zn/(zn1-zn);
end