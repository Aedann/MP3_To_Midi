#include <stdio.h>

int main() {
    FILE *inputFile, *outputFile;
    double col1, col2, col3;

    // Ouvrir le fichier d'entrée en mode lecture
    inputFile = fopen("resultat.txt", "r");
    if (inputFile == NULL) {
        printf("Erreur lors de l'ouverture du fichier d'entrée.\n");
        return 1;
    }

    // Ouvrir le fichier de sortie en mode écriture
    outputFile = fopen("resultat2.txt", "w");
    if (outputFile == NULL) {
        printf("Erreur lors de l'ouverture du fichier de sortie.\n");
        fclose(inputFile);
        return 1;
    }

    // Lire les données du fichier d'entrée, effectuer la multiplication et écrire dans le fichier de sortie
    while (fscanf(inputFile, "%lf %lf %lf", &col1, &col2, &col3) == 3) {
        col2 *= 10000;
        int col2Int = (int)col2;
        fprintf(outputFile, "%.0lf\t%d\t%.6lf\n", col1, col2Int, col3);
    }

    // Fermer les fichiers
    fclose(inputFile);
    fclose(outputFile);

    printf("Le fichier resultat2.txt a été créé avec succès.\n");

    return 0;
}
