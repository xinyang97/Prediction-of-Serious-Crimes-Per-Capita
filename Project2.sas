
libname d "/folders/myfolders/200B_DATA";
data cdi; set d.cdi; 
	popdensity = pop/area;
run;
/* split data into training and testing */
proc surveyselect data=cdi out=cdinew method=srs samprate=0.75
	outall seed=12345 noprint;
	samplingunit id;
run;

data training; set cdinew;
	where selected = 1;
run;

data holdout; set cdinew;
	where selected = 0;
run;
/* ********Starts here******** */
data training;
infile "/folders/myfolders/200B_DATA/TRAINING.csv" dsd firstobs=2;
input Selected id cty$ state$ area pop 
	pop18 pop65 docs beds crimes hsgrad bagrad poverty unemp pcincome totalinc 
	region popdensity;
	rename popdensity = popden;
	crimesper1000 = 1000*crimes/pop;
run;

data holdout;
infile "/folders/myfolders/200B_DATA/HOLDOUT.csv" dsd firstobs=2;
input Selected id cty$ state$ area pop 
	pop18 pop65 docs beds crimes hsgrad bagrad poverty unemp pcincome totalinc 
	region popdensity;
	rename popdensity = popden;
	crimesper1000 = 1000*crimes/pop;
run;
/* summary statistics of training and testing data */
proc univariate data = training;
	histogram area pop pop18 pop65 docs beds crimesper1000 hsgrad bagrad
	poverty unemp pcincome totalinc popden;
run;

proc freq data = training; tables region; run;

proc univariate data = holdout;
	var area pop pop18 pop65 docs beds crimesper1000 hsgrad bagrad poverty unemp pcincome totalinc popden;
run;

proc univariate data = training;
	var crimesper1000;
run;

proc univariate data = holdout;
	var crimesper1000;
run;

proc freq data = holdout; tables region; run;

/* model transformation */
proc loess data = training;
	model crimesper1000 = area;
run;
data training; set training;
	logcrimes = log2(crimes);
	logarea = log2(area); /*1*/
	logpop = log2(pop); /*2*/
	logpop18 = log2(pop18);
	logpop65 = log2(pop65);
	logdocs = log2(docs); /*3*/
	logbeds = log2(beds); /*4*/
	loghsgrad = log2(hsgrad);
	logbagrad = log2(bagrad); 
	logpoverty = log2(poverty); /*5*/
	logunemp = log2(unemp); 
	logpcinc = log2(pcincome); 
	logtotalinc = log2(totalinc); /*6*/
	logpopden = log2(popden); /*7*/
run;

/* final training set */
data finaltraining; set training;
	drop logcrimes logpop18 logpop65 loghsgrad logbagrad logunemp logpcinc;
	if region = 2 then region2 = 1; else region2 = 0;
	if region = 3 then region3 = 1; else region3 = 0;
	if region = 4 then region4 = 1; else region4 = 0;
run;

ods select histogram;
proc univariate data = training;
	histogram area;
run;
proc loess data = training;
	model crimesper1000 = area;
run;
ods select histogram;
proc univariate data = training;
	histogram logarea / normal;
run;
proc loess data = training;
	model crimesper1000 = logarea;
run;

ods select histogram;
proc univariate data = training;
	histogram pop;
run;
proc loess data = training;
	model crimesper1000 = pop;
run;
ods select histogram;
proc univariate data = training;
	histogram logpop / normal;
run;
proc loess data = training;
	model crimesper1000 = logpop;
run;


proc loess data = training;
	model crimesper1000 = pop18;
run;
ods select histogram;
proc univariate data = training;
	histogram logpop18 / normal;
run;
proc loess data = training;
	model crimesper1000 = logpop18;
run;


proc loess data = training;
	model crimesper1000 = pop65;
run;
ods select histogram;
proc univariate data = training;
	histogram logpop65 / normal;
run;
proc loess data = training;
	model crimesper1000 = logpop65;
run;

ods select histogram;
proc univariate data = training;
	histogram docs;
run;
proc loess data = training;
	model crimesper1000 = docs;
run;
ods select histogram;
proc univariate data = training;
	histogram logdocs /normal;
run;
proc loess data = training;
	model crimesper1000 = logdocs;
run;

ods select histogram;
proc univariate data = training;
	histogram beds;
run;
proc loess data = training;
	model crimesper1000 = beds;
run;
ods select histogram;
proc univariate data = training;
	histogram logbeds / normal;
