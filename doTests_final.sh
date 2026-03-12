#!/bin/bash

# Configuration CPLEX
export cplexdir=/home1/commun_depinfo/enseignants/lemarchand/CPLEX_Studio126
export LD_LIBRARY_PATH=$cplexdir/opl/bin/x86-64_linux:$cplexdir/opl/lib/x86-64_linux/shared_pic:$cplexdir/cplex/lib/x86-64_linux/static_pic
export oplrun=$cplexdir/opl/bin/x86-64_linux/oplrun

# création du fichier résultat
rm -f resultat_final.csv
echo "Points,CoutExact,CoutHeurOPL,CoutHeurC,TempsExact,TempsHeurOPL,TempsHeurC" > resultat_final.csv

for n in 50 100 150 200
do
    echo "===== Taille $n ====="

    ./genPoints $n 1 > tmp.dat

    # EXACT
    /usr/bin/time -f "%e" -o timeExact.txt \
    $oplrun couvExact.mod tmp.dat > exact.txt 2>/dev/null

    coutExact=$(grep "cout =" exact.txt | awk '{print $3}')
    tempsExact=$(cat timeExact.txt)

    # HEUR OPL
    /usr/bin/time -f "%e" -o timeHeurOPL.txt \
    $oplrun couv2heuristique.mod tmp.dat > heurOPL.txt 2>/dev/null

    coutHeurOPL=$(grep "cout =" heurOPL.txt | awk '{print $3}')
    tempsHeurOPL=$(cat timeHeurOPL.txt)

    # HEUR C
    $oplrun dat2cprog.mod tmp.dat > /dev/null
    /usr/bin/time -f "%e" -o timeHeurC.txt \
    ./heuristique > heurC.txt 2>/dev/null

    coutHeurC=$(grep "cost" heurC.txt | awk '{print $3}')
    tempsHeurC=$(cat timeHeurC.txt)

    # écriture ligne csv
    echo "$n,$coutExact,$coutHeurOPL,$coutHeurC,$tempsExact,$tempsHeurOPL,$tempsHeurC" >> resultat_final.csv

done

rm -f tmp.dat exact.txt heurOPL.txt heurC.txt \
timeExact.txt timeHeurOPL.txt timeHeurC.txt c.dat

echo "Résultats enregistrés dans resultat_final.csv"