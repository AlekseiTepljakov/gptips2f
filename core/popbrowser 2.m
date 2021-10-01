function popbrowser(gp,dataset,ID,complexityType,logR2)
%POPBROWSER Visually browse complexity and performance characteristics of a population.
%
%   POPBROWSER(GP) shows a plot of the current population on the axes
%   fitness vs complexity. The Pareto front is plotted as a series of green
%   circles. Non Pareto front individuals are shown as blue circles. The
%   best individual (as evaluated on the training data) is highlighted with
%   a red circle.
%
%   For multigene symbolic regression, POPBROWSER(GP) shows a scatterplot
%   of 1 - R^2 (coefficient of determination) vs expressional complexity.
%   By default 1 - R^2 is calculated on the training data.
%
%   Clicking on a circle reveals the numeric population identifier ID of
%   the corresponding GP individual(s) and, if a multigene regression
%   model, a simplified overall model equation (to 2 digits of precision
%   using the 'fast' MuPAD simplification mode).
%
%   Additionally, for multigene regression models:
%
%   To specify a different data set to compute 1 - R^2 on, use
%
%   POPBROWSER(GP,DATASET) where DATASET can equal 'train','val' or 'test'.
%   
%   POPBROWSER(GP,DATASET,ID) adds a magenta dot to represent a user
%   supplied model identifier ID, which can be a numeric model ID of a
%   multigene model in the GP population or the 'best', 'valbest' or
%   'testbest' model. ID can also be a struct representing a multigene
%   regression model generated by GPMODEL2STRUCT or GENES2GPMODEL. This is
%   useful for examining the performance of user tailored models when used
%   in conjunction with UNIQUEGENES and GENEBROWSER.
%
%   The plotted tree complexity is by default 'expressional complexity'
%   even if the run was performed using 'node count' as a measure of
%   complexity. However, either measure can be displayed by setting
%   COMPLEXITYTYPE to 1 (expressional) or 0 (node count) using:
%
%   POPBROWSER(GP,DATASET,ID,COMPLEXITYTYPE) where ID may be set to empty
%   ([]) if you don't want to plot a user supplied model.
%
%   To plot a log Y-axis use:
%
%   POPBROWSER(GP,DATASET,ID,COMPLEXITYTYPE,LOGR2) with LOGR2 = TRUE. This
%   gives better visual resolution between high performance models.
%
%   Copyright (c) 2009-2015 Dominic Searson
%
%   GPTIPS 2
%
%   See also SUMMARY, RUNTREE, GPMODELREPORT, PARETOREPORT, GPMODELFILTER,
%   GENEBROWSER, GENES2GPMODEL, UNIQUEGENES

if nargin < 1
    disp('Basic usage is POPBROWSER(GP)');
    return;
end

if nargin < 2 || isempty(dataset)
    dataset = 'train';
end

if nargin < 3
    ID = [];
end

if nargin < 4 || isempty(complexityType)
    complexityType = 1;
end

if nargin < 5 || isempty(logR2)
    logR2 = false;
end

if ischar(complexityType) || ischar(logR2)
    error('complexityType and logR2 parameters must not be strings.');
end

if complexityType < 0 || complexityType > 1
    error('Complexity type must be 0 = node count or 1 = expressional.');
end

if gp.runcontrol.pop_size > 750
    disp('Please wait, performing Pareto sort of population ...');
end

browserFig = figure('visible','off'); set(browserFig,'name','GPTIPS 2 Population browser');
ax1 = gca; set(ax1 ,'box','on')

if ~isempty(gp.userdata.name)
    setname = ['Data: ' gp.userdata.name];
else
    setname = '';
end

%string for figure title
mergeStr = '';
if gp.info.merged && gp.info.filtered
    mergeStr = ' (merged & filtered)';
elseif gp.info.merged
    mergeStr = ' (merged)';
elseif gp.info.filtered
    mergeStr = ' (filtered)';
end

