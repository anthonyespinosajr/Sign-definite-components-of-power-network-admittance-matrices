classdef EuropeanLVTF < SequenceSignDefiniteComputer
    properties
        
    end
    methods
        % Constructor
        function self = EuropeanLVTF(edges, line_codes, sequence_data, sequence_codes)
            self@SequenceSignDefiniteComputer(edges, line_codes, 3, [], sequence_data, sequence_codes);

            % Store data for the sequence parameters corresponding to each
            % line
            self.sequence_data = sequence_data;
            self.sequence_codes = sequence_codes;
            
            % Initialize the symmetrical components transformation matrix
            % and its inverse
            self.sctm = [1 1 1; 1 (self.a).^2 self.a; 1 self.a (self.a).^2];
            self.sctm_inv = inv(self.sctm);
        end

        function [y_s_ab, y_s_ba, y_m_ab, y_m_ba] = getEdgeAdmittanceMatrices(self, line_code, length)
            [y_s_ab, y_s_ba, y_m_ab, y_m_ba] = self.getLineAdmittanceMatrices(line_code, length);
        end
    end
end