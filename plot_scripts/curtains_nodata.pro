; $Id: seac4rs_obs_mod_curtains.pro,v 1.4 2008/07/07 17:15:45 jaf Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SEAC4RS_OBS_MOD_CURTAINS
;
; PURPOSE:
;	 Make plots of the SEAC4RS aircraft data along the flight
;	 track (with altitude as the y-axis), the GEOS-Chem model
;	 output along the flight track, and a "curtain" showing
;	 GEOS-Chem output at all altitudes along the latitude &
;	 longitude coordinates of the flight.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        SEAC4RS_OBS_MOD_CURTAINS, Species_In, Platform, DiagN,
;	 			  Tracer[, Keywords] 
;
; INPUTS:
;	 Species_In - Name of observation variable. e.g. 'CO','ALTP'
;			Default is 'CO'.
;	 Platform   - Name of aircraft. Current options: 'DC8','ER2'
;			Default is 'DC8'.
;	 DiagN      - Name of GEOS-Chem diagnostic. e.g. 'IJ-AVG-$'	
;	 Tracer     - Number of GEOS-Chem tracer. e.g. 4 (for CO)
;
; KEYWORD PARAMETERS:
;	 Flightdates - Date of takeoff as 'YYYYMMDD'. Only one date
;		       can be used.
;			Default is '20130806'.
;	 fscale      - Scale factor for the GEOS-Chem timeseries
;		       files used to make the curtains. Most data
;		       are stored in ppbv, so use fscale to convert
;		       to different units for plotting.
;			Default is 1.
;	 MinData     - Minimum to use when plotting data.
;			Default is Min(Data)
;	 MaxData     - Maximum to use when plotting data.
;			Default is Max(Data)
;	 mMinData    - Minimum to use when plotting model output.
;			Default is MinData
;	 mMaxData    - Maximum to use when plotting model output.
;			Default is MaxData
;	 Unit        - Units of the data to be plotted.
;	 Ztop        - Uppermost altitude (in km) for the curtains.
;	 OPlot_Data  - If set, the observed data from the DC8 will
;		       be plotted on top of the curtain.
;        Obs_Only    - Set to only plot observed values.
;
; OUTPUTS:
;	None
;
; SUBROUTINES:
;	None
;
; REQUIREMENTS:
;	GET_MODEL_DATA_SEAC4RS
;	GET_FIELD_DATA_SEAC4RS
;	SCATTERPLOT_DATACOLOR
;	TVCURTAIN
;	Several Gamap2 routines
;
; NOTES:
;	If no model diagnostics are available for the specified
;	species, the routine will stop after the observations are plotted.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        jaf, 13 May 2008: VERSION 1.00
;        jaf,  5 Aug 2013: Updated for SENEX/SEAC4RS
;
;-
; Copyright (C) 2008, Jenny Fisher, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to jaf@io.as.harvard.edu
; with subject "IDL routine seac4rs_obs_mod_curtains"
;-----------------------------------------------------------------------

; We need Construct_Map_Labels, so compile Map_Labels
@map_labels

pro curtains_nodata, species_in, diagn, tracer,          $
                            flightdates = flightdates, fscale   = fscale,  $
                            mindata     = mindata,     maxdata  = maxdata, $
                            mmindata    = mmindata,    mmaxdata = mmaxdata,$
                            unit        = unit,        ztop     = ztop,    $
			    oplot_data  = oplot_data,  aod      = aod,     $
                            obs_only    = obs_only,    _extra   = _extra
 
; Set default values if parameters / keywords aren't specified 
if N_Elements(species_in) eq 0 then begin
   species_in='CO'
   tracer=4
endif
if N_Elements(flightdates) eq 0 then flightdates='20130806'
if N_Elements(fscale) eq 0 then fscale = 1
if N_Elements(ztop) eq 0 then ztop = 12
if N_Elements(unit) eq 0 then unit = ''

;---------------------------------------------------------------------------
;  Plot GEOS-Chem cross-section (curtain) along flight track
;---------------------------------------------------------------------------
; Specify filename for timeseries files
tsfi = '/as/scratch/bmy/NRT/run.NA/timeseries/ts'+$
;tsfi = '/as/cache/2013-08/bmy/NRT_archive/NA_ts/ts'+$
;tsfi = '/home/skim/SEAC4RS_Mission_Code/NRT/run.NA/timeseries/ts'+$
       flightdates+'.bpch'

; Specify relevant time, lat, lon
hhmm=[1500,1527,1727]
lat=[29.6,30.41,33.0]
lon=[-95.17,-98.58,-116.0]

hh=(hhmm/100)
mm=hhmm-hh

time=hh*3600.+mm*60.

; interpolate to have a few more points so it's less choppy...
lat=interpol(lat,20)
lon=interpol(lon,20)
time=interpol(time,20)

nday1=n_elements(time)-1

; Get timeseries data

; Special handling for AOD
if keyword_set(AOD) then begin
   DIAGN='OD-MAP-$'
   ctm_get_data, datainfo, DiagN, filename = tsfi, tracer = 6
   ctm_get_data, datainfo1, DiagN, filename = tsfi, tracer = 9
   ctm_get_data, datainfo2, DiagN, filename = tsfi, tracer = 12
   ctm_get_data, datainfo3, DiagN, filename = tsfi, tracer = 15
   ctm_get_data, datainfo4, DiagN, filename = tsfi, tracer = 18
   ctm_get_data, datainfo5, DiagN, filename = tsfi, tracer = 4
endif else ctm_get_data, datainfo, DiagN, filename = tsfi, tracer = tracer
; nBlks is the number of blocks (nominally, one for every time)
nBlks = n_elements(datainfo)

