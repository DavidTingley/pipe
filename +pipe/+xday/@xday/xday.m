classdef xday < handle
    % Class that includes functions for aligning FOVs and masks
    % across days

    % ALIGNMENT
    % ---------
    % step 1 --> obj = pipe.xday.xday(mouse, varargin)
    %        Initialize class object.
    % step 2 --> obj.warp(obj, varargin)
    %        Register FOVs using imregdemons. 
    % step 3 --> obj.besttarget(obj, best_day, bad_days)
    %        Validate registered FOVs.
    % step 4 --> obj.(obj, bad_days_to_keep, matched_days)
    %        (only if step 3 had bad_days) Fix registration hiccups.
    % step 5 --> obj.align(obj, varargin)
    %        
    % 
    % PLOTTING (outside of class, see pipe.xday)
    % --------
    % step 6 --> linear_plot_aligned_ROIs(obj, cell_score_threshold)
    %        Plot each ROI aligned across days cropped around 
    %        mean centroid.
    % step 7 --> xday_qc_metrics(obj, cell_score_threshold)
    %        Plot a number of simple metrics to check the quality of
    %        your alignments. 
    
    % class properties
    properties
        pars
        mouse
        savedir
        warpdir
        initial_dates
        initial_runs
        bad_days
        badwarpfields
        warptarget
        warpfields
        final_dates
        final_runs
        pixelsize_microns
        masks_original
        masks_warped
        xdayalignment
    end
    
    % class methods
    methods
        warp(obj, varargin)
        besttarget(obj, best_day, bad_days)
        finalizetarget(obj, bad_days_to_keep, matched_days)
        align(obj)
        
        function obj = xday(mouse, varargin)
            % Initialization step. Default is to use all dates in
            % a directory. Optionally can pass a vector of dates
            % to only loop over certain days. If empty brackets are
            % passed to 'dates', will use GUI to select date folders
            % from mouse directory. 

            %% Parse inputs
            p = inputParser;
            p.CaseSensitive = false;

            % optional inputs
            addOptional(p, 'force', false);
            addOptional(p, 'server', []);
            addOptional(p, 'dates', pipe.lab.dates(mouse, []));

            % parse
            parse(p, varargin{:});
            p = p.Results;

            % determine server and base directory
            basedir = pipe.lab.mousedir(mouse, p.server);
            obj.savedir = sprintf('%s%s%s', basedir, filesep, 'xday'); 
            if ~exist(obj.savedir, 'dir') || force
                mkdir(obj.savedir)
            end

            % get dates to warp and align
            if isempty(p.dates)
                folder_names = uipickfiles('FilterSpec', basedir, 'num', [], 'Prompt',...
                    'Select the scanbox day folder','out','cell');
                
                % turn cell output into dates vector
                dates = [];
                for i = 1:length(folder_names)
                    dates(i) = folder_names{i}(1:6);
                end
                obj.initial_dates = sort(dates);

            else

                obj.initial_dates = p.dates;

            end

            % get runs
            runs = {};
            for i = 1:length(obj.initial_dates)
                date = obj.initial_dates(i);
                runs{i} = pipe.lab.runs(mouse, date, p.server);
            end
            obj.initial_runs = runs;

            % save newly minted xday tracking object
            obj.mouse = mouse;
            obj.pars = p;
            save([obj.savedir filesep 'xday_obj'],'obj','-v7.3')
        end  
    end
    
end