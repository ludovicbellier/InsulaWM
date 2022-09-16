function [idxLat, elecCoordBipo] = iWM_plotValOnAnat(patientList, params)
%%% patientList = {'AMC026', 'AMC038', 'AMC062'}; space = 'MNI'; values = 'r'; highCutOff = []; centered = 0; strDir = '';
%%% choices for values => {numeric, ''};


% Add toolboxes to the path
addpath('/home/knight/lbellier/DataWorkspace/_tools');
ftDir = '/home/knight/lbellier/DataWorkspace/_tools/git/fieldtrip/';
if exist('ft_defaults.m', 'file') == 0
    addpath(ftDir); ft_defaults;
end


% Define parameters
paramFields = fieldnames(params);
for idx = 1:length(paramFields)
    eval(sprintf('%s = params.%s;', paramFields{idx}, paramFields{idx}));
end
edgeSize = 2; 
colorGrain = 0.01;
flagCbar = 1;
flagTitle = 0;
trigLegend = 0;
rootDir = '/home/knight/IWM_SEEG/';
markerList = {'o', '^', 's', 'd', 'v', '<', '>', 'h'};
% figPos = [610,401,700,525]; %figPos = [10 45 1277 965]; %figPos = [46 276 1277 965];
% figPos = [1554 47 1882 1209];
figPos = [6 47 1079 856]; % Anais' screen


% Convert patientList to cell array when needed
if ~iscell(patientList)
    patientList = {patientList};
end
nPat = numel(patientList);


% load MNI template
if flagWholeBrain == 1
    pial = load([ftDir 'template/anatomy/surface_pial_left.mat']);
    pial_lh = pial.mesh;
    pial = load([ftDir 'template/anatomy/surface_pial_right.mat']);
    pial_rh = pial.mesh;
    clear pial mesh_lh mesh_rh
    strWB = '_wholeBrain';
else
    load('_analyses/anatDataInsula_FINAL.mat', 'mesh_LI', 'mesh_RI', 'elec_mni_frv_LI', 'elec_mni_frv_RI');
    load('_analyses/allInsulaMNIcoord_12patients_FINAL.mat', 'elec_mni_frv');
    pial_lh = mesh_LI;
    pial_rh = mesh_RI;
    idxLat = double(elec_mni_frv.chanpos(:, 1) > 0) + 1;
    strWB = '';
end
suffixSpace = '-MNI';


% Get values to plot
if isnumeric(values)
    nElecs = length(values);
    idxFlagPlot = 1:nElecs;
    idxSig = idxFlagPlot;
    strTitle = 'custom values';
    [elecColors, colorMap, clim] = val2colorScale(values, colorGrain, valRange, centered, cmap);
    flipud(colorMap);
    idxSig = setdiff(idxSig, find(isnan(values)));
else
    nElecs = size(elecLat, 1);
    idxFlagPlot = 1:nElecs;
    idxSig = idxFlagPlot;
    strTitle = values;
    switch values
        case ''
            elecColors = repmat([0 0 0], nElecs, 1);
            strTitle = 'coverage';
            
        case {'idPat', 'idElec'}
            switch values
                case 'idPat'
                    values = idPat;
                case 'idElec'
                    labelsTMP = split(dataLabels, '-');
                    labelsTMP = cellfun(@(x) x(regexp(x, '[^ \f\d]')), labelsTMP(:, 2), 'un', 0);
                    allLabels = unique(labelsTMP);
                    [~, values] = ismember(labelsTMP, allLabels);
            end
            flagCbar = 1;
            [elecColors, colorMap, clim] = val2colorScale(values, colorGrain, valRange, centered, cmap);
            flipud(colorMap);
        case 'labels'
            trigLegend = 1;
            labelId = 'fs';
            load(sprintf('%sPinkFloyd/labelColors.mat', rootDir), 'labelInfo_FS', 'labelInfo_MNI');
            labels = cell(nPat, 1);
            if strcmp(labelId, 'fs')
                for idxPat = 1:nPat
                    load(sprintf('%sPinkFloyd/_anatomy/%s/%s_labelTable.mat', rootDir, patientList{idxPat}, patientList{idxPat}), 'labelTable_FS', 'labelNames_FS');
                    [~, idxLabels] = max(labelTable_FS(:, 2:end), [], 2);
                    labels{idxPat} = labelNames_FS(idxLabels);
                end
                labelInfo = labelInfo_FS;
            elseif strcmp(labelId, 'mni')
                for idxPat = 1:nPat
                load(sprintf('%sPinkFloyd/_anatomy/%s/%s_labelTable.mat', rootDir, patientList{idxPat}, patientList{idxPat}), 'labelTable_MNI', 'labelNames_MNI');
                    [~, idxLabels] = max(labelTable_MNI(:, 2:end), [], 2);
                    labels{idxPat} = labelNames_MNI(idxLabels);
                end
                labelInfo = labelInfo_MNI;
            end
            labels = vertcat(labels{:});
            uniqueLabels = unique(labels);
            nLabels = length(uniqueLabels);
            idxColors = cellfun(@(x) find(strcmp(labelInfo(:, 1), x)), labels);
            elecColors = cat(1, labelInfo{idxColors, 2});
            uniqueColors = cat(1, labelInfo{unique(idxColors), 2});
    end
end

if length(mask) > 1
    nAnatClust = sum(unique(mask) ~= 0);
else
    nAnatClust = 1;
end


elecColors = elecColors(idxSig, :);
try
    dataLabels = dataLabels(idxSig);
catch
end
idxFlagPlot = idxFlagPlot(idxSig);
if length(mask) > 1
    mask = mask(idxSig);
end
if isnumeric(values)
    values = values(idxSig);
