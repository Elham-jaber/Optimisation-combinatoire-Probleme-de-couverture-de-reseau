// L Lemarchand 
// EL CHAMAA mohamad && JABER elham 
// Definition du tuple representant un point dans le plan
tuple Tpoint {
    int x; // Coordonne x du point
    int y; // Coordonne y du point
};
{ Tpoint } points = ...; // Ensemble de points representant les emplacements potentiels pour les antennes
float Distance[points][points];// Tableau 2D contenant les distances entre chaque paire de points


execute {// Calcul des distances entre chaque paire de points
    for (var p1 in points)
        for (var p2 in points) {
            var dx = p1.x - p2.x; // Difference en x
            var dy = p1.y - p2.y; // Difference en y
            Distance[p1][p2] = Opl.sqrt(dx*dx + dy*dy); // Calcul de la distance euclidienne
        }
}
tuple Tantenne {
    float portee; // Portee de l'antenne
    int cout;     // Cout de l'antenne
};
{ Tantenne } antennes = ...;// Ensemble d'antennes avec leurs portees et les couts
int visibilite[points][points] = ...;// Matrice binaire indiquant la visibilite entre chaque point et chaque antenne
{Tpoint} nonCouverts;    // Points non encore couverts
{Tpoint} tmpCouverts;    // Sauvegarde des points couverts par une antenne dans une iteration
{Tpoint} bestCouverts;   // Meilleur ensemble couvert courant
int select[antennes][points]; // Solution
float cout = 0.0;        // Cout total
execute {// Heuristique
    for (var a in antennes)// Initialisation de la solution a 0
        for (var p in points)
            select[a][p] = 0;
    nonCouverts.importSet(points); // Au depart tous les points doivent etre couverts
    var taille = nonCouverts.size; // Variable qui contient le nombre de points restant a couvrir
    while (taille != 0) { // On continue tant qu'il reste des points non couverts
        var max = -1.0; // Initialisation du maximum, stocke le meilleur ratio (couverture / cout)
        var max_a;      // Antenne correspondant au meilleur ratio
        var max_pa;     // Meilleur point
        for (var a in antennes) {// On teste toutes les antennes disponibles
            for (var pa in points) { // Pour chaque antenne, on teste toutes les positions possibles
                tmpCouverts.clear(); // Nettoyage de tmpCouverts a chaque iteration
                for (var p in nonCouverts) {// Parcours des points non couverts
                    if ((Distance[pa][p] <= a.portee) && (visibilite[pa][p] == 1)) {// La distance est inferieure a la portee et les deux points sont visibles l'un de l'autre
                        tmpCouverts.add(p); // Si le point est couvert, on l'ajoute
                    }
                }
                if (tmpCouverts.size > 0) {// Calcul du rapport nombre de points couverts / cout de l'antenne
                    var ratio = tmpCouverts.size * 1.0 / a.cout; // On force le calcul en float pour eviter la division entiere
                    if (ratio > max) {
                        max = ratio;       // Mise a jour du maximum
                        max_a = a;         // Mise a jour de l'antenne
                        max_pa = pa;       // Mise a jour du point
                        bestCouverts.clear(); // Nettoyage de bestCouverts
                        bestCouverts.importSet(tmpCouverts); // Mise a jour de bestCouverts
                    }
                }
            }
        }
        for (var p in bestCouverts) { // Suppression des points couverts et mise a jour de la solution
            nonCouverts.remove(p); // Suppression du point de nonCouverts
        }
        select[max_a][max_pa] = 1; // Selection de l'antenne pour le point
        cout = cout + max_a.cout;  // Mise a jour du cout total
        taille = nonCouverts.size; // Mise a jour de la taille de nonCouverts
    }
    writeln("cout = ", cout);// Affichage du cout pour compatibilite avec les scripts shell
}
execute {// Sortie du resultat detaille
    var sortie = "couv2.res"; // Fichier de sortie
    var ofile = new IloOplOutputFile(sortie); // Ouverture du fichier de sortie
    ofile.writeln("cout = ", cout); // Ecriture du cout total
    for (var a in antennes)
        for (var pa in points)
            if (select[a][pa] == 1)
                ofile.writeln(a.portee, ", ", pa.x, " ", pa.y); // Ecriture des details des antennes selectionnees
    ofile.close(); // Fermeture du fichier de sortie
    writeln("trace dans ", sortie); // Affichage du chemin du fichier de sortie
}
// Il est possible d'eviter l'appel au solver en ecrivant un main() a la place du dernier execute -- cf exemples OPL
