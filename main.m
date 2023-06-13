%Pour établir le temps de calcul : 
tic
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
TailleY = length(yDownsampled)

frameDuration = 0.02; %Durée d'une trame en s.

% Diviser le signal en trames de durée frameDuration.
frameSize = round(frameDuration * Fs / facteur_decim)
% = Nombre de points d'une frame
numFrames = floor(length(yDownsampled) / frameSize)
% = Nombre de frames
frames = reshape(yDownsampled(1:numFrames*frameSize), frameSize, numFrames);
% = Tableau de frames

%DureeAudio = numFrames*frameSize/(Fs/4)
bufferSize = 2; %Taille d'un tampon

notes = zeros(numFrames, 1);%matrice colone de taille frames de zéros
volumes = zeros(numFrames, 1);%matrice colone de taille frames de zéros
durations = frameDuration*ones(numFrames, 1);%matrice colone de taille frames de frameDuration*ones 

for i=1:numFrames-bufferSize
    
    
    % Extraire 4 trames à partir de la i-ème trame
    buffer = frames(:, i:i+bufferSize-1); 
    % = Tableau de frames de taille controlée.
    buffer = buffer(:); % Vecteur colones de frames.
    TailleBuffer = length(buffer);
    
    volumes(i) = round(mean(abs(buffer))*1000);
    volumes(i) = uint8(max(min(volumes(i), 99), 1)); % Ajuste les valeurs entre 1 et 99.

    
    % Ajouter du zero-padding
    paddingFactor = 10; % Proportionnel au nombre de zéros à ajouter
    bufferPadded = [buffer; zeros(length(buffer)* paddingFactor, 1)];

    % Calculer le spectre des trames avec padding
    nfft = length(bufferPadded); %Nombre de points de la FFT
    spec = fft(bufferPadded, nfft);
    %spec_filtre = spec.*blackman(length(spec));
    spec_filtre = spec.*blackman(length(spec));
    TailleSpecFilt = length(spec_filtre);


    %Application d'un seuil pour enlever le bruit à threshold
    threshold = 0.000;
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

    f2 = 0:fc/nfft:fc-1;
    amdf = zeros(1, f0_max-f0_min+1); %
    for j=f0_min:f0_max 
        tau = round(j*nfft/fc);

        s1 = abs(buffer_thresholded(1:end));
        s2 = [ threshold*ones(length(f2)-length(abs(buffer_thresholded(1:end-tau))), 1); abs(buffer_thresholded(1:end-tau))];
        amdf(j-f0_min+1) = sum(abs(s1-s2));
        j;
    end
    % Recherche de la fréquence fondamentale correspondant à la valeur minimale de la fonction AMDF
    [min_amdf, indice_min_amdf] = min(amdf);

    pitch = indice_min_amdf + f0_min;
    pitch2 = convertirPitchEnNote(pitch);
    notes(i)=pitch2;

end

% Enregistrement des résultats dans un fichier texte
fid = fopen('resultat.txt', 'w');
for i = 1:length(notes)
    fprintf(fid, '%d\t%d\t%f\n', notes(i), volumes(i), durations(i));
end
fclose(fid);

detect_new_notes('./resultat.txt');

%fin du calcul :
toc

