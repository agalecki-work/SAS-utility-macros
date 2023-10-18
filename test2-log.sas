options mprint nocenter;
filename src "./src";
%include src(
  attrc_label
  attrc_sortedby
  );

ods listing close;


Title "Macro ATTRC_LABEL";
Title2 "Returns dataset label";
%let data_label = %attrc_label(class, libname=sashelp);
%put data_label := &data_label;

Title "Macro ATTRC_SORTEDBY";
Title2 "Returns dataset sortedby attribute";
%let data_sorted = %attrc_sortedby(class, libname=sashelp);
%put data_sorted := &data_sorted;
