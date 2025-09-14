% ==============================================================
% Comparativa 2D Richardson-Lucy - MATLAB
% Gráficos de barras con estilo académico
% ==============================================================

% Datos de la tabla (medianas)
implementaciones = { ...
    'Python - SimpleITK', ...
    'Python - Scikit-image', ...
    'Julia - DeconvOptim (orig)', ...
    'Julia - DeconvOptim (adapt)', ...
    'Julia - DeconvOptim (TV)', ...
    'MATLAB - DL2'};

tiempos_sintetica = [6.37, 0.478, 0.059, 0.060, 0.077, 2.576];
tiempos_celulas   = [1.46, 0.090, 0.015, 0.016, 0.020, 0.835];

% Paleta de colores (más académica)
colores = lines(length(implementaciones));

% --------------------------------------------------------------
% Función auxiliar para gráficos
% --------------------------------------------------------------
function crearGrafico(tiempos, implementaciones, titulo, nombreFichero, colores, usarLog)
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

    % Escala logarítmica si se pide
    if usarLog
        set(gca, 'YScale', 'log');
    end

    % Guardar en alta calidad
    exportgraphics(gca, nombreFichero, 'Resolution', 300);
end

% --------------------------------------------------------------
% Gráficos (lineales y logarítmicos)
% --------------------------------------------------------------

% Imagen sintética
crearGrafico(tiempos_sintetica, implementaciones, ...
    'Comparativa 2D - Imagen sintética', 'comparativa_sintetica.png', colores, false);

crearGrafico(tiempos_sintetica, implementaciones, ...
    'Comparativa 2D - Imagen sintética (escala log)', 'comparativa_sintetica_log.png', colores, true);

% Imagen células
crearGrafico(tiempos_celulas, implementaciones, ...
    'Comparativa 2D - Imagen células', 'comparativa_celulas.png', colores, false);

crearGrafico(tiempos_celulas, implementaciones, ...
    'Comparativa 2D - Imagen células (escala log)', 'comparativa_celulas_log.png', colores, true);
