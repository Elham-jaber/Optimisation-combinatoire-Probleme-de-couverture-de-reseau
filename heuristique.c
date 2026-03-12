#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#define MAXANTENNES 10
#define MAXPOINTS 1000
typedef struct {
	float portee;
	int cout;
} antenne_t;
int NbAntennes;
antenne_t Antennes[MAXANTENNES];
int NbPoints;
float Distances[MAXPOINTS][MAXPOINTS];
int Visibilite[MAXPOINTS][MAXPOINTS];
void readCouverture(char *filename)
{
	FILE *fp = fopen(filename, "r");// Ouverture du fichier de donnees
	if (!fp) exit(0);
	fscanf(fp, "%d", &NbAntennes);// Lecture du nombre d'antennes
	for (int a=0; a<NbAntennes; a++)// Lecture des portees et couts des antennes
		fscanf(fp, "%f%d", &(Antennes[a].portee),
				   &(Antennes[a].cout));
	fscanf(fp, "%d", &NbPoints); // Lecture du nombre de points
	for (int i=0; i<NbPoints; i++)// Lecture des matrices Distance et Visibilite
		for (int j=0; j<NbPoints; j++)
			fscanf(fp, "%f%d", 
				&(Distances[i][j]),
				&(Visibilite[i][j]));
	fclose(fp);
}
// Heuristique gloutonne : A chaque iteration on choisit l'antenne et la position
// qui maximisent le ratio (nombre de points couverts / cout)
float couvrir(int select[MAXANTENNES][MAXPOINTS])
{
	float cout = 0.0;
	int nonCouverts[MAXPOINTS];
	for (int i = 0; i < NbPoints; i++)	// Tous les points sont non couverts au début
		nonCouverts[i] = 1;
	while (1)
	{
		int reste = 0;
		for (int i = 0; i < NbPoints; i++)// Vérifier s’il reste des points non couverts
			if (nonCouverts[i]) reste = 1;
		if (!reste) break;
		int bestAntenne = -1;
		int bestPoint = -1;
		float bestRatio = -1.0;
		for (int a = 0; a < NbAntennes; a++)// Parcourir toutes les antennes disponibles
		{	
			for (int pa = 0; pa < NbPoints; pa++)// Tester chaque point comme emplacement possible pour une antenne
			{
				int couverts = 0;
				for (int p = 0; p < NbPoints; p++)// Vérifier quels points non couverts peuvent être couverts par cette antenne
				{
					if (nonCouverts[p] &&
						Distances[pa][p] <= Antennes[a].portee &&
						Visibilite[pa][p])
					{
						couverts++;
					}
				}
				if (couverts > 0)// Calculer le rapport couverture/coût
				{
					float ratio = (float)couverts / Antennes[a].cout;
					if (ratio > bestRatio)// Garder la meilleure antenne trouvée
					{
						bestRatio = ratio;
						bestAntenne = a;
						bestPoint = pa;
					}
				}
			}
		}
		if (bestAntenne == -1) break;// Si aucune antenne na ete trouvee, arreter
		select[bestAntenne][bestPoint] = 1;// Sélectionner cette antenne
		cout += Antennes[bestAntenne].cout;
		for (int p = 0; p < NbPoints; p++)// Mettre à jour les points couverts
		{
			if (nonCouverts[p] &&
				Distances[bestPoint][p] <= Antennes[bestAntenne].portee &&
				Visibilite[bestPoint][p])
			{
				nonCouverts[p] = 0;
			}
		}
	}
	return cout;
}
int main(int argc, char *argv[])
{
	char *filename = "c.dat";// Nom du fichier par défaut
	clock_t start, end;
	double cpu_time_used;
	start = clock();// Enregistrez le temps de début
	if (argc == 2)// Vérifier si un nom de fichier est passé en argument
	{
		filename = argv[1];
		char cmd[1024];
		sprintf(cmd,
			"/home1/commun_depinfo/enseignants/lemarchand/CPLEX_Studio126/opl/bin/x86-64_linux/oplrun "
			"dat2cprog.mod %s",
			argv[1]);
		system(cmd);
		sleep(1);
	
	}
	// Appeler la fonction pour lire les données du fichier (en mode local on lit directement le fichier passé en argument)
	// Appeler la fonction pour lire les données du fichier "c.dat"
	readCouverture("c.dat");
	printf("from %s: read %d points and %d antennas problem\n",
		   filename, NbPoints, NbAntennes);
	int select[MAXANTENNES][MAXPOINTS];// Tableau pour stocker les antennes sélectionnées pour chaque point
	for (int a = 0; a < MAXANTENNES; a++)// Initialisation à 0
		for (int p = 0; p < MAXPOINTS; p++)
			select[a][p] = 0;
	float cout = couvrir(select);// Appeler la fonction pour couvrir les points avec les antennes
	for (int a = 0; a < NbAntennes; a++)// Afficher les antennes sélectionnées pour chaque point
	{
		for (int p = 0; p < NbPoints; p++)
		{
			if (select[a][p] == 1)
			{
				printf("\nant %d at point %d\n", a + 1, p + 1);
			}
		}
		printf("\n");
	}
	printf("cost : %.2f\n", cout);// Afficher le coût total de la solution
	end = clock();// Enregistrez le temps de fin
	cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
	printf("Le temps d'exécution est %f secondes.\n", cpu_time_used);
	return 0;
}
