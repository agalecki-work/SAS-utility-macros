%macro datepart(varnm) / des = "M1: Extract datepart from datetime variable and assigns date7. format";
 &varnm = datepart(&varnm);
 format &varnm date7.;
%mend datepart;
