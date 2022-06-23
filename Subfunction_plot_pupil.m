function Subfunction_plot_pupil(data1, data2, data3,data4,stat_clu, stat_clu2, legnames,titl,makeitguapo,loc,stats, interaction)
%% Set colors
analysis_path = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Analysis_Scripts/Pupillometry';
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
    'DefaultAxesFontSize', 16, ...
    'DefaultAxesFontName', 'Helvetica', ...
    'DefaultLineLineWidth', 1, ...
    'DefaultTextFontUnits', 'Points', ...
    'DefaultTextFontSize', 16, ...
    'DefaultTextFontName', 'Helvetica', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.025]);
colors1 = cbrewer('qual', 'Set1', 2);
black =  [0.25, 0.25, 0.25]; red = [1, 0, 0]; blue= [0, 0.4470, 0.7410];
colors = [red; blue; black]

%% PLOT
time = linspace(min(data1.time), max(data1.time), numel(data1.time));
fsample = 100;
switch interaction
    case 0
        enc =boundedline(time, data1.avg, data1.var,...
            time, data2.avg, data2.var, ... 
            time, data3.avg, data3.var,...
            'cmap', colors, 'transparency', 0.1);
        hold on
        ylims = get(gca, 'ylim');
        hold on;
        i = 0.01
        if sum(stat_clu.mask==1)>0
           % sig=find(stat_clu.mask==1)/fsample;
           sig = time(find(stat_clu.mask==1))
            line([sig(1) sig(end)], [ylims(1)+i ylims(1)+i], 'LineWidth', 1, 'Color', 'k');
            
            text(sig(1), ylims(1)-0.03, 'p < .05', 'FontSize', 12);
        else
            line([0 time(end)], [ylims(1)+i ylims(1)+i], 'LineWidth', 1, 'Color', 'k');
            text(time(end)-0.1, ylims(1)+0.05, 'n.s.', 'FontSize', 12);
        end     
        lh = legend(enc);
        for i = 1:length(legnames),
            str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
        end
        lh.String = str;
        lh.Box = 'off';
        lh.FontSize=12;
        if loc == 1
            lh.Location = 'NorthWest';
        else
            lh.Location = 'South';
            
        end
        lpos = lh.Position;
        
        lpos(1) = lpos(1)- makeitguapo
        lh.Position = lpos
        ylims = get(gca, 'ylim');
        axis tight;
        ylim([min(ylims) max(ylims)]);
        xvals = time(1):.5:time(end);
        xlim([min(xvals) max(xvals)]); % some space at the sides
        xlabel('Time'); set(gca, 'xtick', xvals);
        
        ylabel('Pupil response (z)');
        xlims = get(gca,'xlim')
        t = title(titl)
        t.FontSize = 18
    % Case 1 for interactions between Memory and Sound for 2T seqs
    case 1
      colors = cbrewer('qual', 'Paired', 8);
      colors = colors([1:2,5:6],:)
        enc =boundedline(time, data1.avg, data1.var,...
            time, data2.avg, data2.var, ...
            time, data3.avg, data3.var,...
            time, data4.avg, data4.var,...
            'cmap', colors, 'transparency', 0.1); %eA)
        ylims = get(gca, 'ylim');
        hold on;
        i = 0.02
         if sum(stat_clu.mask==1)>0
            sig = time(find(stat_clu.mask==1))

            %sig=find(stat_clu.mask==1)/fsample;
            line([sig(1) sig(end)], [ylims(1)+i ylims(1)+i], 'LineWidth', 1, 'Color', 'k');
            
            text(sig(1), ylims(1)-0.01, 'Main effect of sound: p < .05', 'FontSize', 16);
        else
           disp('no significant main effect of sound');
         end
        i = 0.04
          if sum(stat_clu2.mask==1)>0
              sig = time(find(stat_clu2.mask==1))

              %sig=find(stat_clu2.mask==1)/fsample;
            line([sig(1) sig(end)], [ylims(1)+i ylims(1)+i], 'LineWidth', 1, 'Color', 'k');
            
            text(sig(1), ylims(1)+i-0.03, 'Main effect of memory: p < .05', 'FontSize', 16);
        else
           disp('no significant main effect of memory');
          end
         lh = legend(enc);
        for i = 1:length(legnames),
            str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
        end
        lh.String = str;
        lh.Box = 'off';
        lh.FontSize=16;
        if loc == 1
            lh.Location = 'NorthEast';
        else
            lh.Location = 'South';
            
        end
        lpos = lh.Position;
        
        lpos(1) = lpos(1)- makeitguapo
        lh.Position = lpos
        ylims = get(gca, 'ylim');
        axis tight;
        ylim([min(ylims) max(ylims)]);
        xvals = time(1):.5:time(end);
        xlim([min(xvals) max(xvals)]); % some space at the sides
        xlabel('Time'); set(gca, 'xtick', xvals);
        
        ylabel('Pupil response (z)');
        xlims = get(gca,'xlim')
        t = title(titl)
        t.FontSize = 18
        
        
        % Case 2 is for ONE way anova
    case 2
        colors = cbrewer('qual', 'Set1', 8);
      %colors = colors([1:2,5:6],:)
        enc =boundedline(time, data1.avg, data1.var,...
            time, data2.avg, data2.var, ...
            time, data3.avg, data3.var,...
            'cmap', colors, 'transparency', 0.1); %eA)
        ylims = get(gca, 'ylim');
        hold on;
        i = 0.01
         if sum(stat_clu.mask==1)>0
            sig=find(stat_clu.mask==1)/fsample;
            line([sig(1) sig(end)], [ylims(1)+i ylims(1)+i], 'LineWidth', 1, 'Color', 'k');
            
            text(sig(1), ylims(1)-0.01, 'Main effect of sound: p < .05', 'FontSize', 16);
        else
         line([0 time(end)], [ylims(1)+i ylims(1)+i], 'LineWidth', 1, 'Color', 'k');
            text(0, ylims(1)+0.05, 'n.s.', 'FontSize', 16);
         end
       
        lh = legend(enc);
        for i = 1:length(legnames),
            str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
        end
        lh.String = str;
        lh.Box = 'off';
        lh.FontSize=16;
        if loc == 1
            lh.Location = 'NorthEast';
        else
            lh.Location = 'South';
            
        end
        lpos = lh.Position;
        
        lpos(1) = lpos(1)- makeitguapo
        lh.Position = lpos
        ylims = get(gca, 'ylim');
        axis tight;
        ylim([min(ylims) max(ylims)]);
        xvals = time(1):.5:time(end);
        xlim([min(xvals) max(xvals)]); % some space at the sides
        xlabel('Time'); set(gca, 'xtick', xvals);
        
        ylabel('Pupil response (z)');
        xlims = get(gca,'xlim')
        t = title(titl)
        t.FontSize = 18
end
end
%
% if stats ==1
