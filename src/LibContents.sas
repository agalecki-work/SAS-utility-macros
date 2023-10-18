/* http://www.phusewiki.org/docs/Conference%202017%20DH%20Papers/DH08.pdf */

%macro LibContents(
 Lib= /*Library name (e.g. work) and the default name of the output dataset with 
     description of the library contents*/ 
 , DSets=   /*List of the datasets to filter for (e.g. dm ex)*/
 , OutSet=  /*Name of the output dataset*/ 
 , DelTemp= /*Set to Y if temporary datasets are to be deleted*/ 
 );
*# Check if the name of the output dataset is specified; 
%if %length(&OutSet.)=0 %then %let OutSet=&Lib.; 
*# Create list of datasets to filter for;
%if %length(&DSets.)>0 %then %do;
  data _null_; NOfDSetsL=countw("&DSets.");
  DSetsList='"'||tranwrd(upcase("&DSets."),' ','" "')||'"';
  call symput('DSetsList',DSetsList);
  call symput('NOfDSetsL',NOfDSetsL);
 run; 
%end;
 proc sql noprint;
  create table _datasets as select
   * 
  from dictionary.tables
   where libname=upcase("&LIB")
   %if %length(&DSets.) > 0 %then and memname in (&DSetsList.);; 
 *# Check the number of datasets from the list found in the library;
  select count(*) into :NOfDSetsO from _datasets;
  create table _variables as select 
   a.* 
   from dictionary.columns a
   where libname=upcase("&LIB")
   and memname in (select distinct memname from _datasets)
   ; 
  create table &OutSet. as select
   a.libname, a.MemName, a.MemLabel, a.crdate as MemCrDate
  ,a.nobs as MemNobs, a.nvar as MemNVar, a.encoding as MemEncoding
  ,b.varnum as VarNum, b.name as VarName, b.label as VarLabel
  ,b.type as VarType, b.length as VarLength, b.format as VarFormat
       from _variables b left join _datasets a
        on (a.libname = b.libname and a.memname = b.memname)
          order by a.MemName, b.varnum 
        ; 
quit;
%*usr_modify_LibContents;  /*--- atg Oct. 2017 ---*/

*# Inform if the dataset from the list is not in the library;
%if %length(&DSets.)>0 %then %do; 
 %if &NOfDSetsO. = 0 %then %put ERR%str(OR):: Datasets from the list not found in the library.;
 %else %if &NOfDSetsO. > 0 and &NOfDSetsL. > &NOfDSetsO. %then
 %put WARN%str(ING):: Only some datasets from the list were found in the library.;
%end;
*#Delete temp datasets from work library;
%if &DelTemp. = Y %then %do;
 ods exclude all;
  proc datasets library=work;
  delete _datasets _variables;
  run; 
 ods select all; 
%end; 
%mend LibContents;
