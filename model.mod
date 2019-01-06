set guitars;
set genre;
set concerts;
param nDay := 30;
set days := 1..nDay;

param startmoney;
param price{guitars};
param genreguitars{guitars} symbolic in genre;
param concertprice{concerts,genre};
param concertdays{concerts} symbolic in days;

set concertdates := setof{d in days, c in concerts:concertdays[c] == d} (c,d);
set optimalguitargenres := setof{g in guitars,j in genre:genreguitars[g] == j} (g,j);

var guitarbuy{g in guitars, d in days} binary;
var whichconcerts{c in concerts, j in genre} binary;
var dailybudget{0..nDay} >= 0;

s.t. BudgetInit:
	dailybudget[0] = startmoney;

s.t. DailyBudgetInit{d in days}:
	dailybudget[d] = dailybudget[d-1] - sum{g in guitars} guitarbuy[g,d] * price[g] + sum{j in genre, c in concerts:concertdays[c] == d}whichconcerts[c,j]*concertprice[c,j];

s.t. AtLeastOneGuitar:
 	sum{g in guitars, d in days} guitarbuy[g,d] >= 1;

s.t. OneConcertMaxOnce{c in concerts}:
	sum{j in genre} whichconcerts[c,j] = 1;

s.t. ChosenConcerts{(c,d) in concertdates, j in genre}:
	whichconcerts[c,j] <= sum{d2 in 1..d, g in guitars:genreguitars[g] == j}guitarbuy[g,d2];

s.t. DontBuyTooExpensiveGuitar{d in 1..nDay}:
	dailybudget[d-1] >= sum{g in guitars}price[g]*guitarbuy[g,d];

maximize Maxmoney:
	dailybudget[nDay];

solve;

printf "\n\n";
for{d in days}{
	printf "\n%d. nap:\n",d;
	printf "\tBudget a nap elejen: %d.000 HUF\n",dailybudget[d-1];
	for{g in guitars:guitarbuy[g,d]==1}{
		printf "\n\tVasarolt gitar: %s\n",g,d;
		printf "\t\tGitar ara: %d.000 HUF\n\n",price[g];
	}
	for{c in concerts:concertdays[c] == d}{
		printf "\n\t%s koncert napja\n",c;
		for{j in genre:whichconcerts[c,j] == 1}{
			printf "\t\t%s stilusban leptunk fel\n",j;
			printf "\t\tNyereseg: %d.000 HUF\n\n",concertprice[c,j];
		}
	}
	printf "\tBudget a nap vegen: %d.000 HUF\n",dailybudget[d];
}
printf"\nVasarolt gitarok: ";
for{g in guitars:sum{d in days}guitarbuy[g,d] == 1}
	printf"%s ",g;
printf "\n\nZaro osszeg honap vegen: %d.000 HUF\n\n",dailybudget[nDay];
