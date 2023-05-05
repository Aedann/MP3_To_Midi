% % Lire le fichier mp3
% [y, Fs] = audioread('./harry.mp3');
% 
% % Déterminer la durée d'une trame en échantillons
% frameSize = round(0.04 * Fs);
% 
% % Diviser le signal en trames
% numFrames = floor(length(y) / frameSize);
% frames = reshape(y(1:numFrames * frameSize), frameSize, numFrames);
% 
% f1 = 0:Fs/(frameSize-1):Fs;
% 
% % Déterminer la durée du signal en secondes
% duration = length(y) / Fs;
% 
% % Ajouter 2 secondes de padding zéro
% paddingDuration = 2;
% numPaddingSamples = round(paddingDuration * Fs);
% spectrePadded = padarray(y, [numPaddingSamples, 0], 'post');
% %l'argument 'post' indique que le padding doit être ajouté après le signal
% 
% % Vérifier la nouvelle durée du signal
% durationPadded = length(yPadded) / Fs;
% 
% % Tracez la 50ème trame
% frameNum = 50;
% t = (1:frameSize) / Fs;
% figure;
% spectre = fft(frames(:,frameNum));
% spectre_filtre = 20*log(abs(spectre.*blackman(frameSize)));
% 
% plot(durationPadded,  spectre_filtre);
% xlim([0 Fs/2]);
% xlabel('Fréquence (s)');
% ylabel('Amplitude');
% title(sprintf('Trame %d', frameNum));

% Lire le fichier audio
[y, Fs] = audioread("./harry.mp3");

% Appliquer un filtre anti-repliement de fréquence
fc = 8.8e3;  % fc = 2fe
[b, a] = butter(8, fc / (Fs / 2), 'low');
yFiltered = filter(b, a, y);

% Décimation par un facteur de 5
yDownsampled = downsample(yFiltered, 5);


frameDuration = 0.01; %Durée d'une trame en ms.

% Diviser le signal en trames de durée frameDuration.
frameSize = round(frameDuration * Fs / 5); % Nombre de points d'une frame
numFrames = floor(length(yDownsampled) / frameSize); % Nombre de frames
frames0 = reshape(yDownsampled(1:numFrames*frameSize), frameSize, numFrames);% Tableau de frames

% Extraire 4 trames à partir de la 50e trame
startFrame = 1000;
bufferSize = 4;
startIndice = (startFrame - 1) * frameSize + 1;
buffer = frames0(:, startFrame:startFrame+bufferSize-1); % Tableau de frames de taille controlée.
buffer = buffer(:); % Vecteur colones de frames.

% Ajouter du zero-padding
paddingFactor = 4; % Proportionnel au nombre de zéros à ajouter
bufferPadded = [buffer; zeros(frameSize * paddingFactor - length(buffer), 1)];

% Calculer le spectre des trames avec padding
nfft = 1024;
spec = fft(bufferPadded, nfft);
f = (0:nfft-1) / nfft * Fs / paddingFactor;

% Tracer le spectre
figure;
plot(f, abs(spec));
xlim([0 8000]);
xlabel('Fréquence (Hz)');
ylabel('Magnitude');
title('Spectre des 4 trames avec padding');

%Partie AMDF :

% Paramètres
f0_min = 247; % fréquence minimale pour la recherche de pitch = Si 2
f0_max = 1760; % fréquence maximale pour la recherche de pitch = La 5

amdf = zeros(1, f0_max-f0_min+1);
for j=f0_min:f0_max
	tau = round(Fs/j);
	amdf(j-f0_min+1) = sum(abs(buffer(1:end-tau)-buffer(1+tau:end)));
end
% Recherche de la fréquence fondamentale correspondant à la valeur minimale de la fonction AMDF
[min_amdf, indice_min_amdf] = min(amdf);
pitch = f0_min+indice_min_amdf-1 
f2 = linspace(f0_min+1,f0_max,f0_max-f0_min+1);
length(f2)
length(amdf)
plot(f2, amdf );
