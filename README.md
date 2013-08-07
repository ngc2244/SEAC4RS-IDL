SEAC4RS-IDL, by Jenny Fisher and Lei Zhu, 08/06/2013

Purpose:
SEAC4RS-IDL contains IDL scripts for creating, processing, and analysing aircraft data and GEOS-Chem output from the SEAC4RS campaign.

Instructions for set up:
1. You will need to include a line in your idl_startup.pro that defines the !SEAC4RS system variable. 
This is done using the following syntax:
SEAC4RS = '/home/username/yourpath/SEAC4RS'
DefSysV, '!SEAC4RS',Exists=Exists
if (not Exists ) then DefSysV,'!SEAC4RS',SEAC4RS

You may also want to add this path to the default IDL search path using
Pref_Set, 'IDL_PATH', Expand_Path('+!SEAC4RS/IDL/', /All_Dirs ) + SEP + '<IDL_DEFAULT>', /Commit

2. Also you need to update IDL/gamap2/gamap_util/ctm_read_planeflight.pro as below:

   ARRSIZE  = 2000L ; Increased by lei, 07/19/13
   VARSIZE  = 150L  ; Increased by lei, 07/23/13, as we have more tracers

   ; Change the format based on planeflight_mod.F, Line 1643
   ; Changed by Lei, 130630
   Fmt = '(6X,A5,X,I8.8,X,I4.4,X,F7.2,X,F7.2,X,F7.2,X,'+ $
          String( N_Data ) + '(e11.3,X))'

3. Make sure you have cdh_tools in your IDL folder, see: /home/lei/IDL/cdh_tools/. We will use several functions from cdh_tools, for example, tapply.pro, mean_nan.pro, scatterplot_datacolor.pro and scatterplot.pro.
You can add a line for IDL_PATH in your idl_startup.pro

   Expand_Path( '+~/IDL/cdh_tools/',/All_Dirs ) + Sep + $

4. Use updated tracerinfo.dat. And change the default tracerinfo.dat path in planelog2flightmerge.pro (Line 109)

      ; Use READ_PLANEFLIGHT_AND_TRACERINFO in order to get standard GEOS-Chem
      ; tracer names rather than default ND40 names
      PLANE = READ_PLANEFLIGHT_AND_TRACERINFO( thisfile,$
      !SEAC4RS+'/IDL/planelog2sav/tracerinfo.dat')

5. You will also need to keep your aircraft & model data in the outer IDL directory in the following structure: 

!SEAC4RS/
   IDL/        -- This folder
   gc_data/    -- model output 
   field_data/ -- field measurement
     DC8/ 
       merge_60s/             -- one-minute merged aircraft data 
       merge_10m_0.25x0.3125/ -- merged aircraft data averaged to GEOS-Chem resolution
     ER2/ 
       merge_60s/             -- one-minute merged aircraft data 
       merge_10m_0.25x0.3125/ -- merged aircraft data averaged to GEOS-Chem resolution
       
These data are not included here as they are not currently publicly released.