%multigene regression
mgmodel = false;
if strncmpi(func2str(gp.fitness.fitfun),'regressmulti',12);
    
    
    mgmodel = true;
    
    %data set options
    if strcmpi(dataset,'train')
        
        yvals = 1 - gp.fitness.r2train;
        ylabelContent = '1-R^2 (training)';
        yvalBest = 1 - gp.results.best.r2train;
        
    elseif strcmpi(dataset,'val')
        
        if isfield(gp.fitness,'r2val')
            yvals = 1 - gp.fitness.r2val;
            ylabelContent = '1-R^2 (validation)';
            yvalBest = 1 - gp.results.best.r2val;
        else
            error('No validation data was found.');
        end
        
    elseif strcmpi(dataset,'test')
        
        if isfield(gp.fitness,'r2test')
            yvals = 1 - gp.fitness.r2test;
            ylabelContent = '1-R^2 (testing)';
            yvalBest = 1 - gp.results.best.r2test;
        else
            error('No test data was found.');
        end
    else
        error('The specified data set must be ''train'',''val'' or ''test''.');
    end
    
    
    %plot all models' 1-R2
    if complexityType
        bluedots = plot(ax1,gp.fitness.complexity,yvals,'o');
    else
        bluedots = plot(ax1,gp.fitness.nodecount,yvals,'o');
    end
    
    set(bluedots,'markeredgecolor','none','markerfacecolor',[0 0.45 0.74]);
    hold on;
    
    %if user supplied gpmodel is mg regression model struct then plot that
    %in magenta
    if ~isempty(ID)
        
        %user supplied multigene regression model structure
        if isa(ID,'struct')
            
            if  ~(isfield(ID,'expComplexity') && isfield(ID,'numNodes') )
                close(browserFig);
                error('Invalid multigene regression model structure supplied as ID');
            end
            
            %plot model with supplied numeric population index
        elseif isnumeric(ID) && numel(ID) == 1
            
            if ID > gp.runcontrol.pop_size || ID  < 1
                close(browserFig);
                error('Supplied population index is invalid.');
            end
            
            ID = gpmodel2struct(gp,ID,false,false,true);
            
        elseif ischar(ID) && strcmpi(ID,'best')
            
            ID = gpmodel2struct(gp,'best',false,false,true);
            
        elseif ischar(ID) && strcmpi(ID,'valbest')
            
            ID = gpmodel2struct(gp,'valbest',false,false,true);
            
            if ~ID.valid
                error('No validation data was found.');
            end
            
        elseif ischar(ID) && strcmpi(ID,'testbest')
            
            ID = gpmodel2struct(gp,'testbest',false,false,true);
            
            if ~ID.valid
                error('No test data was found.');
            end
            
        else %unrecognised
            close(browserFig);
            error('Invalid model identifier supplied.');
        end
        
    end
    
    %highlight models on the pareto front with green circles
    if complexityType
        xrank = ndfsort_rank1([yvals gp.fitness.complexity]);
        greendots = plot(ax1,gp.fitness.complexity(xrank==1),yvals(xrank==1),'o');
    else
        xrank = ndfsort_rank1([yvals gp.fitness.nodecount]);
        greendots = plot(ax1,gp.fitness.nodecount(xrank==1),yvals(xrank==1),'o');
    end
    
    set(greendots,'markerfacecolor','green','markeredgecolor',[0.25 0.25 0.25]);
    gp.fitness.values = yvals; %for use with datacursor
    
    %plot supplied model
    if ~isempty(ID)
        plotmodeldot = true;
        
        if strcmpi(dataset,'train') && ~ID.train.warning
            modeldotYval = 1 - ID.train.r2;
        elseif strcmpi(dataset,'val') && ~ID.val.warning
            modeldotYval = 1 - ID.val.r2;
        elseif strcmpi(dataset,'test') && ~ID.test.warning
            modeldotYval = 1 - ID.test.r2;
        else %cannot plot this model on this data set
            plotmodeldot = false;
        end
        
        if plotmodeldot
            if complexityType
                modeldot = plot(ax1,ID.expComplexity,modeldotYval,'mo','linewidth',1,'markersize',8);
            else
                modeldot = plot(ax1,ID.numNodes,modeldotYval,'mo','linewidth',1,'markersize',8);
            end
            set(modeldot,'markerfacecolor','magenta','markeredgecolor','black');
        end
    end
    
    %plot "best" model found on training data circled in red
    if complexityType
        bestComplexity = gp.results.best.complexity;
    else
        bestComplexity = gp.results.best.nodecount;
    end
    
    plot(ax1,bestComplexity,yvalBest,'ro','linewidth',2,'markersize',8);
    grid on; ylabel(ax1,ylabelContent);
    
    %for R2, always set y-axis between 0 and 1
    set(ax1,'Ylim',[0 1]);
    
    if complexityType
        xlabel(ax1,'Expressional complexity');
    else
        xlabel(ax1,'Number of nodes');
    end
    hold off;
    
    title(ax1,{['Population' mergeStr ' models = ' num2str(gp.runcontrol.pop_size)],...
        setname},'interpreter','none','FontWeight','bold');
    
    %change y axis if log (1-R^2) vals required
    if logR2
        set(ax1,'Yscale','log');
        set(ax1,'Ylimmode','auto');
    end
    
