x_center = round(size(psf1,1)/2);  % plano central en X
yz_slice = squeeze(psf1(x_center,:,:));

% Supón que yz_slice ya es tu corte YZ (Nx × Nz)
% Recorta el centro: 40×40 píxeles

centerY = round(size(yz_slice, 1)/2);
centerZ = round(size(yz_slice, 2)/2);
range = 30;  % tamaño de recorte desde el centro

zoomed = yz_slice(centerY-range:centerY+range, centerZ-range:centerZ+range);

imagesc(zoomed);
axis image;
colormap turbo;
title('Zoom en la PSF (YZ)');
xlabel('Y'); ylabel('Z');
colorbar;
caxis([0 max(yz_slice(:)) * 0.1]);  % Ajusta contraste para ver detalles
