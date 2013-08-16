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

pro seac4rs_model_map,species_in,platform,flightdates=flightdates,alts=alts, $
		    mindata=mindata,maxdata=maxdata, unit=unit,region=region,$
		    oplot_data=oplot_data,save=save,fscale=fscale,_extra=_extra

   ; Set defaults
   if n_elements(species_in)  eq 0 then species_in='CO'
   if n_elements(platform)    eq 0 then platform='DC8'
   if n_elements(flightdates) eq 0 then flightdates='20130806'
   if (strpos(flightdates,'*') ge 0) or (n_elements(flightdates) gt 1) then begin
      print,'Must specify a single date!'
      return
   endif
   if n_elements(alts) eq 0 then alts=[0,12]
   if n_elements(fscale) eq 0 then fscale=1
   if (n_elements(region) eq 0) then region=''

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

   ; NRT Directory
   dir = '/as/scratch/bmy/NRT/run.NA/bpch/'

   ; Special treatment for SEAC4RS (jaf, 8/16/13)
   ; Files with name YYYYMMDD mostly contain data for the next date
   ; (21 UTC on YYYYMMDD to 21 UTC on YYYYMMDD+1). Here use previous 
   ; file (day before flightdate) to get most approrpiate information.
   fd_file = string(long(flightdates)-1L,'(i8)')

   ; Test for zipped/unzipped file
   file = dir + 'ctm.bpch.'+fd_file
   Zipped = 0

   if (mfindfile(file))[0] eq '' then begin
      if (mfindfile(file+'.gz'))[0] eq '' then begin
          print,'File '+file+' not found (zipped or unzipped)!'
          return
      endif else begin

          ; Set keyword
          Zipped=1

          ; Unzip file
          s = 'spawn, ''gunzip '+file+'.gz'
          status = execute(s)
      endelse
   endif
   
   ; Pick tracer using names from tracerinfo.dat
   TracerN = indgen(80)+1 ; 80 tracers hardwired for SEAC4RS
   tracerinfo_file = !SEAC4RS+'/IDL/tracerinfo.dat'
   ctm_tracerinfo, TracerN, TracerStruct, filename=tracerinfo_file
   TracerName = TracerStruct.name
   Tracer = TracerN[where( strlowcase(TracerName) eq strlowcase(species_in) )]

   ; Read model fields
   ctm_get_data,  DataInfo, 'IJ-AVG-$', filename=file,  tracer=tracer
   Species_Mod = *(DataInfo.Data) * fscale

   ; Get grid information
   GetModelAndGridInfo, DataInfo, ModelInfo, GridInfo
   iFirst = (DataInfo.First[0])[0]-1 ; from Fortran --> IDL notation
   jFirst = (DataInfo.First[1])[0]-1
   NX = (DataInfo.Dim[0])[0]
   NY = (DataInfo.Dim[1])[0]
   XX = GridInfo.XMid
   YY = GridInfo.YMid
   ZZ = GridInfo.ZMid

   ; Subselect relevant altitudes
   ZInd = where(ZZ ge min(alts) and ZZ le max(alts))
   if n_elements(zind) eq 1 then $
   Species_Mod = Species_Mod[*,*,ZInd] else $
   Species_Mod = mean(Species_Mod[*,*,ZInd],3)

   ; Set plot parameters
   if n_elements(mindata) eq 0 then mindata=min(Species_Mod)
   if n_elements(maxdata) eq 0 then maxdata=max(Species_Mod)
   dcolor = (maxdata-mindata)/20.

   Title=strupcase(species_in)+', '+string(min(alts),'(f4.1)')+' - '+$
         string(max(alts),'(f4.1)')+' km, '+flightdates

   if ( maxdata/10. gt 5 ) then cbformat='(i)' else $
      cbformat='(f4.1)'
   if n_elements(unit) eq 0 then unit=''

; Fix this later (jaf, 8/9/13)
;   if keyword_set(save) then begin
;	filename='model_CO_L'+string(level,'(i2.2)')+'_'+date+'.ps'
;        multipanel,rows=2,cols=1
;        open_device, /ps, filename=filename, Bits=8, $
;                WinParam = [0, 300,400], /color, /portrait
;        !p.font = 0 
;   endif else window,0

   ; Plot model as background
   myct, 33, ncolors = 30
   tvmap, Species_Mod, XX[iFirst:iFirst+NX-1], YY[jFirst:jFirst+NY-1], $
          /isotropic, /USA, limit=limit, $
          /fcontour, /continents, /noadvance, title=title,       $
  	  cbunit=unit,/cbar, c_levels=indgen(20)*dcolor+mindata, $
          cbformat=cbformat,_extra=_extra

   ; If needed, read and plot observations during flight
   if Keyword_Set(oplot_data) then begin

      species = get_field_data_seac4rs(species_in,platform,flightdates,$
                                     _extra=_extra)
      lat = get_field_data_seac4rs('lat',platform,flightdates,$
                                  _extra=_extra)
      lon = get_field_data_seac4rs('lon',platform,flightdates,$
                                  _extra=_extra)
      alt_data = get_field_data_seac4rs('altp',platform,flightdates,$
                                  _extra=_extra)

      if ~finite(mean_nan(species)) then begin
         print,'No data for species '+species+' on '+flightdates
         goto, nodata
      endif

      ; Select data in the correct alt range
      index = where( alt_data ge min(alts) and alt_data le max(alts) )
      species = species[index]
      lat     = lat[index]
      lon     = lon[index]

      ; Add to map
      scatterplot_datacolor,lon,lat,species,/overplot,zmin=mindata,$
         zmax=maxdata,/xstyle,/ystyle,/nocb,_extra=_extra

   nodata:
   endif

;   if keyword_set(save) then close_device

   ; If necessary, re-zip file
   if keyword_set(Zipped) then begin
      s = 'spawn, ''gzip '+file
      status = execute(s)
   endif

end

