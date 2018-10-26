function [fsig] = interpolation_signal_comparison(data)
    fsig = figure;
    plot(data.osc.t, data.osc.il, 'k', 'DisplayName', data.osc.label);
    hold on
    plot(data.adc.t,data.adc.il, 'g', 'Marker', '.', 'LineStyle','none', 'DisplayName', data.adc.label)
    plot(data.dst.t, data.dst.il, ':b', 'LineWidth', 2, 'DisplayName', sprintf('%.4fMHz', data.dst.fs/1e6))
    plot(data.int.t,data.int.il,'r','DisplayName',data.int.label);
    figure(fsig);
    xlabel(data.t_str);
    legend;
end