function [] = interpolation_quality(s1,s2, D, fsw, display)

s1 = signal_quality_parameters(s1, fsw);
s2 = signal_quality_parameters(s2, fsw);

if display

    fprintf('%d KHz\tmean\tstd\tmin\tmax\n', fsw/1e3)
    fprintf('e_ilrms\t%.4f\n', abs(s1.il_rms-s2.il_rms));
    fprintf('e_pavg\t%.4f\n', abs(s1.p_avg-s2.p_avg));
    ilpkh_stats = datastats(abs(s1.ilpkh-s2.ilpkh));
    fprintf('ilpk,H\t%.1e\t%.1e\t%.1e\t%.1e\n',ilpkh_stats.mean, ilpkh_stats.std, ilpkh_stats.min, ilpkh_stats.max);

    ilpkl_stats = datastats(abs(s1.ilpkl-s2.ilpkl));
    fprintf('ilpk,L\t%.1e\t%.1e\t%.1e\t%.1e\n',ilpkl_stats.mean, ilpkl_stats.std, ilpkl_stats.min, ilpkl_stats.max);
    
    
    ioffh_stats = datastats(abs(s1.ioffh-s2.ioffh));
    fprintf('ioff,H\t%.1e\t%.1e\t%.1e\t%.1e\n',ioffh_stats.mean, ioffh_stats.std, ioffh_stats.min, ioffh_stats.max);

    ioffl_stats = datastats(abs(s1.ioffl-s2.ioffl));
    fprintf('ioff,L\t%.1e\t%.1e\t%.1e\t%.1e\n',ioffl_stats.mean, ioffl_stats.std, ioffl_stats.min, ioffl_stats.max);

    tsnbh_stats = datastats(abs(s1.tsnbh-s2.tsnbh));
    fprintf('tsnb,H\t%.1e\t%.1e\t%.1e\t%.1e\n',tsnbh_stats.mean, tsnbh_stats.std, tsnbh_stats.min, tsnbh_stats.max);

    tsnbl_stats = datastats(abs(s1.tsnbl-s2.tsnbl));
    fprintf('tsnb,L\t%.1e\t%.1e\t%.1e\t%.1e\n',tsnbl_stats.mean, tsnbl_stats.std, tsnbl_stats.min, tsnbl_stats.max);

    tdh_stats = datastats(abs(s1.tdh-s2.tdh));
    fprintf('td,H\t%.1e\t%.1e\t%.1e\t%.1e\n',tdh_stats.mean, tdh_stats.std, tdh_stats.min, tdh_stats.max);

    tdl_stats = datastats(abs(s1.tdl-s2.tdl));
    fprintf('td,L\t%.1e\t%.1e\t%.1e\t%.1e\n',tdl_stats.mean, tdl_stats.std, tdl_stats.min, tdl_stats.max);
end

end

