#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// genPoints <nbPoints> [<seed>]
// les points sont Ã  la fois les points Ã  couvrir et les points possibles pour les antennes
/* produit:
points = {
< 1, 1>,
< 1, 2>,
< 1, 3>, 
< 1, 4>,
< 2, 1>,
< 2, 2>,
< 2, 3>, 
< 2, 4>
};

antennes .........


visibilite = [
[ 1 1 1 0 0 0 0 0 ]
[ 1 1 1 0 0 0 0 0 ]
[ 1 1 0 0 0 0 1 0 ]
[ 0 1 1 0 0 0 1 0 ]
[ 1 1 1 0 0 1 0 1 ]
[ 1 1 1 0 1 0 0 0 ]
[ 1 0 1 1 0 0 0 1 ]
[ 1 1 1 0 0 0 1 0 ]
];
*/

// A utiliser pour ajouter a couv.dat les points: ./genPoints 100 3 >> couv.dat
// les antennes doivent etre saisies à part
// cf doTestsCouverture
int main(int argc, char *argv[]) 
{

	int i, j;
	if (argc < 2) goto usage;

	int n = atoi(argv[1]);
	if (argc == 3) srand(atoi(argv[2]));
	// -------- Points --------
	printf("points = {\n");
	for(i=1;i<n/4;i++){
		for(j=1;j<=4;j++){
			printf("< %d, %d>,\n", i, j);
		}
	}	
	printf("< %d, 1>,\n", (n/4));
	printf("< %d, 2>,\n", (n/4));
	printf("< %d, 3>,\n", (n/4));
	if(n%4 != 0){
		printf("< %d, 4>,\n", (n/4));
		for(j=1;j<n%4;j++){
			printf("< %d, %d>,\n", (n/4+1), j);
		}
		printf("< %d, %d>\n", (n/4+1), (n%4));
	} 
	else {
		printf("< %d, 4>\n", (n/4));
	}
	printf("};\n");

	// -------- ANTENNES --------
    printf("antennes = {\n");
    printf("< 3.6, 120 >,\n");
    printf("< 2.4, 100 >\n");
    printf("};\n\n");


	// -------- Visibilite --------
	
	printf("visibilite = [\n");
	for(i=0; i<n; i++){
		printf("[ ");
		for(j=0; j<n; j++){
			printf("%d ", (rand()%2));
		}
		printf("]\n");
	}
	printf("];\n");


	return 0;
usage:
	fprintf(stderr, "usage: %s <nbPoints> [<seed>]\n", argv[0]);
	return 1;


}