else %for other fitness functions, plot raw training fitness values
    if complexityType
        bluedots = plot(ax1,gp.fitness.complexity,gp.fitness.values,'o');
    else
        bluedots = plot(ax1,gp.fitness.nodecount,gp.fitness.values,'o');
    end
    
    set(bluedots,'markeredgecolor','none','markerfacecolor',[0 0.45 0.74]);
    hold on; grid on;
    
    %find 'best' on training data
    best_fit = gp.results.best.fitness;
    if complexityType
        bestComplexity = gp.results.best.complexity;
    else
        bestComplexity = gp.results.best.nodecount;
    end
    
    %plot 'best' on training data
    plot(ax1,bestComplexity,best_fit,'ro','linewidth',2,'markersize',8);
    ylabel(ax1,gp.fitness.label);
    
    if complexityType
        xlabel(ax1,'Expressional complexity');
    else
        xlabel(ax1,'Number of nodes');
    end
    
    %highlight individuals on the pareto front with green circles
    if gp.fitness.minimisation
        mo = 1;
    else
        mo = -1;
    end
    if complexityType
        xrank = ndfsort_rank1([(mo * gp.fitness.values) gp.fitness.complexity]);
        greendots = plot(ax1,gp.fitness.complexity(xrank == 1),gp.fitness.values(xrank == 1),'o');
    else
        xrank = ndfsort_rank1([(mo * gp.fitness.values) gp.fitness.nodecount]);
        greendots = plot(ax1,gp.fitness.nodecount(xrank == 1),gp.fitness.values(xrank == 1),'o');
    end
    
    set(greendots,'markerfacecolor','green','markeredgecolor',[0.25 0.25 0.25]);
    hold off;
    title(ax1,{['Population = ' mergeStr num2str(gp.runcontrol.pop_size)],...
        setname},'interpreter','none','FontWeight','bold');
end

gp.complexityType = complexityType;
grid on; set(browserFig,'userdata',gp); set(browserFig,'numbertitle','off'); set(browserFig,'visible','on');

%enable datacursor mode
dcManager = datacursormode(gcf);
if mgmodel && gp.info.toolbox.symbolic()
    set(dcManager,'UpdateFcn',@disp_mgmodel);
else
    set(dcManager,'UpdateFcn',@disp_indiv);
end

set(dcManager,'SnapToDataVertex','on');
set(dcManager,'enable','on');
drawnow;

function txt = disp_indiv(~,event_obj)
%returns population member ID to datacursor.
if verLessThan('Matlab','8.4')
    gp = get(gcbf,'userdata'); %appears not to work in 2014b
else
    gp = get(gcf,'userdata'); %workaround til this is fixed
end

a = get(event_obj);
b = get(a.Target);

if strcmp(b.Type,'line')
    comp = a.Position(1);
    fitness = a.Position(2);
    
    %locate in population
    fitInd = find(gp.fitness.values==fitness);
    
    if gp.complexityType
        compInd = find(gp.fitness.complexity==comp);
    else
        compInd = find(gp.fitness.nodecount==comp);
    end
    
    ind = intersect(fitInd,compInd);
    numInds = numel(ind);
    
    txt = cell(numInds+1,1);
    txt{1} ='Individual ID: ';
    for i=1:numInds
        txt{i+1} = int2str(ind(i));
    end
else
    txt = '';
end


function txt = disp_mgmodel(~,event_obj)
%returns multigene regression model info to datacursor.
if verLessThan('Matlab','8.4')
    gp = get(gcbf,'userdata'); %appears not to work in 2014b
else
    gp = get(gcf,'userdata'); %workaround til this is fixed
end

a = get(event_obj);
b = get(a.Target);

if strcmp(b.Type,'line')
    complexity = a.Position(1);
    fitness = a.Position(2);
    
    %locate in population
    fitInd = find(gp.fitness.values==fitness);
    
    if gp.complexityType
        compInd = find(gp.fitness.complexity==complexity);
    else
        compInd = find(gp.fitness.nodecount==complexity);
    end
    
    ind = intersect(fitInd,compInd);
    numInds = numel(ind);
    
    if numInds > 0
        
        if numInds > 10
            disp('Multiple matching models: only displaying first 5.');
            ind = ind(1:5);
            numInds = 5;
        end
        
        txt = cell(numInds+1,2);
        txt{1,1} ='Individual ID: ';
        txt{1,2} ='Model: ';
        
        for i=1:numInds
            txt{i+1,1} = int2str(ind(i));
            try
                txt{i+1,2} = char(vpa(gpmodel2sym(gp,ind(i),true),2)); %only display 2 chars of precision
            catch
                txt{i+1,2} = 'Invalid model';
            end
        end
        
    else
        txt = {'Model not found in population.'}; %e.g. valbest frequently isn't in final population
    end
    
else
    txt = '';
end
