function [trl, event] = nadia_fun(cfg)

% Include only 2T sequences
% Remembered-Forgotten at Encoding and then at Retrieval

StimTypeArray = {{{'101','102','103','104','105','106','107','108','109'}, 'eA';... % Encoding A sound (all)
    {'1','2','3','4','5','6','7','8','9'}, 'eMA';... % Encoding MA sound (all)
    {'201','202','203','204','205','206','207','208', '209'}, 'eM';... % Encoding Motor (all)
    {'112','113','114','115', '116', '117', '118','123','124','125','126', '127', '128'}, 'tAenc';... % Test sound A at encoding 
    {'12','13','14','15','16','17','18','23','24','25','26','27','28'}, 'tMAenc';... % Test sound MA at encoding
    {'141'}, 'tA_1st_2T';...
    {'41'}, 'tMA_1st_2T';
    {'142'}, 'tA_2nd_2T';...
    {'42'}, 'tMA_2nd_2T';
    {'131'}, 'tA_1st_1T';... 
    {'31'}, 'tMA_1st_1T';... 
    {'132'}, 'tA_2nd_1T';...
    {'32'}, 'tMA_2nd_1T'}};
    
   
% read the header information and the events from the data
subject = cfg.sj;
% hdr = ft_read_header(cfg.dataset, subject)
fsample = cfg.fsample;
sub_folder = cfg.folder;
event = cfg.event;

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * fsample);
posttrig =  round(cfg.trialdef.post * fsample);

disp('Decode event type to make my life easier');

for iR = 1:length(event)
    if  ~isempty(strfind(event(iR).value, 'TRIAL_VAR_LABELS 89'))
        event(iR).type = 'response';
    elseif isempty(event(iR).value)
        disp('value empty, continue');
    elseif isempty(event(iR).type) && ~isempty(regexp(event(iR).value, '^MSG\s\d*\s 88'))
        event(iR).type ='response';
    elseif ~isempty(strfind(event(iR).value, ' TRIAL_VAR_LABELS 253'))
        event(iR).type ='blockstart';
    elseif ~isempty(strfind(event(iR).value, ' TRIAL_VAR_LABELS 254'))
        event(iR).type ='trialstart';
    elseif ~isempty(strfind(event(iR).value, ' TRIAL_VAR_LABELS 99'))
        event(iR).type ='extrapress';
%     elseif ~isempty(strfind(event(iR).value, ' TRIAL_VAR_LABELS 99'))
%         disp('continue')
        
    end
end

% Search for "stimulus" events
for iR = 1:length(event)
    if ~isempty(strfind(event(iR).type, 'TRIAL_VAR_LABELS'))
        event(iR).type = 'stimulus';
    end
