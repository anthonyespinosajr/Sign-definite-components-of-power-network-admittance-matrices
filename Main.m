% Importing data for 34-Node Test Feeder
opts = detectImportOptions('1992 34-bus Feeder/line data.xls');
opts = setvartype(opts, 'string');
t_34 = readtable('1992 34-bus Feeder/line data.xls', opts);
t_34_transformer_data = readtable('1992 34-bus Feeder/Transformer Data.xls');

% Importing data for 37-Node Test Feeder
opts = detectImportOptions('1992 37-bus Feeder/Line Data.xls');
opts = setvartype(opts, 'string');
t_37 = readtable('1992 37-bus Feeder/Line Data.xls', opts);
t_37_transformer_data = readtable('1992 37-bus Feeder/Transformer Data.xls');

% Importing data for European Low Voltage Test Feeder
t_euro = readtable('European Low Voltage Test Feeder 2015\European_LV_CSV/Lines', 'NumHeaderLines', 1);
sequence_sheet_euro = readtable('European Low Voltage Test Feeder 2015\European_LV_CSV/LineCodes.csv', 'NumHeaderLines', 1);



%
% EUROPEAN LOW VOLTAGE TEST FEEDER
%

% Formatting data
edge_pairs_euro = table2array(t_euro(:, [2:3, 5]));
line_codes_euro = string(table2array(t_euro(:,7)));
sequence_codes_euro = string(table2array(sequence_sheet_euro(:,1)));
sequence_data_euro = table2array(sequence_sheet_euro(:,3:8));

% Build network admittance matrix (NAM) for this network
european_LVTF = EuropeanLVTF(edge_pairs_euro, line_codes_euro, sequence_data_euro, sequence_codes_euro);
y_lvtf = european_LVTF.buildAdmittanceMatrix();

% check if NAM components are sign definite
disp("EUROPEAN LOW VOLTAGE TEST FEEDER RESULTS");
european_LVTF.printResults();

% Compute and store eigenvalues of real and imaginary parts of NAM
[gev_lvtf, bev_lvtf] = european_LVTF.getEigenvalues();



%
% 34 NODE TEST FEEDER
%
            
% Get a list of all the included nodes in the graph
edge_pairs = str2double(table2array(t_34(:,1:4)));

% Get a list mapping between edge indices and line codes
line_codes = table2array(t_34(:,4));

% Build NAM for this network
bus_feeder_34 = BusFeeder34(edge_pairs, line_codes, t_34_transformer_data);
%bus_feeder_34.omitNodes([888; 890]); % omits 2-node subgraph connected by transformer
y_34 = bus_feeder_34.buildAdmittanceMatrix();

% Compute and store eigenvalues of real and imaginary parts of NAM
[gev_34, bev_34] = bus_feeder_34.getEigenvalues();

% Check if NAM components are sign definite
disp("34 NODE TEST FEEDER RESULTS");
bus_feeder_34.printResults();



%
% 37 NODE TEST FEEDER
%
            
% Get a list of all the included nodes in the graph
edge_pairs = str2double(table2array(t_37(:,1:4)));

% Get a list mapping between node indices and line codes
line_codes = table2array(t_37(:,4));

% Build NAM for this network
bus_feeder_37 = BusFeeder37(edge_pairs, line_codes, t_37_transformer_data);
%bus_feeder_37.omitNodes(775); % omits 1-node subgraph connected by transformer
y_37 = bus_feeder_37.buildAdmittanceMatrix();

% Compute and store eigenvalues of real and imaginary parts of NAM
[gev_37, bev_37] = bus_feeder_37.getEigenvalues();

% Check if NAM components are sign definite
disp("37 NODE TEST FEEDER RESULTS");
bus_feeder_37.printResults();