; $Id: seac4rs_model_map.pro,v 1.7 2008/07/06 17:07:19 jaf Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SEAC4RS_MODEL_MAP
;
; PURPOSE:
;        Plot modeled concentration of a given species within a specified
;        altitude range on a domain appropriate for the SEAC4RS missions.
;        Observed data can be overplotted.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        SEAC4RS_MODEL_MAP,Species,Platform[,Keywords]
;
; INPUTS:
;        Species  - Name of species being mapped. e.g. 'CO', 'O3', 'ALTP'
;        Platform - Name of Aircraft. Current options: 'DC8'
;
; KEYWORD PARAMETERS:
;        FlightDates - Dates (as takeoff dates) as 'YYYYMMDD'. Can only
;                      accept single flight date.
;        Alt         - Altitude range. Use this keyword to only plot
;                      data that falls within this range of altitudes.
;        MinData     - Minimum value to use when plotting species.
;        MaxData     - Maximum value to use when plotting species.
;        OPlot_Data  - If set, observed values will be plotted over
;                      model background
;        Save        - If set, map will be saved as a postscript rather
;                      than plotted on the screen
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        GET_FIELD_DATA_SEAC4RS
;
; NOTES:
;
; EXAMPLE:
;    SEAC4RS_MODEL_MAP,'CO','DC8',FlightDates='20130806', $
;                      MinData=0, MaxData=200,/OPlot_Data
;
;    Plots modeled CO for 20130806, with observations on top.
;
; MODIFICATION HISTORY:
;        jaf, 9 Aug 2013: VERSION 1.00
;-
; Copyright (C) 2013, Jenny Fisher, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
;-----------------------------------------------------------------------

pro nh3_emis,type, mindata=mindata,maxdata=maxdata, region=region,$
		   limit=limit,save=save,_extra=_extra

   ; Set defaults
   if n_elements(type)  eq 0 then type='anth'
   case strlowcase(type) of
       'anth': diagn='NH3-ANTH'
       'natu': diagn='NH3-NATU'
       'biob': diagn='NH3-BIOB'
       'biof': diagn='NH3-BIOF'
       'anth_natu': diagn=['NH3-ANTH','NH3-NATU']
       else  : begin
          print,'type not found'
          return
          end
   endcase
   ; All dates have same emissions, so just read one to get total

   if n_elements(region) gt 0 and n_elements(limit) gt 0 then begin
     print,'Specify region or limit but not both!'
     return
   endif

   if (n_elements(region) eq 0) then region=''
   if n_elements(limit) eq 0 then begin
   case strlowcase(region) of
     'west'     : limit=[30,-127,50,-110]
     'w'        : limit=[30,-127,50,-110]
     'southeast': limit=[25,-100,40,-75]
     'se'       : limit=[25,-100,40,-75]
     'northeast': limit=[35,-95,50,-65]
     'ne'       : limit=[35,-95,50,-65]
     'na'       : limit=[9,-130,60,-60]
     else:      limit=[25,-127,50,-65]
   endcase
   endif

   ; NRT Directory
   dir = '/as/scratch/bmy/NRT/run.NA/bpch/'
   file = dir + 'ctm.bpch.20130814'

   if (mfindfile(file))[0] eq '' then begin
       print,'File '+file+' not found!'
       return
   endif
   
   ; Read model fields
   for d=0,n_elements(diagn)-1 do begin
      ctm_get_data,  DataInfo, DiagN[d], filename=file,  tracer=30
      if ( d eq 0 ) then emiss = *(DataInfo.Data) else emiss = emiss + *(DataInfo.Data)
   endfor

   ; Get grid information
   GetModelAndGridInfo, DataInfo, ModelInfo, GridInfo
   iFirst = (DataInfo.First[0])[0]-1 ; from Fortran --> IDL notation
   jFirst = (DataInfo.First[1])[0]-1
   NX = (DataInfo.Dim[0])[0]
   NY = (DataInfo.Dim[1])[0]
   XX = GridInfo.XMid
   YY = GridInfo.YMid
   ZZ = GridInfo.ZMid

   ; Convert to Fabien's units: kg(NH3-N)/ha/month
   unit = 'kg(NH3-N)/ha/month'
   area_km2 = ctm_boxsize(GridInfo)
   area_ha = area_km2 * 1d2
   area_ha = area_ha[iFirst:iFirst+NX-1,*]
   area_ha = area_ha[*,jFirst:jFirst+NY-1]
   days_per_month = 31d0
   N_per_NH3 = 14./17.

   Emiss = Emiss * N_per_NH3 * days_per_month / area_ha

   ; Set plot parameters
   dcolor = [0,0.1,0.25,0.5,0.75,1,1.25]
   ncol   = n_elements(dcolor)

   Title='August NH3 emissions'

   cbformat='(f4.1)'

   ; Plot model as background
   myct, /whgrylrd, ncolors = 30
   tvmap, Emiss, XX[iFirst:iFirst+NX-1], YY[jFirst:jFirst+NY-1], $
          /isotropic, /USA, limit=limit, $
          /fcontour, /continents, /noadvance, title=title,       $
  	  cbunit=unit,/cbar, c_levels=dcolor,$
          cbformat=cbformat,div=5,_extra=_extra

stop
end

