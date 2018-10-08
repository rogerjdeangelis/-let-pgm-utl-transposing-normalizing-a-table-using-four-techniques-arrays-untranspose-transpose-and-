Transposing normalizing a table using four techniques arrays untranspose transpose and gather

github
https://tinyurl.com/y9z5q29m
https://github.com/rogerjdeangelis/utl-transposing-normalizing-a-table-using-four-techniques-arrays-untranspose-transpose-and-gather

https://tinyurl.com/y8caphtm
https://communities.sas.com/t5/SAS-Programming/Need-help-on-TRANSPOSE/m-p/502341

Kurt Bremser
https://communities.sas.com/t5/user/viewprofilepage/user-id/11562

             1. Untranspose - requires renaming ( Arthur Tabachneck, Gerhard Svolba, Joe Matise and Matt Kastin)
             2. Double transpose
             3. Gather macro
             4. Array - Kurt Bremser

INPUT
=====

40 obs from HAVE total obs=3

 LT_DATETIME  LP_DATETIME  SP_DATETIME  ST_DATETIME ID  LT_MVA  LT_MWA  LP_MVA  LP_MWA  ST_MVA  ST_MWA  SP_MVA  SP_MWA

  21JAN2018    17FEB2018    20MAR2018    04MAR2018   1    11      12      13      14      15      16      17      18
  21JAN2017    17FEB2017    20MAR2017    07MAR2017   2    11      12      13      14      15      16      17      18
  21JAN2016    17FEB2016    20MAR2016    09MAR2016   3    11      12      13      14      15      16      17      18



EXAMPLE OUTPUT
--------------

 WORK.WANT total obs=12

 ID    PROFILE     DATETIME     MVA    MWA

  1      lt       1832112000     11     12
  1      lp       1834489800     13     14
  1      sp       1837144800     15     16
  1      st       1835757000     17     18

  2      lt       1800612000     11     12
  2      lp       1802921400     13     14
  2      sp       1805610600     15     16
  2      st       1804473000     17     18

  3      lt       1768978800     11     12
  3      lp       1771313400     13     14
  3      sp       1774080000     15     16
  3      st       1773129600     17     18


PROCESS
=======

1. Untranspose - requires renaming
----------------------------------

* handles mixures of numeric and character variable!!;
%untranspose(data=%str(have(rename= (
      LT_DATETIME = DATETIME_1
      LP_DATETIME = DATETIME_2
      SP_DATETIME = DATETIME_3
      ST_DATETIME = DATETIME_4
      LT_MVA      = MVA_1
      LP_MVA      = MVA_2
      ST_MVA      = MVA_3
      SP_MVA      = MVA_4
      LT_MWA      = MWA_1
      LP_MWA      = MWA_2
      ST_MWA      = MWA_3
      SP_MWA      = MWA_4)))
   , out=want,  by=id, id=index, delimiter=_, var=datetime mva mwa);


2. Double transpose
-------------------

proc transpose data=have out=havXpo(where=(_name_ ne 'ID'));
  by id;
  var _all_;
run;quit;

proc sql;
  create
     view havVue as
  select
     id
    ,scan(_name_,1,'_') as pfx
    ,scan(_name_,2,'_') as var
    ,col1 as val
  from
    havXpo
  order
    by id, pfx, var
;quit;

proc transpose data=havVue out=want(drop=_name_);
  by id pfx;
  id var;
  var val;
run;quit;


3. Gather macro
---------------

%utl_gather(have,var,val,id,havXpo,valFormat=best.);

proc sql;
  create
     view havVue as
  select
     id
    ,scan(var,1,'_') as pfx
    ,scan(var,2,'_') as var
    ,val
  from
    havXpo
  order
    by id, pfx, var
;quit;

proc transpose data=havVue out=want(drop=_nam_);
  by id pfx;
  id var;
  var val;
run;quit;


4. Array
--------

data want (
  keep=id profile datetime mva mwa
);
set wide;
array dt{4} lt_datetime lp_datetime sp_datetime st_datetime;
array mv{4} lt_mva lp_mva st_mva sp_mva;
array mw{4} lt_mwa lp_mwa st_mwa sp_mwa;
array prof{4} $ _temporary_ ('lt','lp','sp','st');
do i = 1 to 4;
  profile = prof{i};
  datetime = dt{i};
  mva = mv{i};
  mwa = mw{i};
  output;
end;
format datetime datetime19.;
run;

