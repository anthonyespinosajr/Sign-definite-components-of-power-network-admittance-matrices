classdef SignDefiniteComputer < handle
    properties
        edges; % array of data for each line
        line_codes; % table of line codes for each line
        transformer_codes; % table of data for each transformer code
        length_index; % index of column giving physical edge length in line data file
        y; % network admittance matrix (NAM)
        g_eigenvalues; % eigenvalues of the real part of the network admittance matrix
        b_eigenvalues; % eigenvalues of the imaginary part of the network admittance matrix

        conversion_matrix = [1, -1,  0; % matrix which transforms line-to-neutral voltages to line-to-line voltages
                             0,  1, -1;
                            -1,  0,  1];
    end
    methods
        % Constructor
        function self = SignDefiniteComputer(edges, line_codes, length_index, transformer_codes)
            self.edges = edges;
            self.line_codes = line_codes;
            self.length_index = length_index;
            self.transformer_codes = transformer_codes;
        end

        function x = printResults(self)
            % Checking if NAM components are sign definite
            [gpd, bnd] = self.checkSignDefinite();
            
            % Checking if NAM components are sign semidefinite
            [gpsd, bnsd] = self.checkSignSemidefinite();
            
            % Checking if NAM is complex symmetric
            ys = self.checkSymmetric();

            % Print results
            disp("G is PSD");
            disp(gpsd);
            disp("B is NSD");
            disp(bnsd);
            disp("G is PD");
            disp(gpd);
            disp("B is ND");
            disp(bnd);

            disp("Y is complex symmetric");
            disp(ys)
        end

        % Checks whether the last computed NAM is complex symmetric
        function [ys] = checkSymmetric(self)
            ys = issymmetric(self.y);
        end

        % Returns an array of the eigenvalues of the real part of the NAM,
        % and an array of the eigenvalues of the imaginary part of the NAM
        function [gev, bev] = getEigenvalues(self)
            % get real and imaginary parts of the admittance matrix
            g = real(self.y);
            b = imag(self.y);

            % compute the eigenvalues of the real and imaginary parts
            self.g_eigenvalues = eig(g);
            self.b_eigenvalues = eig(b);

            % store the eigenvalues
            gev = self.g_eigenvalues;
            bev = self.b_eigenvalues;
        end
        
        % Returns whether the real part of the NAM is positive definite,
        % and whether the imaginary part of the NAM is negative definite
        function [gpd, bnd] = checkSignDefinite(self)
            self.getEigenvalues();

            % For the real (imaginary) part of the NAM, check if the 
            % eigenvalues are strictly positive (negative)
            gpd = all(self.g_eigenvalues>0);
            bnd = all(self.b_eigenvalues<0);
        end

        % Returns whether the real part of the NAM is positive semidefinite,
        % and whether the imaginary part of the NAM is negative semidefinite
        function [gpsd, bnsd] = checkSignSemidefinite(self)
            self.getEigenvalues();

            % For the real (imaginary) part of the NAM, check if the 
            % eigenvalues are greater (less) than or equal to 0
            gpsd = all(self.g_eigenvalues>=0);
            bnsd = all(self.b_eigenvalues<=0);
        end

        % removes all edges in the edge list matrix that induce any of the
        % nodes in a given set of nodes
        function x = omitNodes(self, omitted_nodes)
            old_edge_count = size(self.edges, 1);

            % Number of edges = number of rows (so preserve the number of columns)
            column_count = size(self.edges, 2);
            new_edges = zeros(0, column_count);
            new_line_codes = zeros(0, 1);
            
            % Used to index the new edge list matrix
            new_edge_index = 1;

            % Check each edge
            for current_edge_index=1:1:old_edge_count
                old_edge_row = self.edges(current_edge_index, :);
                old_line_code = self.line_codes(current_edge_index);

                % Get the pair of nodes induced by the current edge
                old_edge_pair = old_edge_row(:,1:2);
                
                % Set a flag if any of the omitted nodes is induced by the 
                % current edge
                edge_is_omitted = false;
                for omitted_node=omitted_nodes
                    if any(old_edge_pair == omitted_node, 'all')
                        edge_is_omitted = true;
                        break;
                    end
                end

                if edge_is_omitted==false
                    % Use the old rows in the new matrices
                    new_edges = [new_edges; old_edge_row];
                    new_line_codes = [new_line_codes; old_line_code];
    
                    % Only increment the "new" index if the current edge
                    % Isn't omitted.
                    new_edge_index = new_edge_index + 1;
                end
            end
            
            % Update the edges and line codes to reflect the removal of
            % data pertaining to the omitted nodes
            self.edges = new_edges;
            self.line_codes = new_line_codes;
        end
        
        % Construct the NAM from the phase series/shunt admittance
        % matrices, according to procedure outlined in Chapter 2
        function y = buildAdmittanceMatrix(self)
            included_nodes = unique(self.edges);
        
            E = size(self.edges, 1);
            N = size(included_nodes,1);
            
            y = zeros(3*N, 3*N);
        
            for edge_pair_index = 1:1:E % Iterate through the edges. Current edge is denoted (a,b)
                % Get the buses in the current edge pair
                bus_a_id = self.edges(edge_pair_index, 1);
                bus_b_id = self.edges(edge_pair_index, 2);
                bus_a = find(included_nodes==bus_a_id);
                bus_b = find(included_nodes==bus_b_id);

                % Retrieve the correct series impedance and shunt admittance matrices 
                % corresponding to the line code for this line
                line_code = self.line_codes(edge_pair_index, 1);
                
                % Get transmission line / transformer matrix
                length = self.getLineLength(edge_pair_index);
                [series_admittance_ab, series_admittance_ba, shunt_admittance_ab, shunt_admittance_ba] = self.getEdgeAdmittanceMatrices(line_code, length);
                
                % Get indices for indexing the submatrices in the network admittance matrix
                % that correspond to the current line
                row_lower = (bus_a * 3) - 2;
                row_upper = bus_a * 3;
                col_lower = (bus_b * 3) - 2;
                col_upper = bus_b * 3;
            
                % Fill off-diagonal entries of network admittance matrix
                y(row_lower:row_upper, col_lower:col_upper) = -series_admittance_ab; % "a" as row index
                y(col_lower:col_upper, row_lower:row_upper) = -series_admittance_ba; % "b" as row index
            
                % Fill diagonal entries of network admittance matrix
                for bus_in_edge=[bus_a bus_b] % each iteration of the for loop corresponds to a different diagonal entry
                    % Get indices for indexing the submatrix in network admittance matrix
                    % that corresponds to the current bus
                    row_lower = (bus_in_edge * 3) - 2;
                    row_upper = bus_in_edge * 3;
                    col_lower = (bus_in_edge * 3) - 2;
                    col_upper = bus_in_edge * 3;
                    
                    % Row index of diagonal entry is held constant in sum;
                    % a given sum is over all possible values of the column
                    % index
                    if bus_in_edge == bus_a
                        shunt_admittance = shunt_admittance_ab;
                        series_admittance = series_admittance_ab;
                    else
                        shunt_admittance = shunt_admittance_ba;
                        series_admittance = series_admittance_ba;
                    end

                    y(row_lower:row_upper, col_lower:col_upper) = y(row_lower:row_upper, col_lower:col_upper) + series_admittance + shunt_admittance;
                end
            end

            self.y = y;
        end
        
        % Returns the line length of a given edge in the network
        function l = getLineLength(self, edge_index)
            l = self.edges(edge_index, self.length_index);
        end

        % Returns the phase series admittance matrices, and the shunt
        % admittance matrices, for a given edge with a given length.
        % For transformers, length may be given as 0.
        function [y_s_ab, y_s_ba, y_m_ab, y_m_ba] = getEdgeAdmittanceMatrices(self, line_code, length)
            if ~isnan(str2double(line_code)) % transmission/distribution lines are expected to be identified by numbers
                [y_s_ab, y_s_ba, y_m_ab, y_m_ba] = self.getLineAdmittanceMatrices(line_code, length);
            else % transformers are expected to be identified by strings
                [y_s_ab, y_s_ba, y_m_ab, y_m_ba] = self.getTransformerAdmittanceMatrices(line_code);
            end
        end

        % Returns the phase series admittance matrices, and the shunt
        % admittance matrices, for a given transmission line with a given length.
        function [y_s_ab, y_s_ba, y_m_ab, y_m_ba] = getLineAdmittanceMatrices(self, line_code, length)
            % Set default values for inverted impedance
            % matrices
            y_s_ab = zeros(3, 3);
            y_s_ba = zeros(3, 3);

            % Get series impedance and shunt admittance matrices
            [z_s_ab, z_s_ba, y_m_ab, y_m_ba] = self.getScaledLineParameterMatrices(line_code, length);

            % Compute the series admittance matrices for the current edge

            if rank(z_s_ab) == 3
                y_s_ab = inv(z_s_ab);
            else
                % Handle conversion of series impedance matrices for
                % single or two-phased lines
                y_s_ab(z_s_ab ~= 0) = 1 ./ z_s_ab(z_s_ab ~= 0);
            end

            if rank(z_s_ba) == 3
                y_s_ba = inv(z_s_ba);
            else
                % Handle conversion of series impedance matrices for
                % single or two-phased lines
                y_s_ba(z_s_ba ~= 0) = 1 ./ z_s_ba(z_s_ba ~= 0);
            end
        end

        % Retrieve series impedance and shunt admittance matrices for a 
        % transmission line with a given length, based on its line code
        function [z_s_ab, z_s_ba, y_m_ab, y_m_ba] = getScaledLineParameterMatrices(self, line_code, length)
            % get the per unit length series impedance and shunt admittance
            % matrices associated with the given line code
            [z_s_ab, z_s_ba, y_m_ab, y_m_ba] = self.getLineParameterMatrices(line_code);

            % scale matrices according to given line length
            z_s_ab = z_s_ab .* length;
            z_s_ba = z_s_ba .* length;
            y_m_ab = y_m_ab .* length;
            y_m_ba = y_m_ba .* length;
        end

        % Retrieve (per unit length) series impedance and shunt admittance 
        % matrices for some transmission line based on its line code
        function [z_s_ab, z_s_ba, y_m_ab, y_m_ba] = getLineParameterMatrices(self, line_code)
            % Set to 0 by default, should be specified differently in
            % inheriting classes
            z_s_ab = zeros(3, 3);
            z_s_ba = zeros(3, 3);
            y_m_ab = zeros(3, 3);
            y_m_ba = zeros(3, 3);
        end

        % Returns the phase series admittance matrices, and the shunt
        % admittance matrices, for some transformer, based on its line code
        function [y_s_ab, y_s_ba, y_m_ab, y_m_ba] = getTransformerAdmittanceMatrices(self, transformer_code)
            row_index = find(table2array(self.transformer_codes(:,1)) == transformer_code);

            power = table2array(self.transformer_codes(row_index,2)); % Rated primary side three-phase power magnitude
            
            % rated primary side line-to-line voltage
            primary_voltage = split(table2array(self.transformer_codes(row_index,3))); 

            % String which indicates the configuration of the corresponding side of the transformer
            primary_configuration = primary_voltage(2); 

            primary_voltage = str2double(primary_voltage(1));

            % rated secondary side line-to-line voltage magnitude
            secondary_voltage = split(table2array(self.transformer_codes(row_index,4))); 

            % String which indicates the configuration of the corresponding side of the transformer
            secondary_configuration = secondary_voltage(2); 

            secondary_voltage = str2double(secondary_voltage(1));

            % Percentage of voltage-current ratio that gives the transformer's primary-side series resistance
            percent_resistance = table2array(self.transformer_codes(row_index,5)); 

            % Percentage of voltage-current ratio that gives the transformer's primary-side series reactance
            percent_reactance = table2array(self.transformer_codes(row_index,6)); 

            voltage_current_ratio = (primary_voltage.^2) ./ power;
            resistance = voltage_current_ratio * (percent_resistance ./ 100); % Primary-side series resistance
            reactance = voltage_current_ratio * (percent_reactance ./ 100); % Primary-side series reactance
            series_impedance = resistance + (reactance * 1i); % Primary-side series impedance for a single phase of the transformer
            series_admittance = 1 ./ series_impedance;

            turn_ratio = primary_voltage ./ secondary_voltage; % Turn ratio for primary and secondary-side transformer windings
            a = 1 ./ turn_ratio;

            y_s_ab_parameter = a * series_admittance; % Primary side series admittance
            y_s_ba_parameter = a * series_admittance; % Secondary side series admittance
            y_m_ab_parameter = (1 - a) * series_admittance; % Primary side shunt admittance
            y_m_ba_parameter = series_admittance * (-a) * (1 + a); % Secondary side shunt admittance
            
            % transformer properties should be the same for each phase
            y_s_ab = eye(3) .* y_s_ab_parameter;
            y_s_ba = eye(3) .* y_s_ba_parameter;
            y_m_ab = eye(3) .* y_m_ab_parameter;
            y_m_ba = eye(3) .* y_m_ba_parameter;

            % If the primary/secondary side is in the delta configuration,
            % then the original phase admittance matrix needs to be right multiplied
            % by the conversion matrix so that the new phase admittance
            % matrix can map line-to-neutral voltages to nodal injection
            % currents.

            if primary_configuration == "D"
                y_s_ab = y_s_ab * self.conversion_matrix;
                y_m_ab = y_m_ab * self.conversion_matrix;
            end

            if secondary_configuration == "D"
                y_s_ba = y_s_ba * self.conversion_matrix;
                y_m_ba = y_m_ba * self.conversion_matrix;
            end
        end
    end
end