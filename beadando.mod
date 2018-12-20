set guitars;
set genre;
set concerts;

param startmoney := 130;
param price{guitars};
param genreguitars{genre,guitars} binary, default 0;
param concertprice{concerts,genre};

var money >= 0;
var guitarbuy{g in guitars} binary;
var whichconcerts{c in concerts, j in genre} binary;

#legalább egy gitárt vennünk kell
s.t. AtLeastOneGuitar:
	sum{g in guitars} guitarbuy[g] >= 1;

#a pénzünk nem lehet több, mint a gitár ára
s.t. MoneyIsAlwaysPositive{g in guitars}:
	money >= guitarbuy[g]*price[g];

#Egy koncertre csak egyszer mehetünk el
s.t. OneConcertMaxOnce{c in concerts}:
	sum{j in genre} whichconcerts[c,j] <= 1;

#Ha adott gitárt vettem meg és az adott stílusra való, akkor az adott stílusban lesz értelme szerepelnünk a koncerteken
s.t. ChosenConcerts{c in concerts, j in genre, g in guitars:genreguitars[j,g] == 1}:
	whichconcerts[c,j] = guitarbuy[g];

#Aktuális pénz = gitárunkal aktuális stílus * koncertárak stílus szerint + indulótõke - gitár ára
s.t. MoneyInitialize:
	money = sum{c in concerts, j in genre} whichconcerts[c,j]*concertprice[c,j] + startmoney - sum{g in guitars}guitarbuy[g]*price[g];

maximize Maxmoney:
	money;

solve;

for{g in guitars:guitarbuy[g]==1}{
	printf "Valasztott gitar: %s\n",g;
	printf "Ara: %d.000 HUF\n",price[g];
	for{j in genre:genreguitars[j,g]==1}
		printf "Mire lehet menni vele: %s\n",j;
	printf "Penzunk: %d.000\n",startmoney-price[g];
}
for{c in concerts, j in genre:whichconcerts[c,j]==1}{
	printf "Valasztott koncert: %s\n",c;
	printf "Fizetes: %d.000 HUF\n",concertprice[c,j];
}
	printf "Penzunk: %d.000 HUF\n",money;

data;

set guitars := G1 G2 G3 G4 G5;

set genre := GEN1 GEN2 GEN3;

set concerts := C1 C2 C3 C4 C5 C6;

param price:=
G1	75
G2	90
G3	120
G4	85
G5	82
;

param genreguitars:
	G1	G2	G3	G4	G5 :=
GEN1	1	.	.	.	.
GEN2	.	1	1	.	.
GEN3	.	.	.	1	1
;

param concertprice:
	GEN1	GEN2	GEN3 :=
C1	40	60	32
C2	24	30	16
C3	33	43	22
C4	40	53	41
C5	27	80	47
C6	40	50	47
;

end;
