function Pupil_1_preprocessing
% CONVERSION IS ALREADY DONE IN STEP_1_CONVERSION

%% 1. Paths
clear; clc; close all;
analysis_path = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Analysis_Scripts/Pupillometry';
data_path = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/EyeTracking';
raw_mat = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/EyeTracking';
raw_asc=raw_mat;
analysis_log = [analysis_path '/analysis_log.txt'];
% add plugins needed
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/boundedline']);
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/catuneven']);
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/Inpaint_nans']);
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/singlepatch']);
addpath([analysis_path '/Tools_Nadia'])
addpath([analysis_path '/Tools-master_AU/plotting']);
addpath([analysis_path '/Tools-master_AU/plotting/cbrewer'])
set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');
set(groot, ...
    'DefaultFigureColorMap', linspecer, ...
    'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 0.8, ...
    'DefaultAxesXColor', 'k', ...
    'DefaultAxesYColor', 'k', ...
    'DefaultAxesFontUnits', 'points', ...
    'DefaultAxesFontSize', 10, ...
    'DefaultAxesFontName', 'Helvetica', ...
    'DefaultLineLineWidth', 1, ...
    'DefaultTextFontUnits', 'Points', ...
    'DefaultTextFontSize', 12, ...
    'DefaultTextFontName', 'Helvetica', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.025]);
colors = cbrewer('qual', 'Set1', 8);

ft_defaults;
% File
nBlocks=24;
subjects = [6 7 8 9 10 11 12 13 14 16 18 19 20 21 22 23 24 25 26 27 28 29 30];
tic;
fileID = fopen(analysis_log,'wt');
fprintf(fileID,'Data path: %s*\n\n',data_path);

