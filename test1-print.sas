options mprint nocenter;
filename src "./src";
%include src(
  _nobsdata_  /* number of observations in a dataset */
  contents_data
  checkdupkey
  );

ods listing close;


ods html file ="test1-print.html";

Title "Macro CONTENTS_DATA";
title2 "By default dataset named CONTENTS is created and printed";
%contents_data(sashelp.class);


Title "Macro _NOBSDATA_ macro";
Title2 "Creates _NOBSDATA_ dataset (one row) with NOBS and NVAR";

%_nobsdata_(class, libname=sashelp);

Title "Macro CHECKDUPKEY";
title2 "By default dataset named  `_freq_dupkey_` is created and printed";

data clss;/* DATASET with duplicate key */
  set sashelp.class;
  if name = "Alfred" then name = "Henry";  
run;

%checkdupkey(clss, name);
title "Data: _FREQ_DUPKEY_";
proc print data = _FREQ_DUPKEY_;

title "Data: _MRGD_DUPKEY_";
proc print data = _MRGD_DUPKEY_;
run;
ods html close;