end
i=1;
baseline_vals=[];
%% Recode stimulus type based on StimTypeArray
for iStim = 1:length(event)
    if ~isempty(strfind(event(iStim).type, 'blockstart'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
        strtok = tokenize(event(iStim).value);
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;

        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = 253;
        
        i=i+1
    elseif~isempty(strfind(event(iStim).type, 'question'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
        
        timestamp = event(iStim).value;
        trl(i,10) = timestamp;
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = 555;
        i=i+1

    elseif~isempty(strfind(event(iStim).type, 'error'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
        strtok = tokenize(event(iStim).value);
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = 199;
        i=i+1;
    elseif ~isempty(strfind(event(iStim).type, 'trialstart'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
        % define baseline window (500 ms prior to the trialstart)
%         disp('Calculating baseline as 500 ms prior to trialstart');

%         baseline =  sscanf(event(iStim).value, 'MSG %d* TRIAL_VAR_LABELS 254');
%         baseline = dsearchn(asc.dat(1,:)', baseline)
%         baseline_vals = [baseline_vals; baseline];
        strtok = tokenize(event(iStim).value);
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = 254;
        i=i+1
    elseif ~isempty(strfind(event(iStim).type, 'retention'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + (posttrig);  
        strtok = tokenize(event(iStim).value);
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = 10;
        i=i+1
    elseif ~isempty(strfind(event(iStim).type, 'fix'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
        strtok = tokenize(event(iStim).value);
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = 999;
        i=i+1
    elseif ~isempty(strfind(event(iStim).type, 'extrapress'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
        strtok = tokenize(event(iStim).value);
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = 99;
        i=i+1;
    % search for "stimulus" events
    elseif ~isempty(strfind(event(iStim).type, 'stimulus'))
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;   
        strtok = tokenize(event(iStim).value);
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        stim_trigger =  sscanf(event(iStim).value, 'MSG %*f TRIAL_VAR_LABELS%d*');
        % Identify not-to-be-analyzd events (catch, noSounds)
        %disp('Identify not-to-be-analyzd events (catch, noSounds)');

        if  ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 50')) 
            event(iStim).type = 'catch';
            event(iStim).value = 50;
        elseif  ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 150')) 
            event(iStim).type = 'catch';
            event(iStim).value = 150;
        elseif ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 250'))
            event(iStim).type = 'catch';
            event(iStim).value = 250;
        elseif ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 51')) ||  ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 52')) ||  ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 151')) || ...
                ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 152'))
            event(iStim).type = 'catch';
            event(iStim).value = 350;
            
        elseif  ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 133')) 
            event(iStim).type ='noSound';
            event(iStim).value =133;
        elseif  ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 134'))
             event(iStim).type ='noSound';
            event(iStim).value =134;
        end
        
        % Decode stimulus type
        if ismember(stim_trigger,str2double(StimTypeArray{1}{1, 1})) % if eA
            event(iStim).value = 1;
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{2, 1})) % if eMA
            event(iStim).value = 2;
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{3, 1})) % if eM
            event(iStim).value = 3;
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{4, 1})) % if tAenc
            event(iStim).value = 11;
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{5, 1})) % if tMAenc
            event(iStim).value = 21;
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{6, 1})) % if tA1st_2T
            event(iStim).value = str2double(StimTypeArray{1}{6, 1});
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{7, 1})) % if tMA1st_2T
            event(iStim).value = str2double(StimTypeArray{1}{7, 1});
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{8, 1})) % if tA2nd_2T
            event(iStim).value = str2double(StimTypeArray{1}{8, 1});
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{9, 1})) % if tMA2nd_2T
            event(iStim).value = str2double(StimTypeArray{1}{9, 1});
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{10, 1})) % if tA_1st_1T
            event(iStim).value = str2double(StimTypeArray{1}{10, 1});
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{11, 1})) % if tMA_1st_1T
            event(iStim).value = str2double(StimTypeArray{1}{11, 1});
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{12, 1})) % if tA_2nd_1T
            event(iStim).value = str2double(StimTypeArray{1}{12, 1});
        elseif ismember(stim_trigger,str2double(StimTypeArray{1}{13, 1})) % if tMA_2nd_1T
            event(iStim).value = str2double(StimTypeArray{1}{13, 1});
       
        end
        
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = event(iStim).value;
        i=i+1;
%        disp('Decode response..');
    elseif ~isempty(strfind(event(iStim).value, 'TRIAL_VAR_LABELS 89'))
        strtok = tokenize(event(iStim).value)
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        event(iStim).value = 89;
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
          trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = event(iStim).value;
        i=i+1
    elseif ~isempty(strfind(event(iStim).type, 'response')) && ~isempty(strfind(event(iStim).value, ' 88'))
         strtok = tokenize(event(iStim).value)
        timestamp = str2num(strtok{2});
        trl(i,10) = timestamp;
        event(iStim).value = 88;
        stimulus_sampleStart = event(iStim).sample + pretrig;
        stimulus_sampleEnd = event(iStim).sample + posttrig;
        trl(i,1) = stimulus_sampleStart;  % start of segment
        trl(i,2) = stimulus_sampleEnd; % end of segment
        trl(i,3) = pretrig;                    % how many samples prestimulus
        trl(i,4) = event(iStim).value;
        i=i+1
    else 
        disp('nan');
    end
