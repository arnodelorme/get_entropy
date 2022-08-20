%% Computes entropy on EEGLAB-formatted data.
%
% Cedric Cannard, August 2022

function pop_entropy(EEG,varargin)

% Basic checks and warnings
if nargin < 1, help pop_entropy; return; end
if isempty(EEG.data), error('Cannot process empty dataset.'); end
if isempty(EEG.chanlocs(1).labels), error('Cannot process without channel labels.'); end
% if ~isfield(EEG.chanlocs, 'X') || isempty(EEG.chanlocs(1).X), error("Electrode locations are required. " + ...
%         "Go to 'Edit > Channel locations' and import the appropriate coordinates for your montage"); end
if isempty(EEG.ref), warning(['EEG data not referenced! Referencing is highly recommended ' ...
        '(e.g., CSD-transformation, infinity-, or average- reference)!']); end
if length(size(EEG.data)) == 2
    continuous = true;
else
    continuous = false;
end

% GUI
if nargin < 2
    drawnow;
    eTypes = {'Sample entropy' 'Multiscale entropy' 'Refined composite multiscale fuzzy entropy (default)'};
    cTypes = {'Mean' 'Standard deviation (default)' 'Variance'};
    uigeom = { [.5 .5 .5] .5 [.5 .5 .5] .5 [.5 .5 .5] .5 .5};
    uilist = {
        {'style' 'text' 'string' 'Channel selection:'}, ...
        {'style' 'edit' 'string' ' ' 'tag' 'chanlist'}, ...
        {'style' 'pushbutton' 'string'  '...', 'enable' 'on' ...
        'callback' "tmpEEG = get(gcbf, 'userdata'); tmpchanlocs = tmpEEG.chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels},'withindex','on'); set(findobj(gcbf,'tag','chanlist'),'string',tmpval); clear tmp tmpEEG tmpchanlocs tmpval" }, ...
        {} ...
        {'style' 'text' 'string' 'Entropy type:'} ...
        {'style' 'popupmenu' 'string' eTypes 'tag' 'etype'} {} ...
        {} ...
        {'style' 'text' 'string' 'Coarse graining method:'} ...
        {'style' 'popupmenu' 'string' cTypes 'tag' 'stype'} {} ...
        {} ...
        {'style' 'checkbox' 'string' 'Bandpass filter each scale to control for spectral bias (recommended)?','tag' 'filter','value',0}  ...
        };
    result = inputgui(uigeom,uilist,'pophelp(''pop_entropy'')','entropy EEGLAB plugin',EEG);
    if isempty(result), return; end
    
    %decode user inputs
    args = {};
    if ~isempty(result{1})
        chanlist = split(result{1})';
        args = { args 'channel'  chanlist };
    else
        error('You must select at least one channel to compute entropy.');
    end
    args = [args {'etype'} eTypes(result{2})];
    args = [args {'ctype'} cTypes(result{3})];
    args = [args {'filter'} result{4}];
else
    args = varargin;
end

% Defaults
args = struct(args{:});
if ~isfield(args, 'chanlist') || isempty(args.chanlist)
    args.chanlist = {EEG.chanlocs.labels};
end
if ~isfield(args, 'etype') || isempty(args.etype)
    args.etype = 'Refined composite multiscale fuzzy entropy (default)';
end
if ~isfield(args, 'ctype') || isempty(args.ctype)
    args.ctype = 'Standard deviation (default)';
end
if ~isfield(args, 'filter') || isempty(args.filter)
    args.filter = 0;
end

if strcmp(args.etype, 'Sample entropy')

end
