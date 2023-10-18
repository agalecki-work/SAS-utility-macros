*#3. Macro to transpose datasets from a library;
%macro TransposeAllLib(InpSet= /*Input dataset*/
,byVars= /*By variables. The first variable is key ie it
must appear in the dataset in order to consider it for transposition e.g. SUBJID. Must
contain sequence variable other than key ID marked by # e.g LINE#*/
,OutSet= /*Output dataset*/
,DelTmp= /*set to Y to delete temporary datasets*/
);
%let StartTime = %sysfunc(datetime());
%LibContents(Lib=&InpSet.,DelTemp=Y);

*#Create a string with ID variables list;
%if %length(&byVars.)>0 %then %do;
%put &byVars.;
*#Identify the sequence variable [marked by "#" at the end];
%let pos1 = %sysfunc(find("&byVars.",#,-1000));
%let SeqAsLast = %qsubstr(&byVars.,1,&pos1.-2);
%let pos2 = %sysfunc(anyspace("&SeqAsLast.",-1000));
%let SeqVar = %qsubstr(&SeqAsLast.,&pos2.);
%put &SeqVar.;
*#Update ID variables to drop Seq indicator;
%let byVars=%sysfunc(compress(&byVars.,#));
%put &byVars.;
data _null_;
 List='"'||tranwrd(compbl(upcase("&byVars.")),' ','" "')||'"';
 call symput('byVarsQ',List);
 run;
%put &byVarsQ.;
%end;
*#Extract each single ID variables and save as macro variables;
%if %length(&byVars.)>0 %then %do;
%let k=1;
%do %until(%nrbquote(%scan(&byVars.,&k,' '))=);
%let Value&k=%upcase(%scan(&byVars.,&k,' '));
%put Value&k = &&Value&k;
%put &k;
%let k = %eval(&k+1);
%end;
%let NbyVars=%eval(&k-1);
%put &NbyVars.;
%end;

*#Check if ID variables are present in the datasets;
proc sql;
create table _tmpdls01 as select
*
%do i=1 %to &NbyVars.;
,sum(varname in ("&&Value&i")) label="&&Value&i." as KeyVar&i.
%end;
from &InpSet.
group by memname;
quit;
*#Transpose only datasets with key ID variable present and with at least one record
[skip ID variables from the list];
proc transpose
data = _tmpdls01 (where = (varname not in (&byVarsQ.) and memnobs>0 and KeyVar1=1))
out = _tmpdls02;
by libname memname KeyVar:;
var varname;
run;
*#Create the specification of the datasets in the library;
data VarSpec;
length DVList List $5000;
set _tmpdls02 end=last;
Loc = trim(left(libname))||'.'||trim(left(memname));
List = catx(' ', of col:);
DVList = trim(left(memname))||'['||List||']';
DSetIdN+1;
DSetId='DS'||trim(left(put(DSetIdN,best.)));
DSetLoc='LOC'||trim(left(put(DSetIdN,best.)));
NKeyVars=sum(of KeyVar:);
keep Loc DVList List DSetIdN DSetId DSetLoc KeyVar: NKeyVars memname libname;
*Output variables and locations;
call symputx(DSetId,List);
call symputx(DSetLoc,Loc);
if last then call symputx('NSets',DSetIdN);
run;

%let RunIndex=1;
%do i=1 %to &NSets.;
%put ########### Processing Dataset: &&loc&i. ###########;
data _tmpdlIn01;
 set &&loc&i.;
 UniqueKey=1;
run;
*Bring in domain name and library;
data _tmpdlname;
set VarSpec (where = (DSetIdN=&i.) keep = DSetIdN memname libname);
UniqueKey=1;
run;
data _tmpdlIn02;
 merge _tmpdlIn01 (in=a) _tmpdlname (in=b);
 by UniqueKey;
run;
%do j=2 %to &NbyVars.;
 proc sql noprint;
select KeyVar&j. into :IndValKeyVar&j. from VarSpec where DSetIdN=&i.;
 quit;
%if &&IndValKeyVar&j.=0 and %upcase(&&Value&j.)^= %upcase(&SeqVar.) %then %do;
*#If second ID variable is missing;
data _tmpdlIn02;
 set _tmpdlIn02;
 &&Value&j="";
run;
%end;
%else %if &&IndValKeyVar&j.=0 and %upcase(&&Value&j.)= %upcase(&SeqVar.) %then %do;
*#If line ID variable is missing then set to dummy sequence;
proc sort data=_tmpdlIn02 out=_tmpdlIn03;
 by &Value1.;
run;
data _tmpdlIn02;
 set _tmpdlIn03;
 by &Value1.;
 retain &SeqVar.;
 if first.&Value1. then &SeqVar.=1;
 else &SeqVar.+1;
run;
%end;
%end;
%DataLong(InpSet=_tmpdlIn02
 ,byVars=&byVars. memname libname
 ,Params=&&ds&i.
 ,OutSet=_tmpdlOutInd
 ,OutSrt=&byVars.
 ,DelTmp=);
%if &RunIndex.=1 %then %do;
data &OutSet.;
 set _tmpdlOutInd;
run;
%end;
%if &RunIndex.>1 %then %do;
data &OutSet.;
 set &OutSet. _tmpdlOutInd;
run;
%end;
%let RunIndex = %eval(&RunIndex+1);
%end;
*#Delete temp datasets from work library;
%if &DelTmp. = Y %then %do;
ods exclude all;
 proc datasets library=work;
 delete _tmpdl: ;
 run;
ods select all;
%end;

data _null_;
duration = datetime()-&StartTime.;
put 'Total duration:' duration time13.2;
run;
%mend TransposeAllLib;

%macro Example2Use;
*#Example of the use of the macro for checks on the NIDA datasets;
*#Create transposed dataset;
%TransposeAllLib(InpSet=raw
,byVars=patient study line#
,OutSet=o
,DelTmp=);


*#Simple scan check;
%FindHidChars(InpSet=o
,Var=paramvlc
,Whr=
,OutSet=o1);

*#Visual and statistical check;
%FirstDigitDist(InpSet=o
,Var=paramvlc
,Whr= paramtp eq 'N' and memname eq 'LABSA'
,OutSet=o2
,Plot=Y);
%mend Example2Use;
