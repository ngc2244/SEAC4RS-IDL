; $Id$
;-----------------------------------------------------------------------
;+
; NAME:
;        SEAC4RS_PM_PROFILES
;
; PURPOSE:
;	 Plot average vertical profiles for observed PM during SEAC4RS
;	 along with GEOS-Chem PM components.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        SEAC4RS_PM_PROFILES [, KEYWORDS]
;
; INPUTS:
;	 None
;
; KEYWORD PARAMETERS:
;        FLIGHTDATES - one or multiple flight dates (default all)
;        MINDATA     - minimum value for x-axis (called with MAXDATA)
;        MAXDATA     - maximum value for x-axis (called with MINDATA)
;        CHOOSE_WIN  - used to plot in an IDL window besides 0
;	 LATRANGE    - specifies min,max of latitude values to include
;	 LONRANGE    - specifies min,max of lonitude values to include
;        SAVE        - set this keyword to save figure
;
; OUTPUTS:
;	 NONE
;
; SUBROUTINES:
;	 Various SEAC4RS, GAMAP scripts
;
; REQUIREMENTS:
;	 Various SEAC4RS, GAMAP scripts
;
; NOTES:
;
; EXAMPLE:
;        seac4rs_pm_profiles,flightdates='2013*'
;
; MODIFICATION HISTORY:
;        jaf, 09 Aug 2013: VERSION 1.00
;
;-
; Copyright (C) 2013, Jenny Fisher, University of Wollongong
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to jennyf@uow.edu.au
; with subject "IDL routine seac4rs_pm_profiles"
;-----------------------------------------------------------------------

pro seac4rs_pm_profiles,flightdates=flightdates,altrange=altrange,$
	mindata=mindata,maxdata=maxdata,choose_win=choose_win,$
	latrange=latrange,lonrange=lonrange,save=save,model_only=model_only,$
	obs_only=obs_only,mod_comp=mod_comp,nmol=nmol,_extra=_extra
 
; Set defaults
if N_Elements(flightdates) eq 0 then begin
        flightdates='2013*'
        print, $
	'You didn''t specify flightdates, so all dates are being plotted!'
	flightdates=get_model_data_seac4rs('FLIGHTDATE','DC8',flightdates)
	flightdates = flightdates(uniq(flightdates))
	flightdates = string(flightdates, '(i8.8)')
endif
if n_elements(altrange) eq 0 then altrange=[0,10]
if n_elements(nmol) eq 0 then nmol=0
 
; Initialize arrays
; basic info
altp=[0]
lat=[0]
lon=[0]
doy=[0]

; obs
so4=[0]
nh4=[0]
no3=[0]
oa =[0]

doy_mod=[0]
so4_mod=[0]
nh4_mod=[0]
no3_mod=[0]
oa_mod =[0]
 
