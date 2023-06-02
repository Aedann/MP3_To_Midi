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
% xlim([0 Fs/2]);pkf
% xlabel('Fréquence (s)');
% ylabel('Amplitude');
% title(sprintf('Trame %d', frameNum));

% Lire le fichier audio
[y0, Fs] = audioread("./harry.wav");
y = y0(:,1);%Suppression de la voie de droite qui comporte du bruit très faible.


%Ré-échantillonage : 

% Appliquer un filtre anti-repliement de fréquence
facteur_decim = 4;
fc = Fs/facteur_decim;
[b, a] = butter(8, fc / (Fs / 2), 'low');
yFiltered = filter(b, a, y);

% Décimation par un facteur
yDownsampled = downsample(yFiltered, facteur_decim);


frameDuration = 0.01; %Durée d'une trame en ms.

% Diviser le signal en trames de durée frameDuration.
frameSize = round(frameDuration * Fs / facteur_decim); 
% = Nombre de points d'une frame
numFrames = floor(length(yDownsampled) / frameSize); 
% = Nombre de frames
frames0 = reshape(yDownsampled(1:numFrames*frameSize), frameSize, numFrames);
% = Tableau de frames

% Extraire 4 trames à partir de la startFrame-ème trame
startFrame = 1200;
bufferSize = 4; %Taille d'un tampon
startIndice = (startFrame - 1) * frameSize + 1;
buffer = frames0(:, startFrame:startFrame+bufferSize-1); 
% = Tableau de frames de taille controlée.
buffer = buffer(:); % Vecteur colones de frames.

% Ajouter du zero-padding
paddingFactor = 20; % Proportionnel au nombre de zéros à ajouter
bufferPadded = [buffer; zeros(length(buffer)* paddingFactor, 1)];

% Calculer le spectre des trames avec padding
nfft = length(bufferPadded); %Nombre de points de la FFT
spec = fft(bufferPadded, nfft); 
spec_filtre = spec;%.*hamming(length(spec));

%Application d'un seuil pour enlever le bruit à 0.02
threshold = 0.05;
buffer_thresholded = spec_filtre;
buffer_thresholded(buffer_thresholded < threshold) = threshold;

taille_buff_pad = round(length(bufferPadded)/2);
%f = (-taille_buff_pad:taille_buff_pad) / nfft * Fs / paddingFactor;
%f = 0:length()
bufferPaddedTrimmed = spec(length(spec)/2+1:end);
f = 0:fc/nfft:fc-1;

%Partie AMDF :

% Paramètres
f0_min = 247; % fréquence minimale pour la recherche de pitch = Si 2
f0_max = 1760; % fréquence maximale pour la recherche de pitch = La 5


amdf = zeros(1, f0_max-f0_min+1); %
for j=f0_min:f0_max 
    tau = round(j*nfft/fc);
    f2 = 0:fc/nfft:fc-1;

    s1 = abs(buffer_thresholded(1:end));
    s2 = [ zeros(length(f2)-length(abs(buffer_thresholded(1:end-tau))), 1); abs(buffer_thresholded(1:end-tau))];
    amdf(j-f0_min+1) = sum(abs(s1-s2));
    j;
end
% Recherche de la fréquence fondamentale correspondant à la valeur minimale de la fonction AMDF
[min_amdf, indice_min_amdf] = min(amdf);

pitch = indice_min_amdf + f0_min

tau = pitch*nfft/fc
s2 = [ threshold+zeros(length(f2)-length(abs(buffer_thresholded(1:end-tau))), 1); abs(buffer_thresholded(1:end-tau))];

%Tracé des spectres superposé à la fréquence min d'AMDF
f1 = linspace(f0_min,f0_max,length(amdf));
plot(f1,amdf/200,"color",[0, 0.2, 0.2],"linewidth",2);
hold on;
plot(f2,s1,"color",[0, 0, 0.2],"linewidth",2);
plot(f2,s2,"color",[0, 0.4,0],"linewidth",2);
xlim([0 fc/2]);
xlabel('Fréquence (Hz)');
%xlabel('BufferPadded (s)');
ylabel('Magnitude');
title('AMDF et Spectres superposés ');
