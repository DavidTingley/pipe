function info = write_sbxinfo(path, varargin)
%WRITE_SBXINFO Summary of this function goes here
%   Detailed explanation goes here

    p = inputParser;
    % ---------------------------------------------------------------------
    % Most important variables
    addOptional(p, 'mouse', []);  % Mouse name
    addOptional(p, 'date', []);  % Date
    addOptional(p, 'run', []);  % Run, supercedes path if mouse date and run are set
    addOptional(p, 'movie', []);  % Used to set dimensions, supercedes height, width, channels, times
    addOptional(p, 'height', 512);  % Movie height
    addOptional(p, 'width', 796);  % Movie width
    addOptional(p, 'length', []);  % Movie length, only used for config
    addOptional(p, 'channels', 1);  % Number of color channels
    addOptional(p, 'single_color', 'green');  % If a single color, can be red or green
    addOptional(p, 'bidirectional', false);  % Set to true if bidirectional imaging.

    if length(varargin) == 1 && iscell(varargin{1}), varargin = varargin{1}; end
    parse(p, varargin{:});
    p = p.Results;
    
    %% Parse results

    if ~isempty(p.mouse) && ~isempty(p.date) && ~isempty(p.run)
        path = pipe.lab.rundir(p.mouse, p.date, p.run);
        path = fullfile(path, sprintf('%s_%06i%03i.mat', p.mouse, p.date, p.run));
    end
    
    if isempty(path)
        error('Path not found');
    end
    
    % Force path to .mat
    if ~strcmp(path(end-4:end), '.mat')
        [parent, fname, ~] = fileparts(path);
        path = fullfile(parent, [fname '.mat']);
    end
    
    if ~isempty(p.movie)
        if ndims(p.movie) == 4
            p.channels = size(p.movie, 1);
            p.width = size(p.movie, 2);
            p.height = size(p.movie, 3);
            p.length = size(p.movie, 4);
        elseif ndims(p.movie) == 3
            p.width = size(p.movie, 1);
            p.height = size(p.movie, 2);
            p.length = size(p.movie, 3);
        elseif ndims(p.movie) == 2
            p.width = size(p.movie, 1);
            p.height = size(p.movie, 2);
        end
    end
    
    channels = 2;
    if p.channels == 2
        channels = 1;
    elseif strcmp(p.single_color, 'red')
        channels = 3;
    end
    
    scanmode = 1;
    if p.bidirectional
        scanmode = 0;
    end
    

    %% Create info
    config = struct( ...
        'wavelength', 960, ...
        'frames', p.length, ...
        'lines', p.height, ...
        'magnification', 2, ...
        'pmt0_gain', 0.5, ...
        'pmt1_gain', 0.5, ...
        'knobby', struct([]) ...
    );
    
    info = struct( ...
        'frame', 0, ...
        'line', 0, ...
        'event_id', 1, ...
        'resfreq', 7930, ...
        'postTriggerSamples', 5000, ...
        'recordsPerBuffer', p.height, ...
        'bytesPerBuffer', p.height*20000, ...
        'channels', channels, ...
        'ballmotion', [], ...
        'abort_bit', 0, ...
        'scanbox_version', 2, ...
        'scanmode', scanmode, ...
        'config', config, ...
        'sz', [p.height, p.width], ...
        'height', [p.height], ...
        'width', [ p.width], ...
        'otwave', [], ...
        'otwave_um', [], ...
        'otparam', [], ...
        'otwavestyle', 1, ...
        'volscan', 0, ...
        'power_depth_link', 0, ...
        'opto2pow', [], ...
        'area_line', 1, ...
        'calibration', struct(), ...
        'objective', 'Nikon 16x', ...
        'messages', {[]}, ...
        'usernotes', '' ...
     );

    save(path, 'info');
    % info = pipe.io.read_sbxinfo(path);
end