; Read data
for i = 0, n_elements(flightdates)-1 do begin

   if ~keyword_set(model_only) then begin
      so4 = [so4,get_field_data_seac4rs('ams_so4','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
      nh4 = [nh4,get_field_data_seac4rs('ams_nh4','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
      no3 = [no3,get_field_data_seac4rs('ams_no3','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
      oa =  [oa, get_field_data_seac4rs('oa','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
    
      ; Read other relevant variables
      altp = [altp,get_field_data_seac4rs('altp','DC8',flightdates[i], $
                                       _extra = _extra )]
      lat =  [lat,get_field_data_seac4rs('lat','DC8',flightdates[i], $
                                       _extra = _extra)]
      lon =  [lon,get_field_data_seac4rs('lon','DC8',flightdates[i], $
                                       _extra = _extra)]
      doy =  [doy,get_field_data_seac4rs('doy','DC8',flightdates[i], $
                                      _extra = _extra )]
   endif else begin
      altp = [altp,get_model_data_seac4rs('alt','DC8',flightdates[i], $
                                       _extra = _extra )]
      lat =  [lat,get_model_data_seac4rs('lat','DC8',flightdates[i], $
                                       _extra = _extra)]
      lon =  [lon,get_model_data_seac4rs('lon','DC8',flightdates[i], $
                                       _extra = _extra)]
      doy =  [doy,get_model_data_seac4rs('doy','DC8',flightdates[i], $
                                      _extra = _extra )]
   endelse
 
   if ~keyword_set(obs_only) then begin
      ; Read relevant model variables
      doy_mod = [doy_mod, $
   	get_model_data_seac4rs('DOY','DC8',flightdates[i], $
                               _extra = _extra )]
      ; model PM components 
      so4_mod = [so4_mod,get_model_data_seac4rs('so4','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
      nh4_mod = [nh4_mod,get_model_data_seac4rs('nh4','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
      no3_mod = [no3_mod,get_model_data_seac4rs('no3','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
      oa_mod  = [oa_mod, get_model_data_seac4rs('oa','DC8',flightdates[i], $
                                         nmol=nmol,_extra = _extra) ]
   endif
 
endfor
 
; Remove placeholder
altp = altp[1:*]
lat  = lat[1:*]
lon  = lon[1:*]
doy  = doy[1:*]
 
; Fix longitudes
lon[where(lon gt 180)]=lon[where(lon gt 180)]-360.
 
if ~keyword_set(model_only) then begin
   so4 = so4[1:*]
   nh4 = nh4[1:*]
   no3 = no3[1:*]
   oa  =  oa[1:*]
   tot_pm = so4+nh4+no3+oa
endif
if ~keyword_set(obs_only) then begin
   doy_mod = doy_mod[1:*]
   so4_mod = so4_mod[1:*]
   nh4_mod = nh4_mod[1:*]
   no3_mod = no3_mod[1:*]
   oa_mod  =  oa_mod[1:*]
   
   ; Interpolate model to observed space
   so4_mod = interpol( so4_mod, doy_mod, doy )
   nh4_mod = interpol( nh4_mod, doy_mod, doy )
   no3_mod = interpol( no3_mod, doy_mod, doy )
   oa_mod  = interpol( oa_mod,  doy_mod, doy )
   tot_pm_mod = so4_mod+nh4_mod+no3_mod+oa_mod
endif
 
; Subselect relevant region, finite data
if ~keyword_set(model_only) then begin
if ( n_elements(lonrange) gt 0 and n_elements(latrange) gt 0 ) then begin
   index = where( finite(tot_pm)                                 and $
		  (lat ge min(latrange) and lat le max(latrange)) and $
		  (lon ge min(lonrange) and lon le max(lonrange))     )
endif else if ( n_elements(lonrange) gt 0 ) then begin
   index = where( finite(tot_pm)                                 and $
		  (lon ge min(lonrange) and lon le max(lonrange))     )
endif else if ( n_elements(latrange) gt 0 ) then begin
   index = where( finite(tot_pm)                                 and $
		  (lat ge min(latrange) and lat le max(latrange))     )
endif else index = where(finite(tot_pm))
endif else begin
if ( n_elements(lonrange) gt 0 and n_elements(latrange) gt 0 ) then begin
   index = where( (lat ge min(latrange) and lat le max(latrange)) and $
		  (lon ge min(lonrange) and lon le max(lonrange))     )
endif else if ( n_elements(lonrange) gt 0 ) then begin
   index = where( (lon ge min(lonrange) and lon le max(lonrange))     )
endif else if ( n_elements(latrange) gt 0 ) then begin
   index = where( (lat ge min(latrange) and lat le max(latrange))     )
endif else index = indgen(n_elements(tot_pm_mod))
endelse
 
altp = altp[index]
lat = lat[index]
lon = lon[index]
if ~keyword_set(model_only) then begin
   tot_pm = tot_pm[index]
   so4 = so4[index]
   nh4 = nh4[index]
   no3 = no3[index]
   oa  = oa[index]
endif
if ~keyword_set(obs_only) then begin
   tot_pm_mod = tot_pm_mod[index]
   so4_mod = so4_mod[index]
   nh4_mod = nh4_mod[index]
   no3_mod = no3_mod[index]
   oa_mod  = oa_mod[index]
endif
 
; From CDH:
; Add this later? (jaf, 8/8/13)
;; Read ground elevation
;restore, !HOME +'/data/smith_sandwell_topo_v8_2.sav', /verbose
;jj = value_locate( topo.lat, lat )
;ii = value_locate( topo.lon, lon )
;altp = altp - (topo.alt[ii,jj] > 0)/1000.
 
; Find the nearest integer altitude (km)
; Restrict the range 0 < alt < 12km
alt_group     = ( ( floor(altp) < 12 ) > 0 )
 
; Find the median for each altitude bin
if ~keyword_set(model_only) then begin
   tot_pm_median   = tapply( tot_pm,  alt_group, 'median', /NaN )
   so4_median   = tapply( so4,  alt_group, 'median', /NaN )
   nh4_median   = tapply( nh4,  alt_group, 'median', /NaN )
   no3_median   = tapply( no3,  alt_group, 'median', /NaN )
   oa_median    = tapply( oa,   alt_group, 'median', /NaN )
endif
altp_median  = tapply( altp, alt_group, 'median', /NaN )

; We can use the same group IDs for the model because they are
; already interpolated to the same time and location 
if ~keyword_set(obs_only) then begin
   tot_pm_mod_median   = tapply( tot_pm_mod,  alt_group, 'median', /NaN )
   so4_mod_median   = tapply( so4_mod,  alt_group, 'median', /NaN )
   nh4_mod_median   = tapply( nh4_mod,  alt_group, 'median', /NaN )
   no3_mod_median   = tapply( no3_mod,  alt_group, 'median', /NaN )
   oa_mod_median    = tapply( oa_mod,   alt_group, 'median', /NaN )
endif
 
; Also get interquartile range
if ~keyword_set(model_only) then begin
 tot_pm_25 = tapply( tot_pm, alt_group, 'percentiles', /Nan, value=0.25 )
 tot_pm_75 = tapply( tot_pm, alt_group, 'percentiles', /Nan, value=0.75 )
endif
if ~keyword_set(obs_only) then begin
   tot_pm_mod_25 = tapply( tot_pm_mod, alt_group, 'percentiles', /Nan, value=0.25 )
   tot_pm_mod_75 = tapply( tot_pm_mod, alt_group, 'percentiles', /Nan, value=0.75 )
endif
 
; Set plot strings
if keyword_set(obs_only) then $
   title = 'Observed vertical profiles of PM' $
else if keyword_set(model_only) then $
   title = 'Modeled vertical profiles of PM' $
else $
   title = 'Observed and modeled vertical profiles of PM'
ytitle='Altitude, km'
if keyword_set(nmol) then xtitle='PM, nmol/m3' else xtitle='PM, ug/m3'

; Set up plot, full dynamic range
if Keyword_set(save) then begin
   filename=!SEAC4RS+'/IDL/plots/pm_profiles_full.ps'
   multipanel,rows=2,cols=1
   open_device, /ps, filename=filename, Bits=8, WinParam = [0, 300, 400], $
                /color, /portrait
   !p.font = 0
endif else if n_elements(choose_win) eq 0 then window,0 else window,choose_win

; Plot individual data points
if ~keyword_set(model_only) then $
plot, tot_pm,altp,color=1,psym=sym(1),symsize=0.2,yrange=altrange,ystyle=9,$
	xtitle=xtitle,ytitle=ytitle,title=title,xstyle=9,/nodata $
else $
plot, tot_pm_mod,altp,color=1,psym=sym(1),symsize=0.2,yrange=altrange,ystyle=9,$
	xtitle=xtitle,ytitle=ytitle,title=title,xstyle=9,/nodata
;oplot, tot_pm_mod, altp,color=2,psym=sym(1),symsize=0.2

; Plot IQR as error bars
;for i = 0, n_elements(tot_pm_mod_25)-1 do begin
;   oplot,[tot_pm_mod_25[i],tot_pm_mod_75[i]],$
;          [altp_median[i]+.05,altp_median[i]+.05],color=2,linestyle=0,thick=2
;endfor
if ~keyword_set(model_only) then begin
for i = 0, n_elements(tot_pm_25)-1 do begin
   oplot,[tot_pm_25[i],tot_pm_75[i]],$
          [altp_median[i],altp_median[i]],color=1,linestyle=0,thick=2
endfor
endif

; Plot median values in each altitude bin
if ~keyword_set(model_only) then begin
   oplot, tot_pm_median,altp_median,color=1,linestyle=0,thick=2
   oplot, so4_median,altp_median,color=5,linestyle=0,thick=2
   oplot, nh4_median,altp_median,color=3,linestyle=0,thick=2
   oplot, no3_median,altp_median,color=4,linestyle=0,thick=2
   oplot, oa_median,altp_median,color=6,linestyle=0,thick=2
   legend, lcolor=[1,5,3,4,6],line=intarr(5),thick=intarr(5)+2,$
	label=['Obs Total PM','   SO4','   NH4','   NO3','   OA'],$
	halign=0.9, valign=0.9, charsize=1.2, /color
endif
if ~keyword_set(obs_only) then begin
   oplot, tot_pm_mod_median,altp_median,color=2,linestyle=0,thick=2
   legend, lcolor=2,line=0,thick=2,label='Model Total PM',$
	halign=0.9, valign=0.9, charsize=1.2, /color,/add
endif 

; Legend
 
multipanel,/off
if Keyword_Set(save) then close_device
 
; Set up plot, limited range
if ( n_elements(mindata) gt 0 and n_elements(maxdata) gt 0 ) then begin
  if Keyword_set(save) then begin
     filename=!SEAC4RS+'/IDL/plots/pm_profiles.ps'
     multipanel,rows=2,cols=1
     open_device, /ps, filename=filename, Bits=8, WinParam = [0, 300, 400], $
                  /color, /portrait
     !p.font = 0
endif else if n_elements(choose_win) eq 0 then window,1 else window,choose_win

if ~keyword_set(model_only) then begin
   if n_elements(mindata) eq 0 then mindata=min([tot_pm,tot_pm_mod])
   if n_elements(maxdata) eq 0 then maxdata=max([tot_pm,tot_pm_mod])
endif else begin
   if n_elements(mindata) eq 0 then mindata=min(tot_pm_mod)
   if n_elements(maxdata) eq 0 then maxdata=max(tot_pm_mod)
endelse

; Plot individual data points
if ~keyword_set(model_only) then $
plot, tot_pm,altp,color=1,psym=sym(1),symsize=0.2,yrange=altrange,ystyle=9,$
	xrange=[mindata, maxdata], xstyle=9, xtitle=xtitle,$
	ytitle=ytitle,title=title,/nodata $
else $
plot, tot_pm_mod,altp,color=1,psym=sym(1),symsize=0.2,yrange=altrange,ystyle=9,$
	xrange=[mindata, maxdata], xstyle=9, xtitle=xtitle,$
	ytitle=ytitle,title=title,/nodata
;oplot, tot_pm_mod, altp,color=2,psym=sym(1),symsize=0.2

; Plot individual data points
;for i = 0, n_elements(tot_pm_mod_25)-1 do begin
;   oplot,[tot_pm_mod_25[i],tot_pm_mod_75[i]],$
;          [altp_median[i]+.05,altp_median[i]+.05],color=2,linestyle=0,thick=2
;endfor
if ~keyword_set(model_only) then begin
for i = 0, n_elements(tot_pm_25)-1 do begin
   oplot,[tot_pm_25[i],tot_pm_75[i]],$
          [altp_median[i],altp_median[i]],color=1,linestyle=0,thick=2
endfor
endif

; Plot median values in each altitude bin
if ~keyword_set(model_only) then begin
   oplot, tot_pm_median,altp_median,color=1,linestyle=0,thick=2
   oplot, so4_median,altp_median,color=5,linestyle=0,thick=2
   oplot, nh4_median,altp_median,color=3,linestyle=0,thick=2
   oplot, no3_median,altp_median,color=4,linestyle=0,thick=2
   oplot, oa_median,altp_median,color=6,linestyle=0,thick=2
   legend, lcolor=[1,5,3,4,6],line=intarr(5),thick=intarr(5)+2,$
	label=['Obs Total PM','   SO4','   NH4','   NO3','   OA'],$
	halign=0.9, valign=0.9, charsize=1.2, /color
endif
if ~keyword_set(obs_only) then begin
   oplot, tot_pm_mod_median,altp_median,color=2,linestyle=0,thick=2
   legend, lcolor=2,line=0,thick=2,label='Model Total PM',$
	halign=0.9, valign=0.9, charsize=1.2, /color,/add

if keyword_set(mod_comp) then begin
oplot, so4_mod_median,altp_median,color=5,linestyle=2,thick=2
oplot, nh4_mod_median,altp_median,color=3,linestyle=2,thick=2
oplot, no3_mod_median,altp_median,color=4,linestyle=2,thick=2
oplot, oa_mod_median,altp_median,color=6,linestyle=2,thick=2
legend, /add, lcolor=[5,3,4,6],line=intarr(4)+2,thick=intarr(4)+1,$
	label=['   SO4','   NH4','   NO3','   OA'],$
	charsize=1.2, /color
endif
endif 
 
multipanel,/off
if Keyword_Set(save) then close_device
 
endif else if ( n_elements(mindata) gt 0 or n_elements(maxdata) gt 0  ) then begin
   print, ''
   print,'Specify MINDATA and MAXDATA simultaneously to plot reduced range'
   print, ''
endif
 
stop
end
