libname finproj '/folders/myfolders/finalproject/';


proc format;
	invalue avgin '-' = .;
run;
				  
data finproj.receiving;
	infile '/folders/myfolders/finalproject/receiving.csv' dlm = ',' firstobs=2 dsd missover;
	input name :$28. team :$3. rec :4. yds :5. tgt :4. avg :4.
		  td :4. fstdn :4. pct :3. lng :4. fum :4. fuml :4.
		  season :4. wk :4.;
run;
	
data finproj.arrests;
	infile '/folders/myfolders/finalproject/arrestincidents.csv' dlm = ',' firstobs=2;
	input date :mmddyy10. team :$3. name :$28. position :$3. case :$12.
		  category :$18. description :$256.;
run;

proc freq data=finproj.receiving nlevels;
	tables _all_ /noprint;
run;

proc freq data=finproj.receiving;
	tables team;
run;
/*includes stl, which is now LA*/

proc univariate data=finproj.receiving;
	var avg;
run;

proc univariate data=finproj.receiving;
	var pct;
run;
