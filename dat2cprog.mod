// L Lemarchand
// c 2023
// Ce programme ecrit dans un fichier c.dat les donnees du probleme
// dans un format simple lisible par un programme C
// Format ecrit dans c.dat :
// nbAntennes
// portee1 cout1
// portee2 cout2
// ...
// nbPoints
// distance(i,j)
// visibilite(i,j)
// ...

// Definition du tuple representant un point du plan
tuple Tpoint {
    int x; // coordonnee x du point
    int y; // coordonnee y du point
};

// Ensemble des points
{Tpoint} points = ...;

// Matrice des distances entre chaque paire de points
float Distance[points][points];

// Calcul automatique des distances euclidiennes
execute {

    // Pour chaque couple de points
    for (var p1 in points)
        for (var p2 in points) {

            // Calcul difference en x
            var dx = p1.x - p2.x;

            // Calcul difference en y
            var dy = p1.y - p2.y;

            // Distance euclidienne
            Distance[p1][p2] = Opl.sqrt(dx * dx + dy * dy);
        }
}

// Definition du tuple representant une antenne
tuple Tantenne {
    float portee; // portee maximale de l antenne
    int cout;     // cout d installation de l antenne
};

// Ensemble des antennes
{Tantenne} antennes = ...;

// Matrice de visibilite entre les points
// visibilite[p1][p2] = 1 si les deux points se voient
int visibilite[points][points] = ...;

// Variables declarees mais non utilisees ici
// Elles sont presentes pour compatibilite avec le modele principal
{Tpoint} nonCouverts;
{Tpoint} tmpCouverts;
{Tpoint} bestCouverts;

int select[antennes][points];
float cout = 0.0;

// Conversion des donnees vers c.dat
execute {

    // Nom du fichier de sortie
    var sortie = "c.dat";

    // Ouverture du fichier
    var ofile = new IloOplOutputFile(sortie);

    writeln("extracting covering problem data into c.dat file");

    // Ecriture du nombre d antennes
    ofile.writeln(antennes.size);

    // Ecriture des portees et couts
    for (var a in antennes)
        ofile.writeln(a.portee, " ", a.cout);

    // Ecriture du nombre de points
    ofile.writeln(points.size);

    // Pour chaque couple de points
    // on ecrit d abord la distance puis la visibilite
    for (var p1 in points)
        for (var p2 in points) {

            ofile.writeln(Distance[p1][p2]);   // distance
            ofile.writeln(visibilite[p1][p2]); // visibilite
        }

    // Fermeture du fichier
    ofile.close();
}
