I = im2double(imread('cameraman.tif'));              % Imagen original
psf = fspecial('gaussian', [9 9], 1.5);          % PSF adecuada

% Simular imagen borrosa + ruido
blurred = imfilter(I, psf, 'conv', 'same');
noisy = imnoise(blurred, 'gaussian', 0, 0.0005);

% Deconvolución de Wiener
K = 0.01;  % Relación ruido/señal
wiener = deconvwnr(noisy, psf, K);

% Deconvolución Richardson–Lucy
rl = deconvlucy(noisy, psf, 10);

% Deconvolución TV (si tienes Image Restoration Toolbox)
tv = deconvreg(noisy, psf);

% Mostrar resultados
% === Figura 1: Imagen original, desenfocada y con ruido ===
figure;
set(gcf, 'Position', [100, 100, 1200, 400]);  % Ancho mayor

subplot(1,3,1), imshow(I), title('Original');
subplot(1,3,2), imshow(blurred), title('Desenfocada');
subplot(1,3,3), imshow(noisy), title('Con ruido');

% === Figura 2: Resultados de restauración ===
figure;
set(gcf, 'Position', [100, 100, 1200, 400]);  % Ancho mayor

subplot(1,3,1), imshow(wiener), title('Wiener (deconvwnr)');
subplot(1,3,2), imshow(rl), title('Richardson-Lucy (deconvlucy)');
subplot(1,3,3), imshow(tv), title('TV (deconvreg)');