end

% Find trials without response to remove the baseline values
% disp('Find trials without response to remove the baseline values');
% dum = find(trl(:,4)==254);
% % add the final row of the trl in the dum mat to be able to analyze the last trial
% dum(end+1) = length(trl);
% to_be_excluded =[]; 
% 

% Col. 6 - Exclude first trial of each block
for j = 1:length(trl)
    if trl(j,4) == 253 % && trl(j+2,4) ~= 50
        %exclude first trial of block
        if any(trl(j:j+16,4)==999)
            for i = 1:16
                trl(j+i,6) = 111;
            end
        else
            for i = 1:12
                if trl(j:j+i,4)~=199
                    trl(j+i,6)= 111;
                else
                    break;
                end
            end
            trl(j+i,6) = 111;
        end     
    end
end
% Col 7 - Mark and exclude catch trials
for j = 1:length(trl)
    if trl(j,4) == 254 && (trl(j+1,4) ==50 || trl(j+1,4) ==150 || trl(j+1,4) ==250) 
        trl(j,7) = 50;
        
        if any(trl(j:j+15,4)==999)
            for i = 1:15
                trl(j+i,7) = 50;
            end
        else
            
            for i = 1:12
                if trl(j+i,4)~=254
                    trl(j+i,7)= 50;
                else
                    break;
                end
            end
            
        end     
    end
end

trl_sofar=trl;
% Mark and exclude trials without response
for j = 1:length(trl)
    if trl(j,4) == 254 && j+16 < length(trl)
        if trl(j,4) == 254 && ~any(trl(j:j+16,4)==999)
            trl(j,8)= 222;
            for i = 1:16
                if trl(j+i,4)~=254 && trl(j+i,4)~=253
                    trl(j+i,8)= 222;
                else
                    break;
                end
            end
            
        end
    elseif trl(j,4) == 254 && j+16 > length(trl)
        if trl(j,4) == 254 && ~any(trl(j:end,4)==999)
            trl(j,8)= 222;
            for i = 1:length(trl)-j
                if trl(j+i,4)~=254 && trl(j+i,4)~=253
                    trl(j+i,8)= 222;
                else
                    break;
                end
            end
            
        end
    end
end

% in case participant has 0 no-response-trials, still add an 8th column to
% avoid errors later
if size(trl,2) < 8
    trl(:,8)=0;
end

%Remove the baseline values for 
% a. no response trials
% b. the catch trials
% c. 1st trial of each block
% find the trial idx that need to be excluded to remove them from the
% baseline values
baseline_samples =  trl(trl(:,4)==254,:);
idx_bsl1 =find(baseline_samples(:,6)==111);
idx_bsl2 =find(baseline_samples(:,7)==50);
idx_bsl3 =find(baseline_samples(:,8)==222);
to_exclude = [idx_bsl1; idx_bsl2; idx_bsl3];
% use unique function in case we have overlaps (e.g., a catch trial that
% was the first trial of the block)
baseline_samples(unique(to_exclude),:) =[];

% Now delete 500 ms from the initial sample
baseline_samples = baseline_samples(:,1)-500;
% Now find the pupil data corresponding to this sample

% baseline_values = data.trial{1}(3,baseline_samples);
% Plot the baseline_values for the trials that will be included in the
% final analyses
% plot(data.time{1}(baseline_samples), baseline_values)
% cd(data_path)
% % saveas(gcf, [num2str(subject) '_BaselineVals.png']);
% eval(['save ' num2str(subject, '%02d') '_bsl_data baseline_values baseline_samples'])
% cd(analysis_path)

