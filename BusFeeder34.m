classdef BusFeeder34 < SignDefiniteComputer
    methods
        % Constructor
        function self = BusFeeder34(edges, line_codes, transformer_codes)
            self@SignDefiniteComputer(edges, line_codes, 3, transformer_codes)
        end

        function [z_s_ab, z_s_ba, y_m_ab, y_m_ba] = getLineParameterMatrices(self, line_code)
            % Series impedance and shunt admittance matrices directly copied from
            % original IEEE test feeder documentation.
            % Series impedance matrix is denoted line_###_z
            % Shunt admittance matrix is denoted line_###_b
            
            line_300_z = [1.3368+1.3343i, 0.2101+0.5779i, 0.2130+0.5015i;
                           0.2101+0.5779i, 1.3238+1.3569i, 0.2066+0.4591i;
                           0.2130+0.5015i 0.2066+0.4591i 1.3294+1.3471i];
            
            line_300_b = [5.3350 -1.5313 -0.9943;
                          -1.5313 5.0979 -0.6212;
                          -0.9943 -0.6212 4.8880];
            
            
            line_301_z = [1.9300+1.4115i, 0.2327+0.6442i, 0.2359+0.5691i;
                          0.2327+0.6442i, 1.9157+1.4281i, 0.2288+0.5238i;
                          0.2359+0.5691i, 0.2288+0.5238i, 1.9219+1.4209i];
            
            line_301_b = [5.1207 -1.4364 -0.9402;
                          -1.4364 4.9055 -0.5951;
                          -0.9402 -0.5951 4.7154];
            
            
            line_302_z = [2.7995+1.4855i, 0+0i, 0+0i;
                          0+0i, 0+0i, 0+0i;
                          0+0i, 0+0i, 0+0i];
            
            line_302_b = [4.2251 0 0;
                           0 0 0;
                           0 0 0];
            
            
            line_303_z = [0+0i, 0+0i, 0+0i;
                          0+0i, 2.7995+1.4855i, 0+0i;
                          0+0i, 0+0i, 0+0i];
            
            line_303_b = [0 0 0;
                           0 4.2251 0;
                           0 0 0];
            
            
            line_304_z = [0+0i, 0+0i, 0+0i;
                          0+0i, 1.9217+1.4212i, 0+0i;
                          0+0i, 0+0i, 0+0i];
            
            line_304_b = [0 0 0;
                           0 4.3637 0;
                           0 0 0];
            
            % Return the series impedance and shunt admittance matrices
            % associated with the given line code
            switch line_code
                case '300'
                    z_s_ab = line_300_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_300_b;
                    y_m_ba = y_m_ab;
                case '301'
                    z_s_ab = line_301_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_301_b;
                    y_m_ba = y_m_ab;
                case '302'
                    z_s_ab = line_302_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_302_b;
                    y_m_ba = y_m_ab;
                case '303'
                    z_s_ab = line_303_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_303_b;
                    y_m_ba = y_m_ab;
                case '304'
                    z_s_ab = line_304_z;
                    z_s_ba = z_s_ab;

                    y_m_ab = line_304_b;
                    y_m_ba = y_m_ab;
                otherwise
                    z_s_ab = zeros(3, 3);
                    z_s_ba = zeros(3, 3);

                    y_m_ab = zeros(3, 3);
                    y_m_ba = zeros(3, 3);
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