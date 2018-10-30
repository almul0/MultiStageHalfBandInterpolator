function [] = interpolation_quality(s1,s2, D, fsw, display)

s1 = signal_quality_parameters(s1, fsw);
s2 = signal_quality_parameters(s2, fsw);

if display

    fprintf('%d KHz\tmean\tstd\tmin\tmax\n', fsw/1e3)
    fprintf('e_ilrms\t%.3f\n', abs(s1.il_rms-s2.il_rms)./s1.il_rms*100);
    fprintf('e_pavg\t%.3f\n', abs(s1.p_avg-s2.p_avg)./s1.p_avg*100);
    ilpkh_stats = datastats(abs(s1.ilpkh-s2.ilpkh)./s1.ilpkh*100);
    fprintf('ilpk,H\t%.3f\t%.3f\t%.3f\t%.3f\n',ilpkh_stats.mean, ilpkh_stats.std, ilpkh_stats.min, ilpkh_stats.max);

    ilpkl_stats = datastats(abs(s1.ilpkl-s2.ilpkl)./s1.ilpkl*100);
    fprintf('ilpk,L\t%.3f\t%.3f\t%.3f\t%.3f\n',ilpkl_stats.mean, ilpkl_stats.std, ilpkl_stats.min, ilpkl_stats.max);
    
    
    ioffh_stats = datastats(abs(s1.ioffh-s2.ioffh)./s1.ioffh*100);
    fprintf('ioff,H\t%.3f\t%.3f\t%.3f\t%.3f\n',ioffh_stats.mean, ioffh_stats.std, ioffh_stats.min, ioffh_stats.max);

    ioffl_stats = datastats(abs(s1.ioffl-s2.ioffl)./s1.ioffl*100);
    fprintf('ioff,L\t%.3f\t%.3f\t%.3f\t%.3f\n',ioffl_stats.mean, ioffl_stats.std, ioffl_stats.min, ioffl_stats.max);

    tsnbh_stats = datastats(abs(s1.tsnbh-s2.tsnbh)./s1.tsnbh*100);
    fprintf('tsnb,H\t%.3f\t%.3f\t%.3f\t%.3f\n',tsnbh_stats.mean, tsnbh_stats.std, tsnbh_stats.min, tsnbh_stats.max);
    
    tsnbh_tstats = datastats(abs(s1.tsnbh-s2.tsnbh)*1e9);
    fprintf('(ns)\t%.3f\t%.3f\t%.3f\t%.3f\n',tsnbh_tstats.mean, tsnbh_tstats.std, tsnbh_tstats.min, tsnbh_tstats.max);

    tsnbl_stats = datastats(abs(s1.tsnbl-s2.tsnbl)./s1.tsnbl*100);
    fprintf('tsnb,L\t%.3f\t%.3f\t%.3f\t%.3f\n',tsnbl_stats.mean, tsnbl_stats.std, tsnbl_stats.min, tsnbl_stats.max);
    
    tsnbl_tstats = datastats(abs(s1.tsnbl-s2.tsnbl)*1e9);
    fprintf('(ns)\t%.3f\t%.3f\t%.3f\t%.3f\n',tsnbl_tstats.mean, tsnbl_tstats.std, tsnbl_tstats.min, tsnbl_tstats.max);

    tdh_stats = datastats(abs(s1.tdh-s2.tdh)./s1.tdh*100);
    fprintf('td,H\t%.3f\t%.3f\t%.3f\t%.3f\n',tdh_stats.mean, tdh_stats.std, tdh_stats.min, tdh_stats.max);
    
    tdh_tstats = datastats(abs(s1.tdh-s2.tdh)*1e9);
    fprintf('(ns)\t%.3f\t%.3f\t%.3f\t%.3f\n',tdh_tstats.mean, tdh_tstats.std, tdh_tstats.min, tdh_tstats.max);

    tdl_stats = datastats(abs(s1.tdl-s2.tdl)./s1.tdl*100);
    fprintf('td,L\t%.3f\t%.3f\t%.3f\t%.3f\n',tdl_stats.mean, tdl_stats.std, tdl_stats.min, tdl_stats.max);
    tdl_tstats = datastats(abs(s1.tdl-s2.tdl)*1e9);
    fprintf('(ns)\t%.3f\t%.3f\t%.3f\t%.3f\n',tdl_tstats.mean, tdl_tstats.std, tdl_tstats.min, tdl_tstats.max);
end

end

