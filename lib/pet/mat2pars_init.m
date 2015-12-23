%% mat2pars_init
% writes a pars_init file from a .mat file

%%
function mat2pars_init(speciesnm)
% created 2015/09/21 by  Goncalo Marques

%% Syntax
% <../mat2pars_init.m *mat2pars_init*> (speciesnm) 

%% Description
% Makes a pars_init file from a results_'speciesnm'.mat file
%
% Input:
%
% * speciesnm: string with the species nama

%% Remarks
% Keep in mind that the files will be saved in your local directory; use
% the cd command BEFORE running this function to save files in the desired
% place.
% NOTE: This function is not yet finalised !

%% Example of use
% mat2pars_init(speciesnm)

matFile = ['results_', speciesnm, '.mat'];

% check that mydata actually exists
if exist(matFile, 'file') == 0
  fprintf([matFile, ' not found.\n']);
  return
end

pars_initFile = ['pars_init_', speciesnm, '.m'];

if exist(pars_initFile, 'file') == 2
  prompt = [pars_initFile, ' already exists. Do you want to overwrite it? (y/n) '];
  overwr = lower(input(prompt, 's'));
  if ~strcmp(overwr, 'y') && ~strcmp(overwr, 'yes')
    fprintf([pars_initFile, ' was not overwritten.\n']);
    return
  end
end

load(matFile);

% open pars_init file
pars_init_id = fopen(['pars_init_', speciesnm, '.m'], 'w+'); % open file for reading and writing, delete existing content

fprintf(pars_init_id, ['%%%% pars_init_', speciesnm,'\n']);
fprintf(pars_init_id, '%% sets (initial values for) parameters\n\n');
fprintf(pars_init_id, ['function [par, metaPar, txtPar] = pars_init_', speciesnm,'(metaData)\n\n']);
fprintf(pars_init_id, ['metaPar.model = ''', metaPar.model,'''; \n\n']);

free = par.free;
par = rmfield(par, 'free');
parFields = fields(par);

% checking the existence of metapar fields
EparFields = get_parfields(metaPar.model);

fprintf(pars_init_id, '%%%% core primary parameters \n');

for i = 1:length(EparFields)
  currentPar = EparFields{i};
  write_par_line(pars_init_id, currentPar, par.(currentPar), free.(currentPar), txtPar.units.(currentPar), txtPar.label.(currentPar));
end

fprintf(pars_init_id, '\n%%%% other parameters \n');

parFields = setdiff(parFields, EparFields);

% separate chemical parameters from other
pos = [];
par_auto = addchem([], [], [], [], metaData.phylum, metaData.class);
chemParFields = fields(par_auto);
otherParFields = setdiff(parFields, chemParFields);

for i = 1:length(otherParFields)
  currentPar = otherParFields{i};
  write_par_line(pars_init_id, currentPar, par.(currentPar), free.(currentPar), txtPar.units.(currentPar), txtPar.label.(currentPar));
end

fprintf(pars_init_id, '\n%%%% set chemical parameters from Kooy2010 \n');
fprintf(pars_init_id, '[par, units, label, free] = addchem(par, units, label, free, metaData.phylum, metaData.class);');

for i = 1:length(chemParFields)
  currentPar = chemParFields{i};
  if par.(currentPar) ~= par_auto.(currentPar)
    write_par_line(pars_init_id, currentPar, par.(currentPar), free.(currentPar), txtPar.units.(currentPar), txtPar.label.(currentPar));
  end
end

fprintf(pars_init_id, '\n\n%%%% Pack output: \n');
fprintf(pars_init_id, 'txtPar.units = units; txtPar.label = label; par.free = free; \n');

fclose(pars_init_id);


function write_par_line(file_id, parName, parValue, freeValue, unitsString, labelString)
  fprintf(file_id, ['par.', parName,' = ', num2str(parValue), ';  ']);
  fprintf(file_id, ['free.', parName,' = ', num2str(freeValue), ';  ']);
  fprintf(file_id, ['units.', parName,' = ''', unitsString, ''';  ']);
  fprintf(file_id, ['label.', parName,' = ''', labelString, '''; \n']);