end

strLat = 'top';
if ~isempty(lateralFilter) && any(strcmpi({'l', 'r'}, lateralFilter(1)))

    switch lower(lateralFilter(1))
        case 'l'
            elecCoordBipo = elec_mni_frv_LI;
            elecCoordBipo.elecpos = elecCoordBipo.elecpos + [-XOffset 0 0];
            idxLatTarget = 1;
            elecLabelsFunc = elec_mni_frv_LI.label;
            strLat = 'left';
        case 'r'
            elecCoordBipo = elec_mni_frv_RI;
            elecCoordBipo.elecpos = elecCoordBipo.elecpos + [XOffset 0 0];
            idxLatTarget = 2;
            elecLabelsFunc = elec_mni_frv_RI.label;
            strLat = 'right';
    end
    idxLat = find(idxLat == idxLatTarget);
    elecColors = elecColors(idxLat, :);
    if length(mask) > 1
        mask = mask(idxLat);
    end
    idxFlagPlot = idxFlagPlot(idxLat);
    if isnumeric(values)
        values = values(idxLat);
    end
else
    idxLat = idxSig;
end
titleStr = '';

if ~isempty(mask)
    idxMask = find(mask~=0);
    if nAnatClust > 1
        titleStr = sprintf('%i / %i patients (%i C1 / %i C2) - %i elecs (%i C1 / %i C2)', ...
            length(unique(idPat(idxMask))), nPat, length(unique(idPat(mask==1))), length(unique(idPat(mask==2))), ...
            length(idxMask), sum(mask==[1 2]));
    else
        titleStr = sprintf('%i / %i patients - %i elecs', length(unique(idPat(idxMask))), nPat, length(idxMask));
    end
    elecCoordBipo = ft_selectElecSubset(elecCoordBipo, idxMask);
    elecColors = elecColors(idxMask, :);
    mask = mask(idxMask);
    idxFlagPlot = idxFlagPlot(idxMask);
    values = values(idxMask);
end


% Plot values on surface
hf = figure('Position', figPos, 'Color', [1 1 1], 'DefaultAxesFontSize', 5);
if ~isempty(lateralFilter) && strcmpi('l', lateralFilter(1))
    ft_plot_mesh(pial_lh, 'facealpha', faceAlpha, 'EdgeAlpha', 0);
    viewPoint = [-90 0];
elseif ~isempty(lateralFilter) && strcmpi('r', lateralFilter(1))
    ft_plot_mesh(pial_rh, 'facealpha', faceAlpha, 'EdgeAlpha', 0);
    viewPoint = [90 0];
else
    ft_plot_mesh(pial_lh, 'facealpha', faceAlpha, 'EdgeAlpha', 0);
    ft_plot_mesh(pial_rh, 'facealpha', faceAlpha, 'EdgeAlpha', 0);
    viewPoint = [0 90];
end
if ~isempty(idxFlagPlot)
    hold on;
    if ~isempty(mask)
        allAnatClust = unique(mask);
        allAnatClust = allAnatClust(allAnatClust~=0);
        for idxAC = 1:length(allAnatClust)
            idxTMP = mask==allAnatClust(idxAC);
            scatter3(elecCoordBipo.elecpos(idxTMP,1), elecCoordBipo.elecpos(idxTMP,2), elecCoordBipo.elecpos(idxTMP,3), elecSize*edgeSize, elecColors(idxTMP,:), 'filled', 'marker', markerList{allAnatClust(idxAC)});
        end
    else
        scatter3(elecCoordBipo.elecpos(:,1), elecCoordBipo.elecpos(:,2), elecCoordBipo.elecpos(:,3), elecSize*edgeSize, elecColors, 'filled', 'marker', markerList{1});
    end
end
view(viewPoint); material dull; lighting gouraud; camlight;


%
dataLabels = elecLabelsFunc;
dcm = datacursormode(hf);
set(dcm, 'update', {@PF_cursorOutputFunction, dataLabels, [], values});

if flagTitle == 1
    if ~isempty(titleStr)
        title(titleStr, 'Interpreter', 'none', 'Fontsize', 6);
    else
        patientListStr = sprintf('%s, ', patientList{:, 1});
        patientListStr = ['[' patientListStr(1:end-2) ']'];
        if nPat <= 5
            title(sprintf('%s - %s', patientListStr, strTitle), 'Interpreter', 'none');
        else
            title(sprintf('%i patients - %s', nPat, strTitle), 'Interpreter', 'none');
        end
    end
end
if flagCbar == 1
    hCbar = colorbar('Location', 'south'); colormap(colorMap); set(gca, 'CLim', double(clim));
    cbarPos = get(hCbar, 'Position'); cbarPos(2) = .08;
    cbarPos = get(hCbar, 'Position'); cbarPos(2) = .05; cbarPos(4) = .03; %width
    set(hCbar, 'Position', cbarPos, 'AxisLocation', 'out', 'Ticks', 1:nPat);
end
if trigLegend == 1
    h5 = plot(nan(2, nLabels), '.', 'MarkerSize', 8);
    set(h5, {'color'}, mat2cell(uniqueColors, ones(nLabels, 1)));
    legend([h2; h3; h4; h5], ['ref elec'; 'noisy elecs'; 'epileptic elecs'; uniqueLabels], 'Interpreter', 'none', 'Location', 'bestoutside');
    set(dcm, 'update', {@PF_cursorOutputFunction, elecCoord.label, labels});
end
if figOutTrig == 1
    pause(1);
    print(sprintf('%s_figures/insula/%s_%ipat_%s%s.png', rootDir, strTitle, nPat, strLat, strWB), '-dpng', '-r300');
end