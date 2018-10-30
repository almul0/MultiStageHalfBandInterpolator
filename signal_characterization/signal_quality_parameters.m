function [ss, range] = signal_quality_parameters(ss, fsw)

nperiods = 32;
nperiod2 = round(nperiods*(1/fsw)*ss.fs/2);
nstart = ceil(size(ss.il,1)/2)-(nperiod2)-round((ss.fs/fsw)/8);
nend = ceil(size(ss.il,1)/2)+(nperiod2)-round((ss.fs/fsw)/8);

ss.range = [nstart nend];

l = size(ss.il,1);
l099 = (round(l*0.005):round(l*0.995));
ss.il_rms = rms(ss.il(l099));
ss.p_avg = mean(ss.il(l099).*ss.vo(l099));

il_range = ss.il(nstart:nend);
vo_range = ss.vo(nstart:nend);
vbus_range = ss.vbus(nstart:nend);

[ss.ilpkh_locs, ss.ilpkl_locs] = peak_cicle_detector(il_range, ss.fs, fsw);
ss.ilpkh = il_range(ss.ilpkh_locs);
ss.ilpkl = il_range(ss.ilpkl_locs);

[ss.rise_locs, ss.fall_locs] = igbt_edge_detector(vo_range, vbus_range);

[ss.ioffh, ss.ioffl] = off_transition_current(il_range, ss.rise_locs, ss.fall_locs);

[ss.tsnbh_locs, ss.tsnbl_locs] = snbcap_discharge_time(il_range, vbus_range, ss.fs, ss.rise_locs, ss.fall_locs);

ss.tsnbh = 1/ss.fs * (ss.tsnbh_locs-ss.fall_locs);
ss.tsnbl = 1/ss.fs * (ss.tsnbl_locs-ss.rise_locs);

mzd = round(0.2*ss.fs/fsw);
[ss.zc_locs] = zero_crossing(il_range,mzd,0);

[ss.tdh_locs, ss.tdl_locs] = diode_driving_time(ss.zc_locs, ss.tsnbh_locs, ss.tsnbl_locs);
ss.tdh = (ss.tdh_locs - ss.tsnbh_locs)/ss.fs;
ss.tdl = (ss.tdl_locs - ss.tsnbl_locs)/ss.fs;
