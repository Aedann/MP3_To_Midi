%Pour établir le temps de calcul : 
tic
% Lire le fichier audio
[y0, Fs] = audioread("./harry.wav");
y = y0(:,1);%Suppression de la voie de droite qui comporte du bruit très faible.


%Ré-échantillonage : 

% Appliquer un filtre anti-repliement de fréquence
facteur_decim = 4;
fc = Fs/facteur_decim;
tic
%[b, a] = butter(8, fc / (Fs / 2), "low");
F = fc/(Fs/2);
[b, a] = firpm(36, [F/3 2*F/3 F 4*F/3 5*F/3 2*F], [1 1 1 0 0 0]);
toc
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

i=50;    %Trame etudiée.
    
% Extraire 4 trames à partir de la i-ème trame
buffer = frames(:, i:i+bufferSize-1); 
% = Tableau de frames de taille controlée.
buffer = buffer(:); % Vecteur colones de frames.
TailleBuffer = length(buffer);

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
threshold = 40.000;
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


amdf = zeros(1, f0_max-f0_min+1); %Initialisation de l'AMDF
f2 = 0:fc/nfft:fc-1;

for j=f0_min:f0_max 
    tau = round(j*nfft/fc);

    s1 = abs(buffer_thresholded(1:end));
    s2 = [ threshold*ones(length(f2)-length(abs(buffer_thresholded(1:end-tau))), 1); abs(buffer_thresholded(1:end-tau))];
    amdf(j-f0_min+1) = sum(abs(s1-s2));
    j;
end

% Recherche de la fréquence fondamentale correspondant à la valeur minimale de la fonction AMDF
[min_amdf, indice_min_amdf] = min(amdf);

pitch = indice_min_amdf + f0_min
pitch2 = convertirPitchEnNote(pitch)
notes(i)=pitch2;


tau = pitch*nfft/fc;
s2 = [ threshold*ones(length(f2)-length(abs(buffer_thresholded(1:end-tau))), 1); abs(buffer_thresholded(1:end-tau))];

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


    [Nb,p]=size(y);
    Nb=1024;
    zf=zeros(Nb,1) ;
    nf=2^6 ; % Nombre de fenetres 1024 échantillons 
    lf=round(Nb/nf) ; % Longueur des fen^etres
    k=0 ;
    r = 2; % comment choisir le facteur de compression ? 
    for f=1 :nf
    zf(k+(1 :lf))=fft(mono_y(k+(1 :lf))) ;
    k=k+lf ;
    end
    zs=sort(abs(zf)) ;
    seuil=zs(round(Nb*(1-1/r))) ;
    zf(abs(zf)<seuil)=0 ;
    k=0 ;
    for f=1 :nf 
    ycf(k+(1 :lf))=ifft(zf(k+(1 :lf))) ;
    k=k+lf ;
    end
