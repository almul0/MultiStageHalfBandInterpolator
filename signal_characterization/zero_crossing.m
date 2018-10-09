function [zc, zc_d] = zero_crossing(z)
    zprev = z(1);
    zc = zeros(size(z));
    zc_d = zeros(size(z));
    for i=2:size(z,1)
       if (zprev == 0 && z(i) ~= 0)           
           zc(i-1) = 2;
           zc(i) = 1;
           zc_d(i) = (i-1)+zero_crossing_d(zprev,z(i));
       elseif ( z(i) ~= 0 && sign(zprev) ~= sign(z(i)) )
           zc(i-1) = 1;
           zc(i) = 1;
           zc_d(i) = (i-1)+zero_crossing_d(zprev,z(i));
       end
       zprev = z(i);
    end
    
end

function [zc_d] = zero_crossing_d(zn, zn1)
    zc_d = -zn/(zn1-zn);
end