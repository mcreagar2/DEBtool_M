%% custom_results_my_pet
% presents results of univariate data graphically

%%
function custom_results_template(par, metaPar, data, txtData, auxData)
%par, metaPar, txtPar, data, auxData, metaData, txtData, weights
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/04/12
  % modified 2015/08/25
  % modified 2018/09/06 by Nina Marn
  
  %% Syntax
  % <../custom_results_my_pet_template.m *custom_results_my_pet_template*>(par, metaPar, txtData, data, auxData)
  
  %% Description
  % present customized results of univariate data
  %
  % * inputs 
  %
  % * par: structure with parameters (see below)
  % * metaPar: structure with field T_ref for reference temperature
  % * txt_data: text vector for the presentation of results
  % * data: structure with data
  % * auxData: structure with temperature data and potential food data
  
  %% Remarks
  % This is a template to create a custom_results_my_pet file. 
  % Replace '_template' with 'my_pet' to use with my_pet templates - this function will be called automatically by <results_pets> function of DEBtool_M
  % Modify to select and plot uni-variate data for your entry: copy to  folder of your species, 
  %     replacing 'template' (or 'my_pet') with the name of your species,
  %     and template data with your entry-specific data you wish to plot
  
  % get predictions
  data2plot = data;              % copy data to Prd_data
  t = linspace(0, 650, 100)';   % set independent variable
  L = linspace(0.8, 5.2, 100)'; % set independent variable
  data2plot.tL = t; % overwrite independent variable in tL
  data2plot.LW = L; % overwrite independent variable in LW
  [prdData, info] = predict_my_pet(par, data2plot, auxData);
  
  [stat, txt_stat]  = feval('statistics_st', metaPar.model, par, C2K(20), par.f);
 
  if strcmp(metaPar.model, 'abj')
    fprintf(['\n acceleration factor s_M is ', num2str(stat.s_M), ' \n'])
  end

  % unpack data & predictions
  tL     = data.tL;     % data points first set
  LW     = data.LW;     % data points second set
  EL     = prdData.tL; % predictions (dependent variable) first set
  EW     = prdData.LW; % predictions (dependent variable) second set

  close all % remove existing figures, else you get more and more if you retry

  figure % figure to show results of uni-variate data
  set(gca,'Fontsize',12, 'Box', 'on')
  set(gcf,'PaperPositionMode','manual');
  set(gcf,'PaperUnits','points'); 
  set(gcf,'PaperPosition',[0 0 350 200]);%left bottom width height
         
  subplot(1,2,1)
  plot(t, EL, 'g', tL(:,1), tL(:,2), '.r', 'markersize', 20, 'linewidth', 2)
  xlabel([txtData.label.tL{1}, ', ', txtData.units.tL{1}])
  ylabel([txtData.label.tL{2}, ', ', txtData.units.tL{2}])
  
  subplot(1,2,2) % figure to show results of uni-variate data
  plot(L, EW, 'g', LW(:,1), LW(:,2), '.r', 'markersize', 20, 'linewidth', 2)
  xlabel([txtData.label.LW{1}, ', ', txtData.units.LW{1}])
  ylabel([txtData.label.LW{2}, ', ', txtData.units.LW{2}])
 
  print -dpng results_my_pet_01.png
