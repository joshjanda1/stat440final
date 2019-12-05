libname finproj '~/my_courses/HW/';


proc format;
	invalue avgin '-' = .;
run;

/*FORMATS SECTION*/
proc freq data=finproj.receiving;
	tables wk;
run; /*<- confirms weeks only go 101-117 */

proc format;
	value weeks 101 = 1
				102 = 2
				103 = 3
				104 = 4
				105 = 5
				106 = 6
				107 = 7
				108 = 8
				109 = 9
				110 = 10
				111 = 11
				112 = 12
				113 = 13
				114 = 14
				115 = 15
				116 = 16
				117 = 17;
run;

proc format;
	value $caseclass
	'Arrested'	= '1'
'Charged'	= '2'
'Cited'	='3'
'Detained'='4'
'Died'	='5'
'Indicted'='6'
'Jailed'	='7'
'Summoned'	='8'
'Surrendered'='9'
'Warrant'='10';
run;

data finproj.receiving;
	infile '/home/u42578782/my_courses/HW/receiving.csv' dlm = ',' firstobs=2 dsd missover;
	input name :$28. team :$3. rec :4. yds :5. tgt :4. avg :4.
		  td :4. fstdn :4. pct :3. lng :4. fum :4. fuml :4.
		  season :4. wk :4.;
	format wk weeks.;
	label name = "Last, First Name of Player"
		  team = "Team of Player"
		  rec = "Total Number of Receives"
		  yds = "Total Number of Yards"
		  tgt = "Total Number of Targets"
		  avg = "Average Yards per Receive"
		  td = "Number of Touchdowns"
		  fstdn = "Number of First Downs"
		  pct = "Percentage of First Downs for each Receive"
		  lng = "Longest Gain/Receive for Week"
		  fum = "Number of Fumbles"
		  fuml = "Number of Fumbles Lost"
		  season = "Season Year"
		  wk = "Week of Season";
	catch_pct = round(rec/tgt,.01);
run;

data finproj.arrests;
	infile '/home/u42578782/my_courses/HW/ArrestIncidents.csv' dlm = ',' firstobs=2 dsd missover;
	input date :mmddyy10. team :$3. name :$28. position :$3. case1 :$12.
		  category :$36. description :$256. outcome :$128;
	format date mmddyy10.;
	format case1 $caseclass.;
	label date = "Date of Incident"
		  team = "Team of Player"
		  name = "Name of Player"
		  position = "Player's Position"
		  case = "Incident Type"
		  category = " Incident Crime Categories"
		  description = "Description of Crime"
		  outcome = "Incident outcome description";
run;

proc freq data=finproj.receiving nlevels;
	tables _all_ /noprint;
run;

proc freq data=finproj.receiving;
	tables team;
run;

proc freq data=finproj.arrests nlevels;
	tables team;
run;

/*should be 32, see Free agent/SD/STL*/

proc freq data=finproj.arrests;
	tables case1;
run;

proc print data=finproj.arrests;
	where case = 'Died';
run;
/*includes stl, which is now LA*/

proc univariate data=finproj.receiving;
	var avg;
run;

proc univariate data=finproj.receiving;
	var pct;
run;

proc univariate data=finproj.receiving;
 var lng;
run;

proc print data=finproj.receiving;
	where fuml>fum;
run;

proc print data=finproj.receiving;
	where rec>tgt;
run;

/*obs 51808 what do we do?*/

/* Cleaning section*/
data finproj.clean_arrests;
	set finproj.arrests;
 if position = "DE/" then position = "DE";
 if team = "Fre" then team = "Free Agent";
run;
/*GROUPING SECTION*/

proc sql;
	select team, count(case1) as NumCases
	from finproj.arrests
	group by team
	order by NumCases desc;
quit;

/*which teams have most arrests*/

proc sql;
	select position, count(position) as count
	from finproj.clean_arrests
	group by position;
quit;

/*conditional output*/

proc sql;
	select  name,season, max(yds) as max
	from finproj.receiving
	group by season
	having yds = calculated max;
quit;

proc sql;
	select team, sum(yds) as sum
	from finproj.receiving
	group by team
	order by calculated sum desc;
quit;

/*better teams have more passing yards*/


/* found an error where one position is DE/*/
/* somehow group into offense/defense to see who commits more crimes*/

/* Iterative Processing