; For SEAC4RS, only the North American region is saved in the
; timeseries files, so the indexing doesn't match the default
; indexing in gamap routines. The first index in each dimension is
; saved in datainfo.first, so this is a generic way of finding
; the first index for both the longitude and latitude dimensions.
; iFirst is the first index in the longitude dimension. We subtract
; 1 so that this matches IDL indexing (starting at 0).
iFirst=DataInfo[0].first[0]-1
; jFirst is the first index in the latitude dimension.
jFirst=DataInfo[0].first[1]-1

; Extract grid information. 
GetModelAndGridInfo,DataInfo[0],ModelInfo,GridInfo

; Find the index of the vertical gridbox nearest to the top of the
; domain, specified by ztop.
near_z = Min(abs(gridinfo.zmid-ztop),iztop)
zmid = GridInfo.zmid(0:iztop)

; Find xdim and ydim, the total size of the longitude and latitude
; dimensions, respectively
temp = *(datainfo(0).data)
temp = size(temp, /dimensions)
xdim = temp(0)
ydim = temp(1)

; Get the longitudes included in the domain
lon_mod = GridInfo.xmid(iFirst:xdim+iFirst-1)

; Get the latitudes included in the domain
lat_mod = GridInfo.ymid(jFirst:ydim+jFirst-1)
 
; Get the UTC for each record in the timeseries files (in units of hour)
UTC = dblarr( nBlks )
for i = 0, nBlks-1 do begin
   UTC[i] = datainfo[i].tau0 - nymd2tau( long(flightdates) )
endfor
 
; Loop over the 1-min observations for the first day.
  for i = 0, nDay1 do begin
 
    ; Extract the sampled vertical profile by finding the index
    ; of the nearest model lon, lat, and time
    near_time = Min(Abs(UTC - Time[i]),j)
    near_lat  = Min(Abs(lat_mod - Lat[i]), jj)
    near_lon  = Min(Abs(lon_mod - Lon[i]), ii)
    ; Special handling for AOD
    if keyword_set(AOD) then $
       array = *( datainfo[j].data ) + *( datainfo1[j].data ) + $
               *( datainfo2[j].data ) + *( datainfo3[j].data ) + $
               *( datainfo4[j].data ) + *( datainfo5[j].data ) else $
       array = *( datainfo[j].data )
    ; Scale the profile by fscale to get the units right
    array = array * fscale
    ; Using only the data up to ztop, save the profile
    profile = reform( array(ii, jj, 0:iztop))
 
    ; Combine vertical profiles into a cross-section
    if ( i eq 0 ) then begin
      curtain = transpose( profile )
    endif else begin
      curtain = [curtain, transpose( profile ) ]
   endelse
 
  endfor  ; End of loop over # of 1-min samples for Day 1

; If the flight spans 2 UTC days, repeat the process 
if N_Elements(nDay2) ne 0 then begin
   ; Increment the flightdate by 1 in the timeseries filename
   tsfi = '/as/scratch/bmy/NRT/run.NA/timeseries/ts'+$
     string(long(flightdates)+1, format = '(i8.8)')+'.bpch'
   ; Get timeseries data
   ; Special handling for AOD
   if keyword_set(AOD) then begin
      DIAGN='OD-MAP-$'
      ctm_get_data, datainfo, DiagN, filename = tsfi, tracer = 6
      ctm_get_data, datainfo1, DiagN, filename = tsfi, tracer = 9
      ctm_get_data, datainfo2, DiagN, filename = tsfi, tracer = 12
      ctm_get_data, datainfo3, DiagN, filename = tsfi, tracer = 15
      ctm_get_data, datainfo4, DiagN, filename = tsfi, tracer = 18
      ctm_get_data, datainfo5, DiagN, filename = tsfi, tracer = 4
   endif else ctm_get_data, datainfo, DiagN, filename = tsfi, tracer = tracer
   nBlks = n_elements(datainfo)
 
   ; Get UTC for each data record
   UTC = dblarr( nBlks )
   for i = 0, nBlks-1 do begin
      UTC[i] = datainfo[i].tau0 - nymd2tau( long(flightdates)+1 )
   endfor
 
   ; Loop over # of 1-min samples
   for i = nDay1+1, nDay2 do begin
 
      ; Extract sampled vertical profile
      near_time = Min(Abs(UTC - Time[i]),j)
      near_lat  = Min(Abs(lat_mod - Lat[i]), jj)
      near_lon  = Min(Abs(lon_mod - Lon[i]), ii)
       ; Special handling for AOD
       if keyword_set(AOD) then $
          array = *( datainfo[j].data ) + *( datainfo1[j].data ) + $
                  *( datainfo2[j].data ) + *( datainfo3[j].data ) + $
                  *( datainfo4[j].data ) + *( datainfo5[j].data ) else $
          array = *( datainfo[j].data )
      ; Scale data by fscale
      array = array * fscale
      ; Reform relevant part of profile
      profile = reform( array(ii, jj, 0:iztop))
 
      ; Combine vertical profiles into a cross-section 
      curtain = [curtain, transpose( profile ) ]
      
   endfor  ; End of loop over # of 1-min observations for Day 2 
   
endif
 
ytitle = 'Pressure Altitude (km)'
title = 'GEOS-CHEM '+Species_in +' ' + Unit

; Plot curtain using TVCURTAIN 
tvcurtain, curtain, lat, lon, zmid, /ystyle, color = 1, $
           mindata=mmindata, maxdata=mmaxdata, ytitle=ytitle, title=title,$
	   /FlightTrack, FlightZ=altp, /CBar,/CBVertical,/NoAdvance
 
 
end