disp('Adding more information to the trl matrix.. ');
disp('Col. 5: Encoding (1) or Retrieval (2) stimuli');
disp('Col. 6: 1st trial of each block = 111')
disp('Col. 7: Catch  = 50')
disp('Col. 8: No response = 222')

disp('Col. 9: For 1T: correct for A-sounds(11), correct for MA-sounds (12), incorrect (666)')
disp('Col. 9: For 2T: recalled A-sounds(21), recalled MA-sounds (22)')

for j = 1:length(trl)
    %     if trl(j,4) == 254
    if ismember(trl(j,4),[1 2 3 11 21 50 150 250])
        trl(j,5) = 1 ;%encoding;
    elseif ismember(trl(j,4),[31 32 41 42 131 132 133 134 141 142 350])
        trl(j,5) = 2; % retrieval;
    end
    
    if (trl(j,4) == 134 && trl(j+2,4)==89)
        trl([j-12:j+3],9) = 666; %incorrect 1T trial
    elseif  (trl(j,4) == 133 && trl(j+3,4)==88)        
        trl([j-11:j+4],9) = 666; %incorrect 1T trial
        
    elseif trl(j,4) == 133 && trl(j+3,4)==89 && trl(j+1,4)==132
        trl([j-11:j+4],9) = 11; % correct for A second at 1T
    elseif trl(j,4) == 134 && trl(j+2,4)==88 && trl(j-1,4)==131
        trl([j-12:j+3],9) = 11; % correct for A first at 1T
    elseif trl(j,4) == 133 && trl(j+3,4)==89 && trl(j+1,4)==32
        trl([j-11:j+4],9) = 12; % correct for MA second at 1T       
    elseif trl(j,4) == 134 && trl(j+2,4)==88 && trl(j-1,4)==31
        trl([j-12:j+3],9) = 12; %correct for MA first at 1T     
        
    elseif  (trl(j,4) == 141 && trl(j+1,4) == 42 && trl(j+3,4)==88)
        trl([j-11:j+4],9) = 21; %recalled A first at 2T   
    elseif  (trl(j,4) == 141 && trl(j+1,4) == 42 && trl(j+3,4)==89)
        trl([j-11:j+4],9) = 22; %recalled MA second at 2T
    elseif trl(j,4) == 142 && trl(j-1,4) == 41 && trl(j+2,4)==89 
        trl([j-12:j+3],9) = 21; % recalled A second at 2T
    elseif trl(j,4) == 142 && trl(j-1,4) == 41 && trl(j+2,4)==88 
        trl([j-12:j+3],9) = 22; % recalled MA first at 2T        
    end
end

% Mark trial end to take samples for trial-based boxcar function
for j = 1:length(trl)
    if trl(j,4) == 254 && j+16 < length(trl)
        %exclude first trial of block
        if any(trl(j:j+16,4)==555) || any(trl(j:j+16,4)==199)
            for i = 1:16
                if (trl(j+i,4) == 555 || trl(j+i,4) == 199) %&& (trl(j+i+1,4) == 254 || trl(j+i+1,4) == 253)
                    
                    trl(j+i,11) = 198;
                end
            end
        end
        
    elseif trl(j,4) == 254 && j+16 > length(trl)
        if any(trl(j:length(trl)-j,4)==555) || any(trl(j:length(trl)-j,4)==199)
            for i = 1:length(trl)-j
                if (trl(j+i,4) == 555 || trl(j+i,4) == 199) %&& (trl(j+i+1,4) == 254 || trl(j+i+1,4) == 253)
                    
                    trl(j+i,11) = 198;
                end
            end
        end
    end
end
% save the initial matrix just in case
trl_all = trl;
cd(sub_folder)
eval(['save ' num2str(subject, '%02d') '_trl_all trl_all'])
 
trl(trl(:,6)==111,:)=[];
trl(trl(:,7)==50,:)=[];
trl(trl(:,8)==222,:)=[];

cd(sub_folder)
eval(['save ' num2str(subject, '%02d') '_trl_clean trl'])

end
