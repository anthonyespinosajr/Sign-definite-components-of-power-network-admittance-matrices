classdef SequenceSignDefiniteComputer < SignDefiniteComputer
    properties
        % column 1-2: positive/negative sequence series impedance (R,X)
        % column 3-4: zero sequence series impedance (R,X)
        % column 5: positive/negative sequence shunt susceptance
        % column 6: zero sequence shunt susceptance
        sequence_data;
        sequence_codes;

        % Three-phase factor
        a = exp(1i*((2 * pi) / 3));

        % Symmetrical components transformation matrix
        sctm;

        sctm_inv;
    end
    methods
        % Constructor
        function self = SequenceSignDefiniteComputer(edges, line_codes, length_index, transformer_codes, sequence_data, sequence_codes)
            self@SignDefiniteComputer(edges, line_codes, length_index, transformer_codes);

            self.sequence_data = sequence_data;
            self.sequence_codes = sequence_codes;
            
            % Initialize the symmetrical components transformation matrix
            % and its inverse
            self.sctm = [1 1 1; 1 (self.a).^2 self.a; 1 self.a (self.a).^2];
            self.sctm_inv = inv(self.sctm);
        end

        % Returns the sequence parameters specifying the series impedance
        % matrices of a transmission line with a given line code
        function seq_vector = getSequenceSeriesParameters(self, line_code)
            line_index = find(self.sequence_codes == line_code);
            
            seq_vector = zeros(1,3);
            
            % Extract vector of sequence parameters by indexing sequence
            % parameter data with the given line code
            seq_vector(1) = self.sequence_data(line_index,3) + (1i*self.sequence_data(line_index, 4));
            seq_vector(2) = self.sequence_data(line_index,1) + (1i*self.sequence_data(line_index, 2));
            seq_vector(3) = seq_vector(2);
        end

        % Returns the sequence parameters specifying the shunt admittance
        % matrices of a transmission line with a given line code
        function seq_vector = getSequenceShuntParameters(self, line_code)
            sequence_index = find(self.sequence_codes == line_code);

            seq_vector = zeros(1,3);

            % Extract vector of sequence parameters by indexing sequence
            % parameter data with the given line code
            seq_vector(1) = self.sequence_data(sequence_index,6);
            seq_vector(2) = self.sequence_data(sequence_index,5);
            seq_vector(3) = seq_vector(2);
        end

        % Computes the series impedance matrix specified by some given
        % vector of sequence parameters, and returns them
        function z_seq = getSequenceSeriesImpedance(self, seq_vector)
            % Format of sequence vector: [zero positive negative]
            
            z_seq = diag(seq_vector);
        end

        % Computes the series impedance and shunt admittance phase
        % matrices, normalized by line length, and returns them.
        function [z_s_ab, z_s_ba, y_m_ab, y_m_ba] = getLineParameterMatrices(self, line_code)
            seq_vector = self.getSequenceSeriesParameters(line_code);
            z_seq = self.getSequenceSeriesImpedance(seq_vector);

            % Convert sequence variables to phase variables
            z_s_ab = (self.sctm_inv * z_seq) * self.sctm;
            z_s_ba = z_s_ab;

            % The shunt admittances for all of the line codes is given to be zero
            y_m_ab = zeros(3,3);
            y_m_ba = y_m_ab;
        end
    end
end