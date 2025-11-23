% ==============================================================
% Comparativa 3D Richardson–Lucy - Julia vs MATLAB vs Python
% Un gráfico por imagen
% ==============================================================

implementaciones = { ...
    'Python', ...
    'Julia - Tradicional', ...
    'MATLAB', ...
};

% --------------------------------------------------------------
% Tiempos de ejecución 3D (segundos) extraídos de tus tablas
% --------------------------------------------------------------

% Imagen sintética (simple_3d_ball)
tiempos_sintetica = [16.9, 0.048, 4.65];

% Imagen células (cells3d)
tiempos_celulas = [9.76, 0.573, 6.61];

% Cube of Spherical Beads
tiempos_cube = [143.0, 0.643, 36.18];

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
    y_max = max(tiempos) * 1.4;
    ylim([1e-2, y_max]);  % límite inferior fijo en 10^-2

    % Etiquetas
    set(gca, 'XTickLabel', implementaciones, 'XTickLabelRotation', 25, ...
        'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('Tiempo de ejecución (s)', 'FontSize', 13, 'FontWeight','bold');
    title(titulo, 'FontSize', 14, 'FontWeight','bold');

    grid on; box on;
    exportgraphics(gca, nombreFichero, 'Resolution', 300);
end


% --------------------------------------------------------------
% Crear los 3 gráficos (uno por volumen)
% --------------------------------------------------------------
crearGraficoLog3D_individual(tiempos_sintetica, implementaciones, ...
    'Comparativa 3D – Imagen sintética (escala log)', 'comparativa3d_sintetica.png', colores);

crearGraficoLog3D_individual(tiempos_celulas, implementaciones, ...
    'Comparativa 3D – Imagen células (escala log)', 'comparativa3d_celulas.png', colores);

crearGraficoLog3D_individual(tiempos_cube, implementaciones, ...
    'Comparativa 3D – Cube of Spherical Beads (escala log)', 'comparativa3d_cube.png', colores);
