function [ioffh, ioffl] = off_transition_current(il, rlocs, flocs)
    ioffh = il(flocs);
    ioffl = il(rlocs);
end