run;
proc loess data = training;
	model crimesper1000 = logbeds;
run;


proc loess data = training;
	model crimesper1000 = hsgrad;
run;
ods select histogram;
proc univariate data = training;
	histogram loghsgrad /normal;
run;
proc loess data = training;
	model crimesper1000 = loghsgrad;
run;

/* ? */
proc loess data = training;
	model crimesper1000 = bagrad;
run;
ods select histogram;
proc univariate data = training;
	histogram logbagrad / normal;
run;
proc loess data = training;
	model crimesper1000 = logbagrad;
run;

ods select histogram;
proc univariate data = training;
	histogram poverty;
run;
proc loess data = training;
	model crimesper1000 = poverty;
run;
ods select histogram;
proc univariate data = training;
	histogram logpoverty / normal;
run;
proc loess data = training;
	model crimesper1000 = logpoverty;
run;

/* ?? */
proc loess data = training;
	model crimesper1000 = unemp;
run;
ods select histogram;
proc univariate data = training;
	histogram logunemp / normal;
run;
proc loess data = training;
	model crimesper1000 = logunemp;
run;


proc loess data = training;
	model crimesper1000 = pcincome;
run;
ods select histogram;
proc univariate data = training;
	histogram logpcinc / normal;
run;
proc loess data = training;
	model crimesper1000 = logpcinc;
run;

ods select histogram;
proc univariate data = training;
	histogram totalinc;
run;
proc loess data = training;
	model crimesper1000 = totalinc;
run;
ods select histogram;
proc univariate data = training;
	histogram logtotalinc /normal;
run;
proc loess data = training;
	model crimesper1000 = logtotalinc;
run;

ods select histogram;
proc univariate data = training;
	histogram popden;
run;
proc loess data = training;
	model crimesper1000 = popden;
run;
ods select histogram;
proc univariate data = training;
	histogram logpopden / normal;
run;
proc loess data = training;
	model crimesper1000 = logpopden;
run;

/* model selection part */
/* best subset, forward, backward, stepwise, lasso, bivariate p-value */

ods graphics on;
proc glmselect data=finaltraining plots=all;
   class region;
   model crimesper1000 = logarea logpop pop18 pop65 logdocs logbeds hsgrad bagrad logpoverty
   						unemp pcincome logtotalinc region logpopden
                   / selection=forward stat=all;
run;
ods graphics off;
proc reg data=finaltraining; 
	model crimesper1000 = pop18 logdocs logpoverty pcincome region2 region3 region4;
run;


ods graphics on;
proc glmselect data=finaltraining plots=all;
   class region;
   model crimesper1000 = logarea logpop pop18 pop65 logdocs logbeds hsgrad bagrad logpoverty
   						unemp pcincome logtotalinc region logpopden
                   / selection=backward stat=all;
run;
ods graphics off;
proc reg data=finaltraining; 
	model crimesper1000 = logpop pop18 logdocs logpoverty unemp pcincome logtotalinc
			region2 region3 region4;
run;

ods graphics on;
proc glmselect data=finaltraining plots=all;
   class region;
   model crimesper1000 = logarea logpop pop18 pop65 logdocs logbeds hsgrad bagrad logpoverty
   						unemp pcincome logtotalinc region logpopden
                   / selection=stepwise stat=all;
run;
ods graphics off;
proc reg data=finaltraining; 
	model crimesper1000 = pop18 logdocs logpoverty pcincome region2 region3 region4;
run;

ods graphics on;
proc glmselect data=finaltraining plots=all;
   class region;
   model crimesper1000 = logarea logpop pop18 pop65 logdocs logbeds hsgrad bagrad logpoverty
   						unemp pcincome logtotalinc region logpopden
                   / selection=lasso stat=all;
run;
ods graphics off;
proc reg data=finaltraining; 
	model crimesper1000 = pop18 logdocs logbeds logpoverty region2 region3 region4 logpopden;
run;

/* bivariate p-value */
proc reg data = finaltraining;
	model crimesper1000 = logarea;
	output p=p1;
run;
proc reg data = finaltraining;
	model crimesper1000 = logpop;
run;
proc reg data = finaltraining;
	model crimesper1000 = pop18;
run;
proc reg data = finaltraining;
	model crimesper1000 = pop65;
run;
proc reg data = finaltraining;
	model crimesper1000 = logdocs;
run;
proc reg data = finaltraining;
	model crimesper1000 = logbeds;
