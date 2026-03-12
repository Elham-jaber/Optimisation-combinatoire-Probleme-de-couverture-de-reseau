// Couverture
// definir les donnees pour lire le couv.dat, avec un tuple pour les points Tpoint(champs x et y)
// et un tuple pour les antennes Tmodele (champs portee et prix)

// a vous ! pour la definition des tuples
tuple Tpoint{
    float x ;
    float y;
}

tuple Tmodele{
    float portee;
    float prix;
}

{ Tpoint } points = ...;
{ Tmodele } antennes = ...;

int visibilite[points][points] = ...;


// definir Distances[][]  
float distances[points][points] ;

execute {
    for (var p1 in points)
        for (var p2 in points)
            distances[p1][p2] =
                Opl.sqrt( (p1.x - p2.x)*(p1.x - p2.x)
                        + (p1.y - p2.y)*(p1.y - p2.y) );
}


// une solution = liste des antennes possibles qui sont allumees: SELECT[a][pa]=1
// definir SELECT
dvar boolean SELECT[antennes][points];


// minimiser le cout total des antennes choisies
minimize
    sum (a in antennes, p in points)
        a.prix * SELECT[a][p];


subject to {

  // Chaque point doit etre couvert par au moins une antenne visible et a portee
  forall(pb in points)
    sum(a in antennes, pa in points)
      ((distances[pa][pb] <= a.portee &&
        visibilite[pa][pb] == 1)
       * SELECT[a][pa]) >= 1;
}


execute {
    writeln("cout = ", cplex.getObjValue());
    for(var a in antennes)
        for(var p in points)
            if (SELECT[a][p] == 1)
                writeln(a.portee, " ", p.x, " ", p.y);
}
