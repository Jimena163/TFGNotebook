% Parámetros de frecuencia
omega = linspace(-pi, pi, 1000);

% Modelo de PSF en frecuencia: gaussiana (desenfoque típico)
sigma = 0.3;
H = exp(-0.5 * (omega / sigma).^2);
H = H / max(H);  % Normalización

% Cálculo del filtro de Wiener para diferentes valores de ruido
K1 = 1e-4;  % Poco ruido
K2 = 1e-2;  % Ruido moderado
K3 = 1e-1;  % Mucho ruido

% Filtros de Wiener
W1 = conj(H) ./ (abs(H).^2 + K1);
W2 = conj(H) ./ (abs(H).^2 + K2);
W3 = conj(H) ./ (abs(H).^2 + K3);

% Definir colores
azul     = [0 0.4470 0.7410];
naranja  = [0.8500 0.3250 0.0980];
verde    = [0.4660 0.6740 0.1880];
grisOscuro = [0.3 0.3 0.3];

% Representación gráfica
figure;

% Escala lineal
subplot(2,1,1);
plot(omega, abs(W1), 'Color', azul, 'LineWidth', 2); hold on;
plot(omega, abs(W2), 'Color', naranja, 'LineWidth', 2);
plot(omega, abs(W3), 'Color', verde, 'LineWidth', 2);
plot(omega, abs(H), '--', 'Color', grisOscuro, 'LineWidth', 1.5);
legend('K = 1e-4','K = 1e-2','K = 1e-1','PSF');
xlabel('\omega (frecuencia)'); ylabel('|Filtro(\omega)|');
title('Filtro de Wiener - Escala lineal');
grid on;
xticks([-pi -pi/2 0 pi/2 pi]);
xticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'});
xlim([-pi pi]);

% Escala logarítmica
subplot(2,1,2);
plot(omega, abs(W1), 'Color', azul, 'LineWidth', 2); hold on;
plot(omega, abs(W2), 'Color', naranja, 'LineWidth', 2);
plot(omega, abs(W3), 'Color', verde, 'LineWidth', 2);
plot(omega, abs(H), '--', 'Color', grisOscuro, 'LineWidth', 1.5);
set(gca, 'YScale', 'log');
legend('K = 1e-4','K = 1e-2','K = 1e-1','PSF');
xlabel('\omega (frecuencia)'); ylabel('|Filtro(\omega)|');
title('Filtro de Wiener - Escala logarítmica');
grid on;
xticks([-pi -pi/2 0 pi/2 pi]);
xticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'});
xlim([-pi pi]);
