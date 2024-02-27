function stat = clusterStatistics_nadia(data1, data2, nsubj)

cfg                  = [];
cfg.method           = 'montecarlo'; % permutation test
cfg.statistic        = 'ft_statfun_depsamplesT'; % dependent samples ttest

% do cluster correction
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.tail             = 0; % two-tailed!
cfg.clustertail      = 0; % two-tailed!
 cfg.alpha            = 0.025; 
cfg.numrandomization = 10000; % make sure this is large enough
cfg.randomseed       = 1; % make the stats reproducible!

% use only our preselected sensors for the time being
cfg.channel          = 'EyePupil';

design = zeros(2,2*nsubj);
for i = 1:nsubj,  design(1,i) = i;        end
for i = 1:nsubj,  design(1,nsubj+i) = i;  end
design(2,1:nsubj)         = 1;
design(2,nsubj+1:2*nsubj) = 2;

cfg.design = design;             % design matrix
cfg.uvar     = 1;               % Row in which the unit of observation variable (subject number) is set
cfg.ivar  = 2;                   % Row in which the independent variable (group number) is set
% specifies with which sensors other sensors can form clusters

stat = ft_timelockstatistics(cfg, data1{:}, data2{:})
end