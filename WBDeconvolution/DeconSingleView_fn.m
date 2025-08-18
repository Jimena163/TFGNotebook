% Cargar imagen de célula
cell_img = im2double(imread('cell.tif'));

% Generar PSF gaussiana
psf = fspecial('gaussian', [9 9], 2);

% Simular imagen desenfocada + ruido
blurred = imfilter(cell_img, psf, 'conv', 'same');
noisy = imnoise(blurred, 'gaussian', 0, 0.0008);

% Deconvolución Richardson–Lucy con 10 iteraciones
deconv_rl = deconvlucy(noisy, psf, 10);

% Mostrar esquema visual
figure;
set(gcf, 'Position', [100, 100, 1200, 400]);

subplot(1,3,1);
imshow(noisy, []); title('i(x): Imagen observada');

subplot(1,3,2);
imshow(psf, []); title('h(x): PSF');

subplot(1,3,3);
imshow(deconv_rl, []); title('o(x): Imagen restaurada (Richardson-Lucy)');

% Guardar imagen para incluir en documento
exportgraphics(gcf, 'esquema_deconvolucion_rl.png', 'Resolution', 300);
