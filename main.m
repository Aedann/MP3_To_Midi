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
[y, Fs] = audioread('./harry.mp3');

% Appliquer un filtre anti-repliement de fréquence
fc = 8.8e3;
[b, a] = butter(8, fc / (Fs / 2), 'low');
yFiltered = filter(b, a, y);

% Décimation par un facteur de 5
yDownsampled = downsample(yFiltered, 5);

% Diviser le signal en trames de 10 ms
frameSize = round(0.01 * Fs / 5);
numFrames = floor(length(yDownsampled) / frameSize);
frames = reshape(yDownsampled(1:numFrames*frameSize), frameSize, numFrames);

% Extraire 4 trames à partir de la 50e trame
startFrame = 50;
numTrames = 4;
startIdx = (startFrame - 1) * frameSize + 1;
endIdx = startIdx + numTrames * frameSize - 1;
trames = frames(:, startFrame:startFrame+numTrames-1);
trames = trames(:);

% Ajouter du zero-padding
paddingFactor = 4;
tramesPadded = [trames; zeros(frameSize * paddingFactor - length(trames), 1)];

% Calculer le spectre des trames avec padding
nfft = 1024;
spec = fft(tramesPadded, nfft);
f = (0:nfft-1) / nfft * Fs / paddingFactor;

% Tracer le spectre
figure;
plot(f, abs(spec));
xlim([0 8000]);
xlabel('Fréquence (Hz)');
ylabel('Magnitude');
title('Spectre des 4 trames avec padding');