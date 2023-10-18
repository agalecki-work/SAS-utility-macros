%macro checkkeyvars (data, keys, opt = S) / des = "M1: Check key variables";
Title "MACRO checkkeyvars: Data: &data. Key variables are; &keys";
%checkdupkey(&data, &keys, opt = &opt); /* creates _mrgd_dupkey_ dataset */

proc printto print=logger;
run;

proc print data = _mrgd_dupkey_;
run;
proc printto;
run;

proc sort data= &data;
by &keys;
run;

%mend checkkeyvars;

