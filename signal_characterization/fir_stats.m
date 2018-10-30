function fir_stats(coeffs, R, type)
    n = numel(coeffs)-1;
    z = sum(coeffs==0);
    if ( all(coeffs==fliplr(coeffs)) ) 
        fprintf('Simetria: Sí\tCoeffs: %d\t Ceros:%d\tMults:%d\tAdders:%d\n',n+1, z, ceil((n-z)/2), n-1);
    else
        fprintf('Simetria: No\tCoeffs: %d\t Ceros:%d\tMults:%d\tAdders:%d\n',n+1, z, n+1-z, n-1)
    end
end