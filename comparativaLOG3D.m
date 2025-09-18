% ==============================================================
% Comparativa 3D Richardson-Lucy - MATLAB
% Gráficos de barras con estilo académico
% Escala logarítmica para mejor visualización
% ==============================================================

% Datos de la tabla (medianas) para 3D
implementaciones = { ...
    'Python - SimpleITK', ...
    'Julia - DeconvOptim (sin reg.)', ...
    'Julia - DeconvOptim (TV)', ...
    'MATLAB - DL2'};

% Tiempos de ejecución 3D (segundos)
tiempos_sintetica = [16.9, 0.048, 0.087, 4.65];
tiempos_celulas   = [9.76, 0.573, 6.61];   % Repetimos TV de Julia si se quiere comparar
tiempos_cube      = [143, 0.643, 36.18];   % Repetimos TV de Julia para visibilidad

% Paleta de colores (más académica)
colores = lines(length(implementaciones));

% --------------------------------------------------------------
% Función auxiliar para gráficos
% --------------------------------------------------------------
function crearGraficoLog(tiempos, implementaciones, titulo, nombreFichero, colores)
    figure('Color','w','Position',[100 100 800 400]); % Fondo blanco, tamaño adecuado
    b = bar(tiempos, 'FaceColor','flat');

    for k = 1:length(tiempos)
        b.CData(k,:) = colores(k,:); % aplicar paleta
    end

    % Etiquetas del eje X
    set(gca, 'XTickLabel', implementaciones, 'XTickLabelRotation', 30, ...
        'FontSize', 12, 'FontName','Times New Roman');

    % Eje Y
    ylabel('Tiempo de ejecución (s)', 'FontSize', 13, 'FontWeight','bold');
    title(titulo, 'FontSize', 14, 'FontWeight','bold');

    % Líneas de cuadrícula
    grid on; box on;

    % Escala logarítmica para mejor visualización
    set(gca, 'YScale', 'log');
    
    % Ajuste de límites para mejor visibilidad
    ylim([0.01, max(tiempos)*1.2]);

    % Guardar en alta calidad
    exportgraphics(gca, nombreFichero, 'Resolution', 300);
end

% --------------------------------------------------------------
% Gráficos (logarítmicos)
% --------------------------------------------------------------

% Imagen sintética
crearGraficoLog(tiempos_sintetica, implementaciones, ...
    'Comparativa 3D - Imagen sintética (escala log)', 'comparativa_sintetica_3d_log.png', colores);

% Imagen células
crearGraficoLog(tiempos_celulas, implementaciones, ...
    'Comparativa 3D - Imagen células (escala log)', 'comparativa_celulas_3d_log.png', colores);

% Cube of Spherical Beads
crearGraficoLog(tiempos_cube, implementaciones, ...
    'Comparativa 3D - Cube of Spherical Beads (escala log)', 'comparativa_cube_3d_log.png', colores);
