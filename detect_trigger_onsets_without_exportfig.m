function [trig_onsets, err_sec_per_tol] = detect_trigger_onsets_without_exportfig(trigger_signal, trig_template, sr, varargin)

    % Iteratively finds trigger onsets by detecting peaks in the
    % cross-correlation function between the trigger channel and a known
    % template. After a peak is found surrounding peaks in the
    % cross-correlation function are suppressed, and the process repeats until
    % no more peaks above a certain tolerance are found (0.4 of the max peak
    % aross all timepoints).
    % 
    % 2019-06-11: Created, Sam NH
    % 
    % 2019-11-16: Added capacity to save figures
    
    clear I;
    I.tol = 0.4;
    I.win_to_zero = length(trig_template)/sr*1.5;
    I.plot = true;
    I.figdir = '';
    I.errtol = [0.99, 0.95, 0.9, 0.8];
    I = parse_optInputs_keyvalue(varargin, I);
    
    %% Normalized cross-correlation
    
    [cc, lag] = xcorr_pearson(trigger_signal, trig_template);
    cc(isinf(cc)) = 0;
    % [cc, lag] = xcorr(trigger_signal, trig_template);
    cc = cc/max(cc);
    
    % check no negative lags
    assert(all(lag>=0));
    % get rid of negative lags
    % xi = lag>=0;
    % lag = lag(xi);
    % cc = cc(xi);
    % clear xi;
    
    %% Detect triggers as peaks
    
    % open figure for dynamic plotting
    if I.plot
        figh = figure;
        set(figh, 'Position', [100 100 1000 300]);
    end
    
    % iteratively find triggers
    trig_onsets = [];
    err_sec_per_tol = [];
    while max(cc) > I.tol
        
        % find a peak and add to trigger onsets
        [~,xi] = max(cc);
        best_lag = lag(xi);
        trig_onsets = [trig_onsets, best_lag]; %#ok<AGROW>a
        
        % find nearest lag less than errtol frac of the peak
        err_smp = [];
        for j = 1:length(I.errtol)
            lags_below_thresh = find(cc < cc(best_lag)*I.errtol(j));
            err_smp = cat(2, err_smp, min(abs(lags_below_thresh-best_lag)));
        end
        err_sec_per_tol = cat(1, err_sec_per_tol, err_smp/sr);
        
        % set surround to zero
        xi = abs(lag - best_lag)/sr < I.win_to_zero;
        cc(xi) = 0;
        
        % plot
        if I.plot
            clf(figh);
            plot(lag/sr, cc);
            hold on;
            for i = 1:length(trig_onsets)
                plot([1 1]*trig_onsets(i)/sr, [0 1], 'r-', 'LineWidth', 2);
            end
            ylim([0,1]);
            xlabel('Time');
            ylabel('Norm CC');
            drawnow;
        end
        
    end
    
    %% Sort triggers
    
    % sort triggers by their onset
    [~,xi] = sort(trig_onsets);
    trig_onsets = trig_onsets(xi);
    err_sec_per_tol = err_sec_per_tol(xi,:);
    
    % save triggers
    if ~isempty(I.figdir)
        save(mkpdir([I.figdir '/triggers.mat']), 'trig_onsets', 'err_sec_per_tol', 'sr')
    end
    
    %%
    
    N = 100000;
    x = rand(1,N);
    y = rand(1,N);
    NSE = mean((x-y).^2) / (mean(x.^2) + mean(y.^2) - 2*mean(x)*mean(y))
    y = rand(1,N) + 1000;
    NSE = mean((x-y).^2) / (mean(x.^2) + mean(y.^2) - 2*mean(x)*mean(y))
    y = randn(1,N)*1000;
    NSE = mean((x-y).^2) / (mean(x.^2) + mean(y.^2) - 2*mean(x)*mean(y))
    
    
    
    %% Print stats
    
    fprintf('Found %d triggers\n', length(trig_onsets));
    for j = 1:length(I.errtol)
        fprintf('error tolerance %.3f: median=%.1f ms, std=%.1f ms, range=%.1f ms\n', ...
            I.errtol(j), median(err_sec_per_tol(:,j))*1000, std(err_sec_per_tol(:,j))*1000, range(err_sec_per_tol(:,j))*1000);
    end
    if ~isempty(I.figdir)
        fid_stats = fopen(mkpdir([I.figdir '/stats.txt']),'w');
        fprintf(fid_stats, 'Found %d triggers\n', length(trig_onsets));
        for j = 1:length(I.errtol)
            fprintf(fid_stats, 'error tolerance %.3f: median=%.1f ms, std=%.1f ms, range=%.1f ms\n', ...
                I.errtol(j), median(err_sec_per_tol(:,j))*1000, std(err_sec_per_tol(:,j))*1000, range(err_sec_per_tol(:,j))*1000);
        end
        fclose(fid_stats);
    end
    
    %% plot error tolerance
    
    if I.plot
        for j = 1:length(I.errtol)
            try
                y = err_sec_per_tol(:,j)*1000;
                bins = unique(linspace(min(y), max(y), 10));
                if length(bins)==1
                    bins = bins+0.1*bins*[-1,1];
                end
                N = myhist(y,bins);
                set(figh, 'Position', [100, 100, 500 500]);
                clf(figh);
                bar(bins, N);
                xlabel('Err (ms)'); ylabel('Counts');
                if ~isempty(I.figdir)
                    fname = [I.figdir '/errtol-' num2str(I.errtol(j))];
                    % export_fig(mkpdir([fname '.pdf']), '-pdf', '-transparent');
                    % export_fig(mkpdir([fname '.png']), '-png', '-transparent', '-r150');
                    saveas(figh, mkpdir([fname '.fig']));
                end
            catch
                keyboard
            end
        end
    end
    
    %% Plot reconstruction
    
    if I.plot
        
        % plot simulated trigger signal
        n_triggers = length(trig_onsets);
        simulated_trigger_signal = zeros(size(trigger_signal));
        for i = 1:n_triggers
            xi = (1:length(trig_template)) + trig_onsets(i);
            simulated_trigger_signal(xi) = trig_template;
        end
        simulated_trigger_signal = max(trigger_signal)*simulated_trigger_signal/max(simulated_trigger_signal);
        
        figh = figure;
        set(figh, 'Position', [100 100 1000 300]);
        plot((0:length(trigger_signal)-1)/sr, [trigger_signal, simulated_trigger_signal]);
        xlabel('Time (sec)');
        legend('Actual', 'Predicted', 'Location', 'EastOutside');
        if ~isempty(I.figdir)
            fname = [I.figdir '/cc'];
            % export_fig(mkpdir([fname '.pdf']), '-pdf', '-transparent');
            % export_fig(mkpdir([fname '.png']), '-png', '-transparent', '-r150');
            saveas(figh, mkpdir([fname '.fig']));
        end
        
        figh = figure;
        set(figh, 'Position', [100 100 1000 600]);
        trigs_to_plot = round(linspace(1, n_triggers, 4+2));
        trigs_to_plot = trigs_to_plot(2:5);
        for i = 1:length(trigs_to_plot)
            subplot(2,2,i);
            win_smp = (1-sr:length(trig_template)+sr);
            win_start_smp = trig_onsets(trigs_to_plot(i));
            plot((win_smp-1)/sr*1000, [trigger_signal(win_smp+win_start_smp), simulated_trigger_signal(win_smp+win_start_smp)]);
            xlabel('Time (ms)');
            title(sprintf('trigger %d', trigs_to_plot(i)));
            legend('Actual', 'Predicted', 'Location', 'SouthOutside');
            xlim((win_smp([1,end])-1)/sr*1000);
        end
        if ~isempty(I.figdir)
            fname = [I.figdir '/cc-individ-triggers'];
            % export_fig(mkpdir([fname '.pdf']), '-pdf', '-transparent');
            % export_fig(mkpdir([fname '.png']), '-png', '-transparent', '-r150');
            saveas(figh, mkpdir([fname '.fig']));
        end
        for i = 1:length(trigs_to_plot)
            subplot(2,2,i);
            xlim([95,105]);
            set(gca, 'XTick', 95:105);
        end
        if ~isempty(I.figdir)
            fname = [I.figdir '/cc-trigger-edge'];
            % export_fig(mkpdir([fname '.pdf']), '-pdf', '-transparent');
            % export_fig(mkpdir([fname '.png']), '-png', '-transparent', '-r150');
            saveas(figh, mkpdir([fname '.fig']));
        end
    end
    
    