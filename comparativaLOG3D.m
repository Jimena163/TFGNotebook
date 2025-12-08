% ==============================================================
% Comparativa 3D Richardson–Lucy - Julia vs MATLAB
% Un gráfico por imagen (Tradicional y WB)
% ==============================================================

implementaciones = { ...
    'Python - SimpleITK', ...
    'Julia - DeconvOptim (adapt)', ...
    'MATLAB - DL2'};

% --------------------------------------------------------------
% Tiempos de ejecución 3D (segundos)
% --------------------------------------------------------------

% Imagen sintética
tiempos_sintetica = [16.9, 0.048, 4.65];

% Imagen células
tiempos_celulas = [9.76, 0.573, 6.61];

% Cube of Spherical Beads
tiempos_cube = [143, 0.643, 36.18];


% --------------------------------------------------------------
% Paleta de colores (estilo académico)
% --------------------------------------------------------------
colores = lines(length(implementaciones));

% --------------------------------------------------------------
% Función auxiliar para crear gráficos
% --------------------------------------------------------------
function crearGraficoLog3D_individual(tiempos, implementaciones, titulo, nombreFichero, colores)
    figure('Color','w','Position',[100 100 800 400]);
    b = bar(tiempos, 'FaceColor','flat');

    % Aplicar colores a cada barra
    for k = 1:length(tiempos)
        b.CData(k,:) = colores(k,:);
    end

    % Escala logarítmica
    set(gca, 'YScale', 'log');
    y_min = min(tiempos) * 0.8;
    if y_min < 1e-3, y_min = 1e-3; end
    y_max = max(tiempos) * 1.4;
    ylim([y_min, y_max]);

    % Etiquetas
    set(gca, 'XTickLabel', implementaciones, 'XTickLabelRotation', 25, ...
        'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('Tiempo de ejecución (s)', 'FontSize', 13, 'FontWeight','bold');
    title(titulo, 'FontSize', 14, 'FontWeight','bold');

    grid on; box on;
    exportgraphics(gca, nombreFichero, 'Resolution', 300);
end

% --------------------------------------------------------------
% Crear los 4 gráficos (uno por volumen)
% --------------------------------------------------------------
crearGraficoLog3D_individual(tiempos_sintetica, implementaciones, ...
    'Comparativa 3D – Imagen sintética', 'comparativa3d_sintetica.png', colores);

crearGraficoLog3D_individual(tiempos_celulas, implementaciones, ...
    'Comparativa 3D – Imagen células', 'comparativa3d_celulas.png', colores);

crearGraficoLog3D_individual(tiempos_cube, implementaciones, ...
    'Comparativa 3D – Cube of Spherical Beads', 'comparativa3d_cube.png', colores);
