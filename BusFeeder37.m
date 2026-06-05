classdef BusFeeder37 < SignDefiniteComputer
    methods
        % Constructor
        function self = BusFeeder37(edges, line_codes, transformer_codes)
            self@SignDefiniteComputer(edges, line_codes, 3, transformer_codes)
        end

        function [z_s_ab, z_s_ba, y_m_ab, y_m_ba] = getLineParameterMatrices(self, line_code)
            % Series impedance and shunt admittance matrices directly copied from
            % original IEEE test feeder documentation.
            % Series impedance matrix is denoted line_###_z
            % Shunt admittance matrix is denoted line_###_b
            
            line_721_z = [0.2926+0.1973i, 0.0673-0.0368i, 0.0337-0.0417i;
                          0.0673-0.0368i, 0.2646+0.1900i, 0.0673-0.0368i;
                          0.0337-0.0417i, 0.0673-0.0368i, 0.2926+0.1973i];
            
            line_721_b = [159.7919 0 0;
                          0 159.7919 0;
                          0 0 159.7919];
            
            
            line_722_z = [0.4751+0.2973i, 0.1629-0.0326i, 0.1234-0.0607i;
                          0.1629-0.0326i, 0.4488+0.2678i, 0.1629-0.0326i;
                          0.1234-0.0607i, 0.1629-0.0326i, 0.4751+0.2973i];
            
            line_722_b = [127.8306 0 0;
                          0 127.8306 0;
                          0 0 127.8306];
            
            
            line_723_z = [1.2936+0.6713i, 0.4871+0.2111i, 0.4585+0.1521i;
                          0.4871+0.2111i, 1.3022+0.6326i, 0.4871+0.2111i;
                          0.4585+0.1521i, 0.4871+0.2111i, 1.2936+0.6713i];
            
            line_723_b = [74.8405 0 0;
                          0 74.8405 0;
                          0 0 74.8405];
            
            
            line_724_z = [2.0952+0.7758i, 0.5204+0.2738i, 0.4926+0.2123i;
                          0.5204+0.2738i, 2.1068+0.7398i, 0.5204+0.2738i;
                          0.4926+0.2123i, 0.5204+0.2738i, 2.0952+0.7758i];
            
            line_724_b = [60.2483 0 0;
                          0 60.2483 0;
                          0 0 60.2483];
            
            % Return the series impedance and shunt admittance matrices
            % associated with the given line code
            switch line_code
                case '721'
                    z_s_ab = line_721_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_721_b;
                    y_m_ba = y_m_ab;
                case '722'
                    z_s_ab = line_722_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_722_b;
                    y_m_ba = y_m_ab;
                case '723'
                    z_s_ab = line_723_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_723_b;
                    y_m_ba = y_m_ab;
                case '724'
                    z_s_ab = line_724_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_724_b;
                    y_m_ba = y_m_ab;
                otherwise
                    z_s_ab = zeros(3,3);
                    z_s_ba = z_s_ab;

                    y_m_ab = zeros(3,3);
                    y_m_ba = y_m_ab;
            end

            % Original matrix entries are given in ohms per mile,
            % but multiplied line lengths are given in feet
            z_s_ab = z_s_ab ./ 5280;
            z_s_ba = z_s_ba ./ 5280;
            y_m_ab = y_m_ab ./ 5280;
            y_m_ba = y_m_ba ./ 5280;
        end
    end
end