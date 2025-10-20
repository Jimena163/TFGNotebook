% Implementaciones consideradas
implementaciones = { ...
    'Julia - Tradicional', ...
    'MATLAB - Tradicional', ...
    'Julia - Wiener–Butterworth', ...
    'MATLAB - Wiener–Butterworth'};

% --------------------------------------------------------------
% Datos obtenidos de las Tablas wbd2d_traditional y wbd2d_wiener
% (todas con 10 iteraciones)
% --------------------------------------------------------------

% Tiempos en segundos
tiempos_sintetica = [0.02209, 0.604, 0.02213, 0.513];
tiempos_celulas   = [0.00584, 0.154, 0.00581, 0.130];

% ==============================================================
% Comparativa 2D Richardson–Lucy - Julia vs MATLAB
% Gráficos de barras con escala logarítmica y estilo académico
% ==============================================================

implementaciones = { ...
    'Julia - Tradicional', ...
    'MATLAB - Tradicional', ...
    'Julia - Wiener–Butterworth', ...
    'MATLAB - Wiener–Butterworth'};

% Tiempos (s)
tiempos_sintetica = [0.02209, 0.604, 0.02213, 0.513];
tiempos_celulas   = [0.00584, 0.154, 0.00581, 0.130];

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

    % Escala logarítmica
    set(gca, 'YScale', 'log');

    % ---- Ajuste de límites del eje Y ----
    % Límite inferior automático según mínimo de datos
    y_min = min(tiempos) * 0.8;
    if y_min < 1e-3
        y_min = 1e-3; % evita valores demasiado pequeños
    end
    y_max = max(tiempos) * 1.5;
    ylim([y_min, y_max]);

    % Guardar en alta calidad
    exportgraphics(gca, nombreFichero, 'Resolution', 300);
end

% --------------------------------------------------------------
% Gráficos 2D (escala logarítmica)
% --------------------------------------------------------------

% Imagen sintética
crearGraficoLog(tiempos_sintetica, implementaciones, ...
    'Comparativa 2D - Imagen sintética (escala log)', ...
    'comparativa_sintetica_2d_log.png', colores);

% Imagen células
crearGraficoLog(tiempos_celulas, implementaciones, ...
    'Comparativa 2D - Imagen células (escala log)', ...
    'comparativa_celulas_2d_log.png', colores);
