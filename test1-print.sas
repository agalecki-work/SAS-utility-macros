options mprint nocenter;
filename src "./src";
%include src(
  _nobsdata_  /* number of observations in a dataset */
  contents_data
  );

ods listing close;


ods html file ="test1-print.html";

Title "Macro CONTENTS_DATA";
title2 "By default dataset named CONTENTS is created and printed";
%contents_data(sashelp.class);


Title "Macro _NOBSDATA_ macro";
Title2 "Creates _NOBSDATA_ dataset (one row) with NOBS and NVAR";

%_nobsdata_(class, libname=sashelp);
ods html close;