%% Preprocessing to regress out responses to blinks and saccades
% =======================================================================
%                               Preprocessing
% =======================================================================
for subject = 1:length(subjects)
    cd(data_path)
    sub_folder = [data_path '/first-level'];
    cd(sub_folder)
    if ~exist(sprintf('%s*%d', 'evoked_', subjects(subject), 'folder'))
        mkdir([sub_folder '/evoked_', num2str(subjects(subject))])
    end
    evoked_folder = [sub_folder '/evoked_' num2str(subjects(subject))];
    cd(evoked_folder)
    
    merged_file = [raw_asc '/' num2str(subjects(subject),'%02d') '_MyBigFat.asc'];
    load([raw_mat '/' num2str(subjects(subject),'%02d') '_Raw.mat']);
    load([raw_mat '/' num2str(subjects(subject),'%02d') '_BigFatAsc.mat']);
    fprintf(fileID,'*********************************\n');
    fprintf(fileID,'-----Subject : %s*\n\n', num2str(subjects(subject)));
    fprintf(fileID,'*********************************\n');
    fprintf(fileID,'EVOKED ANALYSIS*\n');
    fprintf(fileID,'Script: step_2_1_prepro_till_IGA_for_evoked*\n\n');
    
    %% 2. Interpolate Eyelink-defined and additionally detected blinks
    fprintf(fileID,'*********************************\n');
    fprintf(fileID,'Interpolate..........\n');
    
    plotMe=0;
    
    newpupil = blink_interpolate1(data, blinksmp, plotMe, subjects(subject));
    data.trial{1}(find(strcmp(data.label, 'EyePupil')==1),:) = newpupil;
    cd(evoked_folder)
    eval(['save ' num2str(subjects(subject), '%02d') '_interp data'])
    %% 3. Regress out blink- and saccade-linked pupil response
    % http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0155574
    
    fprintf(fileID,'Regressing out blinks & saccades for evoked analysis....\n');
    pupildata = data.trial{1}(~cellfun(@isempty, strfind(lower(data.label), 'eyepupil')),:);
    newpupil = blink_regressout_nadia(pupildata, data.fsample, blinksmp, saccsmp, 1, 1);
    % put back in fieldtrip format
    data.trial{1}(~cellfun(@isempty, strfind(lower(data.label), 'eyepupil')),:) = newpupil;
    cd(evoked_folder)
    eval(['save ' num2str(subjects(subject), '%02d') '_regressedOut data'])
    cd(analysis_path)
    
    %% 4. zscore since we work with the bandpassed signal
    data.trial{1}(find(strcmp(data.label, 'EyePupil')==1),:) = ...
        zscore(data.trial{1}(find(strcmp(data.label, 'EyePupil')==1),:));  
    
    %% 5. Make channels with blinks and saccades
    fprintf(fileID,'Add channels for blinks and saccades\n');
    
    data.label{4} = 'Blinks';
    data.trial{1}(4, :) = zeros(1, length(data.time{1}));
    for b = 1:length(blinksmp),
        data.trial{1}(4, blinksmp(b,1):blinksmp(b,2)) = 1;
    end
    % We don't need the saccade channel here, but still
    data.label{5} = 'Saccades';
    data.trial{1}(5, :) = zeros(1, length(data.time{1}));
    for s= 1:length(saccsmp),
        data.trial{1}(5, saccsmp(s,1):saccsmp(s,2)) = 1;
    end
    cd(evoked_folder)
    eval(['save ' num2str(subjects(subject), '%02d') '_zScored data'])
    
    % Check how many samples were interpolated (for later use)
    
    interpBlinks = find(data.trial{1}(4,:)==1);
    interpSaccs = find(data.trial{1}(5,:)==1);
    percent_blinksInterp = (length(interpBlinks)/length(data.trial{1}))*100
    percent_saccInterp = (length(interpSaccs)/length(data.trial{1}))*100
    cd(evoked_folder)
    eval(['save ' num2str(subjects(subject), '%02d') '_PercentInterp percent_blinksInterp percent_saccInterp'])
    cd(analysis_path)
    
  
    %% 6. Epoching
    fprintf(fileID,'*********************************\n');
    fprintf(fileID,'-----Subject : %s*\n\n', num2str(subjects(subject)));
    fprintf(fileID,'*********************************\n');
    fprintf(fileID,'Epoching 0.5 to 1.5 in %s*\n');
    
    disp('Trigger-based epoching.. [0.5 to 1.5 poststimulus]');
    cfg                         = [];
    cfg.dataset                 = merged_file;
    cfg.event                   = event;
    cfg.trialdef.pre            = 0.5;
    cfg.trialdef.post           = 1.5;
    cfg.fsample                 = asc.fsample
    cfg.sj                      = subjects(subject);
    cfg.folder                  =evoked_folder;
    cfg.trialfun                = 'nadia_fun';
    
    cfg                         = ft_definetrial(cfg);
    cfg.channel                 = 'EyePupil';
    dataN                       = ft_redefinetrial(cfg, data);
    
    dataN.trialinfo             = cfg.trl;
    dataN.event                 = cfg.event; % all events
    event_renamed               = dataN.event
    cd(evoked_folder)
    eval(['save ' num2str(subjects(subject), '%02d') '_dataN dataN'])
    cd(analysis_path)
    fprintf(fileID,'----- Epoching done\n\n');
    
    cfg_all = dataN.trialinfo;
    for cond = {'eA_2T' 'eMA_2T' 'eM_2T' 'eA' 'eMA' 'eM' 'tAretr' 'tMAretr' 'tAretr1T' 'tMAretr1T' 'nosounds' 'tAenc_R_2' 'tAenc_F_2' 'tMAenc_R_2' 'tMAenc_F_2' 'tAretr_R_2' 'tAretr_F_2' 'tMAretr_R_2' 'tMAretr_F_2' 'response' 'retention' 'trialstart' 'blockstart'}
        
        switch cond{:}
            case 'eA_2T'
                tmp=[];
                tmp = cfg_all(cfg_all(:,4)==1 | cfg_all(:,4)==11,:);
                trls = tmp(tmp(:,9)==21 |tmp(:,9)==22,:);
            case 'eMA_2T'
                tmp=[];
                tmp = cfg_all(cfg_all(:,4)==2 | cfg_all(:,4)==21,:);
                trls = tmp(tmp(:,9)==21 |tmp(:,9)==22,:);
            case 'eM_2T'
                tmp=[];
                tmp = cfg_all(cfg_all(:,4)==3,:);
                trls = tmp(tmp(:,9)==21 |tmp(:,9)==22,:);
            case 'eA'
                trls = cfg_all(cfg_all(:,4)==1 | cfg_all(:,4)==11,:)
            case 'eMA'
                trls = cfg_all(cfg_all(:,4)==2 | cfg_all(:,4)==21,:)
            case 'eM'
                trls= cfg_all(cfg_all(:,4)==3,:)
            case 'tAretr'
                trls = cfg_all(cfg_all(:,4)==141 | cfg_all(:,4)==142,:);
            case 'tMAretr'
                trls= cfg_all(cfg_all(:,4)==41 | cfg_all(:,4)==42,:);
                
            case 'tAenc_R_2'
                trls = cfg_all(cfg_all(:,4)==11 & cfg_all(:,9)==21, :);
            case 'tAenc_F_2'
                trls = cfg_all(cfg_all(:,4)==11 & cfg_all(:,9)==22, :);
            case 'tMAenc_R_2'
                trls = cfg_all(cfg_all(:,4)==21 & cfg_all(:,9)==22, :);
            case 'tMAenc_F_2'
                trls = cfg_all(cfg_all(:,4)==21 & cfg_all(:,9)==21, :);
                
            case 'tAretr_R_2'
                tmp=[]
                tmp = cfg_all(cfg_all(:,9)==21,:);
                trls = tmp(tmp(:,4)==141 |tmp(:,4)==142,:);
                
            case 'tAretr_F_2'
                tmp=[]
                tmp = cfg_all(cfg_all(:,9)==22,:);
                trls = tmp(tmp(:,4)==141 |tmp(:,4)==142,:);
                
            case 'tMAretr_R_2'
                tmp2=[];
                tmp2 = cfg_all(cfg_all(:,9)==22,:);
                trls = tmp2(tmp2(:,4)==41 |tmp2(:,4)==42,:);
                
            case 'tMAretr_F_2'
                tmp3=[];
                tmp3 = cfg_all(cfg_all(:,9)==21,:);
                trls = tmp3(tmp3(:,4)==41 |tmp3(:,4)==42,:);
                
            case 'tAretr1T'
                trls= cfg_all(cfg_all(:,4)==131 | cfg_all(:,4)==132,:);
            case 'tMAretr1T'
                trls= cfg_all(cfg_all(:,4)==31 | cfg_all(:,4)==32,:);
            case 'nosounds'
                trls = cfg_all(cfg_all(:,4)==133 |  cfg_all(:,4)==134,:);
            case 'response'
                trls = cfg_all(cfg_all(:,4)==88 |  cfg_all(:,4)==89,:);
            case 'retention'
                trls = cfg_all(cfg_all(:,4)==10,:);
            case 'trialstart'
                trls = cfg_all(cfg_all(:,4)==254,:);
            case 'blockstart'
                trls = cfg_all(cfg_all(:,4)==254,:);
        end
        
        cfg.trl = trls;
        
        dat = ft_redefinetrial(cfg, data);
        dat.trialinfo             = cfg.trl;
        cfg.channel = 'EyePupil'
        dat = ft_selectdata(cfg,dat);
        save([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_GA_' cond{:} '_ERP'],'dat');
        clear dat; clear trls;
        
    end
    
    %% 7. Downsample before continuing
    for cond = {'eA_2T' 'eMA_2T' 'eM_2T' 'eA' 'eMA' 'eM' 'tAretr' 'tMAretr' 'tAretr1T' 'tMAretr1T' 'nosounds' 'tAenc_R_2' 'tAenc_F_2' 'tMAenc_R_2' 'tMAenc_F_2' 'tAretr_R_2' 'tAretr_F_2' 'tMAretr_R_2' 'tMAretr_F_2' 'response' 'retention' 'trialstart' 'blockstart'}
        load([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_GA_' cond{:} '_ERP.mat'])
        
        cfg             = [];
        cfg.resamplefs  = 100;
        % see Kloosterman's comment on Fieldtrip mailing list: https://mailman.science.ru.nl/pipermail/fieldtrip/2010-September/028973.html
        dat.trialinfo(:,[1:3]) = round(dat.trialinfo(:,[1:3]) *  (cfg.resamplefs/dat.fsample));
        
        % use fieldtrip to resample
        dat_down    = ft_resampledata(cfg, dat);
        
        save([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_GA_' cond{:} '_ERP_downsampled'],'dat_down');
        clear dat dat_down
    end
    %% 8. Baseline correction (-0.5 prestimulus)
    
    for cond = {'eA_2T' 'eMA_2T' 'eM_2T' 'eA' 'eMA' 'eM' 'tAretr' 'tMAretr' 'tAretr1T' 'tMAretr1T' 'nosounds' 'tAenc_R_2' 'tAenc_F_2' 'tMAenc_R_2' 'tMAenc_F_2' 'tAretr_R_2' 'tAretr_F_2' 'tMAretr_R_2' 'tMAretr_F_2'  'response' 'retention' 'trialstart' 'blockstart' }
        
        load([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_GA_' cond{:} '_ERP_downsampled.mat'])
        % Baseline correction
        cfg=[];
        cfg.channel                 = 'EyePupil';
        cfg.demean          = 'yes';
        cfg.baselinewindow  = [-0.5 0];
        cfg.fsample = dat_down.fsample
        dat_bsl = ft_preprocessing(cfg,dat_down);
        
        save([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_GA_' cond{:} '_ERP_bsl'],'dat_bsl');
        clear dat_bsl;
    end
    
    %% 9. Timelock to create subject's averages
 
        cd(sub_folder)
        if ~exist(sprintf('%s*%d', 'evoked_', subjects(subject), 'folder'))
            mkdir([sub_folder '/evoked_', num2str(subjects(subject))])
        end
        evoked_folder = [sub_folder '/evoked_' num2str(subjects(subject))];
        cd(evoked_folder)
        i = 1;
        for cond = {'eA_2T' 'eMA_2T' 'eM_2T' 'eA' 'eMA' 'eM' 'tAretr' 'tMAretr' 'tAretr1T' 'tMAretr1T' 'nosounds' 'tAenc_R_2' 'tAenc_F_2' 'tMAenc_R_2' 'tMAenc_F_2' 'tAretr_R_2' 'tAretr_F_2' 'tMAretr_R_2' 'tMAretr_F_2' 'response' 'retention' 'trialstart' 'blockstart' }
            load([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_GA_' cond{:} '_ERP_bsl'],'dat_bsl');
            cfg=[]
            avg = ft_timelockanalysis(cfg,dat_bsl)
            %save([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_TL_' cond{:} '_ERP_bsl'],'TL_bsl');
            save([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_AVG_' cond{:} '_forClust'],'avg');
            
            clear dat_bsl avg
            i = i+1
        end    
    %% 10. Plot individual averages
    fig2= figure;
    eMA=  load([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_AVG_eMA_2T_forClust.mat'])
    eA=  load([evoked_folder '/' num2str(subjects(subject),'%0.2d') '_AVG_eA_2T_forClust.mat'])
    enc= boundedline(eMA.avg.time, eMA.avg.avg, eMA.avg.var ,...
        eA.avg.time, eA.avg.avg, eA.avg.var , ...
        'cmap',colors, 'transparency', 0.1); hold on;
    
    hold on;
    ylims = get(gca, 'ylim');
    line([0 0], [ylims(1) ylims(2)], 'LineStyle', '--', 'Color', 'k');
    legend('Self-generated','Externally-generated'); hold on ;axis tight;
    cd(evoked_folder)
    saveas(fig2, [num2str(subjects(subject)) 'Evoked_AvgSubj_AMA_2T.png']);
end
       
end