run;
proc reg data = finaltraining;
	model crimesper1000 = hsgrad;
run;
proc reg data = finaltraining;
	model crimesper1000 = bagrad;
run;
proc reg data = finaltraining;
	model crimesper1000 = logpoverty;
run;
proc reg data = finaltraining;
	model crimesper1000 = unemp;
run;
proc reg data = finaltraining;
	model crimesper1000 = pcincome;
run;
proc reg data = finaltraining;
	model crimesper1000 = logtotalinc;
run;
proc reg data = finaltraining;
	model crimesper1000 = region2 region3 region4;
run;

proc reg data = finaltraining;
	model crimesper1000 = logpopden;
run;

proc reg data=finaltraining;
	model crimesper1000 = logpop pop18 pop65 logdocs logbeds hsgrad logpoverty
			pcincome logtotalinc region2 region3 region4 logpopden;
run;

/* best subset */
proc phreg data=finaltraining;
	model crimesper1000 = logarea logpop pop18 pop65 logdocs logbeds hsgrad bagrad logpoverty
   						unemp pcincome logtotalinc region2 region3 region4 logpopden
   						/ selection=score best=1;
run;

proc reg data=finaltraining;
	model crimesper1000 = logpop pop18 pop65 logbeds bagrad logpoverty 
			logtotalinc region2 region3 region4;
run;

/* a prior */
proc reg data=finaltraining;
	model crimesper1000 = logarea pop18 pop65 hsgrad bagrad logpoverty unemp pcincome 
			region2 region3 region4 logpopden;
run;

/* test error for holdout set */
data holdout; set holdout;
	if region = 2 then region2 = 1; else region2 = 0;
	if region = 3 then region3 = 1; else region3 = 0;
	if region = 4 then region4 = 1; else region4 = 0;
	logarea = log2(area);
	logpop = log2(pop);
	logdocs = log2(docs);
	logbeds = log2(beds);
	logpoverty = log2(poverty);
	logtotalinc = log2(totalinc);
	logpopden = log2(popden);
	
	yhat_prior = -192.69953+3.98*logarea+1.35*pop18+0.29*pop65+0.22*hsgrad-0.28*bagrad+18.67*logpoverty
	+0.51*unemp+0.002*pcincome+12.32*region2+25.83*region3+16.45*region4+6.05*logpopden;
	
	yhat_best = 85.22482-30.2*logpop+1.34*pop18+0.002*pop65+3.65*logbeds-0.33*bagrad+16.8*logpoverty
	+31.5*logtotalinc+12.07*region2+26.83*region3+17.31*region4;
	
	yhat_forward = -92.29214+0.84*pop18+5.14*logdocs+15.92*logpoverty+0.001*pcincome+12.65*region2+24.78*region3+13.85*region4;
	
	yhat_backward = 378.82395-67.79*logpop+1.01*pop18+5.16*logdocs+15.89*logpoverty+1.17*unemp-0.003*pcincome
	+66.91*logtotalinc+12.85*region2+27.05*region3+15.52*region4;
	
	yhat_step = yhat_forward;
	
	yhat_lasso = -80.45022+0.8*pop18+3.53*logdocs+1.82*logbeds+11.86*logpoverty+11.68*region2+24.79*region3+17.03*region4+1.97*logpopden;
	
	yhat_p = 375.69458-63.75*logpop+1.0*pop18-0.01*pop65+2.55*logdocs+1.95*logbeds-0.28*hsgrad+15.43*logpoverty-0.003*pcincome+62.51*logtotalinc
	+12.08*region2+25.78*region3+19.25*region4+1.52*logpopden;
run;

data holdout; set holdout;
	err_prior = (crimesper1000-yhat_prior)**2;
	err_best = (crimesper1000-yhat_best)**2;
	err_forward = (crimesper1000-yhat_forward)**2;
	err_backward = (crimesper1000-yhat_backward)**2;
	err_step = (crimesper1000-yhat_step)**2;
	err_lasso = (crimesper1000-yhat_lasso)**2;
	err_p = (crimesper1000-yhat_p)**2;
run;

proc means data = holdout sum mean;
	var err_prior err_best err_forward err_backward err_step err_lasso err_p;
run;

proc means data = holdout mean;
	var crimesper1000;
run;

/* drop outliers */
data testing; set holdout;
	if id = 6 then delete;
run;

proc means data = testing mean sum;
	var crimesper1000 err_prior err_best err_forward err_backward err_step err_lasso err_p;
run;

























