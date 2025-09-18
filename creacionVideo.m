% Crea un video a partir de las imágenes PNG en imageFolder
% Superpone el número de iteraciones en cada frame
% imageFolder: carpeta con los PNG (ej. slice52_iterXXX.png)
% outputVideo: ruta del archivo de salida (ej. 'video.mp4')
outputVideo = '/Users/yi/BarridoCalidad/JULIA_Barrido_C1';
imageFolder = '/Users/yi/BarridoCalidad/JULIA_Barrido_C1';

% Buscar imágenes en la carpeta
imgFiles = dir(fullfile(imageFolder, 'slice52_iter*.png'));
    
if isempty(imgFiles)
    error('No se encontraron imágenes PNG en la carpeta especificada.');
end

% Extraer número de iteraciones del nombre de archivo
iter = zeros(length(imgFiles),1);
for i = 1:length(imgFiles)
    tokens = regexp(imgFiles(i).name, 'iter(\d+)', 'tokens');
    if ~isempty(tokens)
        iter(i) = str2double(tokens{1}{1});
    else
        iter(i) = NaN;
    end
end

% Ordenar por iteración
[~, idx] = sort(iter);
imgFiles = imgFiles(idx);
iter = iter(idx);

% Crear objeto de video
v = VideoWriter(outputVideo, 'MPEG-4');
v.FrameRate = 5; % frames por segundo
open(v);

% Escribir imágenes en el vídeo
for i = 1:length(imgFiles)
    imgPath = fullfile(imageFolder, imgFiles(i).name);
    img = imread(imgPath);

    % Superponer texto con el número de iteraciones
    label = sprintf('Iteración: %d', iter(i));
    imgLabeled = insertText(img, [10,10], label, ...
        'FontSize', 20, ...
        'BoxColor', 'black', ...
        'TextColor', 'white', ...
        'BoxOpacity', 0.6);

    % Escribir frame en el vídeo
    writeVideo(v, imgLabeled);
end

close(v);
fprintf('Vídeo creado correctamente en: %s\n', outputVideo);