% Supón que yz_slice ya es tu corte YZ (Nx × Nz)
% Recorta el centro: 40×40 píxeles
x_center = round(size(psf2,1)/2);  % plano central en X
yz_slice = squeeze(psf2(x_center,:,:));

imagesc(yz_slice);
axis image;
colormap prism;
title('Zoom en la PSF (YZ)');
xlabel('Y'); ylabel('Z');
colorbar;
caxis([0 max(yz_slice(:)) * 0.3]);  % Ajusta contraste para ver detalles
