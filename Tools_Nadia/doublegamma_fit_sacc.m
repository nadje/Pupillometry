function [irf] = doublegamma_fit_sacc(x, y)
% return the sum of squared error of the fit

startpt = [-1, 1, 10, 10, 1, 2.5];
lb = [-Inf, 1e-25, 9, 8, 0.5, 1.5];
ub = [ -1e-25, Inf, 11, 12, 3, 5];
disp('fitting saccade double gamma');
doublegamma = @(s1, s2, n1, n2, tmax1, tmax2, x) ...
    s1 * (x.^n1) .* exp((-n1.*x) ./ tmax1) + s2 * (x.^n2) .* exp((-n2.*x) ./ tmax2);
doublegamma = fittype(doublegamma);
fitobj = fit(x, y, doublegamma, ...
    'startpoint', startpt, 'lower', lb, 'upper', ub);
irf = feval(fitobj, x);

end