libname finproj '/folders/myfolders/finalproject/';
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
/*End Formats*/
/*Data Reading*/
data finproj.receiving;
	infile '/folders/myfolders/finalproject/receiving.csv' dlm = ',' firstobs=2 dsd missover;
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
		  wk = "Week of Season"
		  catch_pct = "caught/targets"
		  preformance = "how well the player did that week";
	catch_pct = round(rec/tgt,.01);
	if yds >= 150 then preformance = "phenomenal";
	if yds <= 50 then preformance = "bad";
	if yds >= 50 then preformance = "good";
	if yds >= 100 then preformance = "great";
run;

data finproj.arrests;
	infile '/folders/myfolders/finalproject/ArrestIncidents.csv' dlm = ',' firstobs=2 dsd missover;
	input date :mmddyy10. team :$3. name :$28. position :$3. case1 :$12.
		  category :$36. description :$256. outcome :$128;
	format date mmddyy10.;
	label date = "Date of Incident"
		  team = "Team of Player"
		  name = "Name of Player"
		  position = "Player's Position"
		  case1 = "Incident Type"
		  category = " Incident Crime Categories"
		  description = "Description of Crime"
		  outcome = "Incident outcome description";
run;
/*End Data Reading*/
/*Being Analyzing Data*/
/*Table 1*/
proc freq data=finproj.receiving nlevels;
	tables _all_ /noprint;
run;
/*Table 2*/
proc freq data=finproj.arrests nlevels;
	tables _all_ /noprint;
run;
/*Figure 1*/
proc freq data=finproj.receiving;
	tables team;
run;
/*Figure 2*/
proc freq data=finproj.arrests nlevels;
	tables team;
run;

/*should be 32, see Free agent/SD/STL*, changed team names to be same in each dataset where possible*/
/*includes stl, which is now LA*/
proc freq data=finproj.arrests;
	tables case1;
run; /*looks good*/

proc univariate data=finproj.receiving;
	var avg;
run; /*looks good*/

proc univariate data=finproj.receiving;
	var pct;
run; /*looks good*/

proc univariate data=finproj.receiving;
	var lng;
run; /*looks good*/

proc univariate data=finproj.receiving;
	var rec;
run; /*looks good*/
proc univariate data=finproj.receiving;
	var yds;
run; /*looks good*/
proc univariate data=finproj.receiving;
	var tgt;
run; /*looks good*/
proc univariate data=finproj.receiving;
	var td;
run; /*looks good*/
proc univariate data=finproj.receiving;
	var fstdn;
run; /*looks good*/
proc univariate data=finproj.receiving;
	var fum;
run; /*looks good*/
proc univariate data=finproj.receiving;
	var fuml;
run; /*looks good*/
proc print data=finproj.receiving;
	where fuml>fum;
run; /*no case*/

/*Figure 3*/
proc print data=finproj.receiving;
	var team name rec tgt;
	where rec>tgt;
run; /*one case,fixed*/
/*obs 51808 what do we do? just set target to 1 */

/* Cleaning section*/
data finproj.clean_arrests;
	set finproj.arrests;
 if position = "DE/" then position = "DE";
 if team = "Fre" then team = "Free Agent";
run;

data finproj.clean_receiving;
	set finproj.receiving;
	if name = "Peters, Jason" then tgt = 1;
	if team = "ARZ" then team = "ARI";
	if team = "JAX" then team = "JAC";
	if team = "LA" then team = "LAR";
	run;
/*GROUPING SECTION*/

/*Figure 7*/
proc sql;
	select team, count(case1) as NumCases
	from finproj.clean_arrests
	group by team
	order by NumCases desc;
quit;

/*which teams have most arrests*/
/*Figure 4 and Figure 8*/
proc sql;
	select position, count(position) as count
	from finproj.arrests
	group by position;
quit;
proc sql;
	select position, count(position) as count
	from finproj.clean_arrests
	group by position;
quit;

/*which positions have mose arrests*/


data finproj.off_def;
	set finproj.clean_arrests;
	off_def = position;
	if position = 'C' then off_def = "O";
if position ='CB' then off_def = "D";
if position ='DB' then off_def = "D";
if position ='DE' then off_def ="D";
if position ='DT' then off_def =	"D";
if position ='FB' then off_def = "O"	;
if position ='K' then off_def = "O";
if position ='LB' then off_def =	"D";
if position ='OG' then off_def ="O";
if position ='OL' then off_def =	"O";
if position ='OT' then off_def =	"O";
if position ='P' then off_def	="O";
if position ='QB' then off_def =	"O";
if position ='RB' then off_def =	"O";
if position ='S' then off_def	="D";
if position ='TE' then off_def = 	"O";
if position ='WR' then off_def ="O";
run;

/*Figure 6*/
proc sql;
	select off_def, count(off_def) as count
	from finproj.off_def
	group by off_def;
quit;

 /* defense players committed more crimes*/

/*Figure 9*/
proc sql;
	select  name,season, max(yds) as MaxYds
	from finproj.receiving
	group by season
	having yds = calculated MaxYds;
quit;
/*most yards in a game per season*/
/*Figure 10*/
proc sql;
	select team, sum(yds) as TotYds
	from finproj.receiving
	group by team
	order by calculated TotYds desc;
quit;
/*better teams have more passing yards*/
/*Figure 11*/
proc sort data=finproj.clean_receiving;
	by wk;
	where season = 2016 and team = "NE";
run;
data total_rec_by_NE_2016;
	set finproj.clean_receiving;
	by wk;
	if first.wk then total_yds = 0;
	total_yds + yds;
	if last.wk;
	keep wk total_yds;
run;
proc print data=total_rec_by_NE_2016;run;
/*End Figure 11*/

/*Merge*/
/*Figure 5*/
proc sql;
select a.team, sumarrests, totalyds
from (select team, count(case1) as sumarrests from finproj.arrests
     where position = "WR"
     group by team) as a
inner join (select team, sum(yds) as totalyds
from finproj.receiving
group by team) as r
on a.team = r.team
order by totalyds desc;
quit;
/*better teams do not have more arrests, please mention that our belief was incorrect*/


