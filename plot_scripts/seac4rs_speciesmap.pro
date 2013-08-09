; $Id: seac4rs_speciesmap.pro,v 1.7 2008/07/06 17:07:19 jaf Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SEAC4RS_SPECIESMAP
;
; PURPOSE:
;        Plot a given species measured on the SEAC4RS aircraft or modeled
;        by GEOS-Chem on a domain appropriate for the SEAC4RS missions.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        SEAC4RS_SPECIESMAP,Species,Platform[,Keywords]
;
; INPUTS:
;        Species  - Name of species being mapped. e.g. 'CO', 'O3', 'ALTP'
;        Platform - Name of Aircraft. Current options: 'DC8', 'ER2'
;
; KEYWORD PARAMETERS:
;        FlightDates - Dates (as takeoff dates) as 'YYYYMMDD'. Can also
;                      accept groups
;        Alt         - Altitude range. Use this keyword to only plot
;                      data that falls within this range of altitudes.
;        MinData     - Minimum value to use when plotting species.
;        MaxData     - Maximum value to use when plotting species.
;        Model       - If set, modeled values will be plotted rather
;                      that observed data
;	 Save        - If set, map will be saved as a postscript rather
;		       than plotted on the screen
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        GET_MODEL_DATA_SEAC4RS
;        GET_FIELD_DATA_SEAC4RS
;        SEAC4RS_MAP
;
; NOTES:
;    (1) This routine will not work for dates outside of the SEAC4RS dates.
;        Modify this part of the code to use for other campaigns.
;    (2) If data is not found for the given species / platform / date
;        combination, this routine will return to the calling program.
;
; EXAMPLE:
;    SEAC4RS_SPECIESMAP,'CO','DC8',FlightDates='*', $
;                      MinData=0, MaxData=200,/Troposphere,/Model
;
;    Plots modeled CO from the DC8 flighttrack for all flights based
;    out of Fairbanks. Excludes stratospheric air and plots CO on a
;    scale from 0 to 200.
;
; MODIFICATION HISTORY:
;        cdh & jaf, 14 May 2008: VERSION 1.00
;        jaf,        6 Jul 2008: Added lines to plot all Fairbanks or
;                                Cold Lake flights
;	 jaf,	    27 Aug 2008: Added SAVE keyword
;        lei,       29 Jul 2013: Updated for SEAC4RS
;-
; Copyright (C) 2008, Bob Yantosca, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine seac4rs_speciesmap"
;-----------------------------------------------------------------------

pro seac4rs_speciesmap, species, platform, flightdates=flightdates, $
alts=alts,mindata=mindata,maxdata=maxdata,model=model,save=save, $
_extra=_extra
 
; Set defaults, and alert user to choices being made.
; Default is to plot CO observations from the DC8 for all dates at ll
; pressures.
if N_Elements(species) eq 0 then begin
	species='CO'
	print,'You didn''t specify a species, so CO is being plotted!'
endif 
if N_Elements(platform) eq 0 then begin
	platform='DC8'
	print, 'You didn''t specify a platform, so DC8 is being plotted!'
endif
if N_Elements(flightdates) eq 0 then begin
	flightdates='2013*'
	print, 'You didn''t specify flightdates, so all dates are being plotted!'
endif
;if N_Elements(press) eq 0 then begin
;	press=[0, 1100]
;	print, 'You didn''t specify pressure, so all pressures are being plotted!'
;endif
if N_Elements(alts) eq 0 then begin
	alts=[0, 20]
	print, 'You didn''t specify altitude, so all altitudes are being plotted!'
endif
if N_Elements(model) eq 0 then model = 0 


; Get either modeled or observed data
if keyword_set(model) then begin
	data = get_model_data_seac4rs(species,platform,flightdates, $
	                             _extra=_extra)
	lat = get_model_data_seac4rs('lat',platform,flightdates, $
	                             _extra=_extra)
	lon = get_model_data_seac4rs('lon',platform,flightdates, $
	                             _extra=_extra)
	alt_data = get_model_data_seac4rs('alt',platform,flightdates, $
	                             _extra=_extra)
endif else begin
	data = get_field_data_seac4rs(species,platform,flightdates,$
                                     _extra=_extra)
	lat = get_field_data_seac4rs('lat',platform,flightdates,$
                                     _extra=_extra)
	lon = get_field_data_seac4rs('lon',platform,flightdates,$
                                     _extra=_extra)
	alt_data = get_field_data_senex('alt',platform,flightdates,$
                                     _extra=_extra)
endelse

; Select the data that is within the correct alt range. 
index = where( alt_data gt min(alts) and alt_data lt max(alts) )
if index(0) ge 0 then begin
data = data(index)
lat = lat(index)
lon = lon(index)
endif

; If MinData and/or MaxData are not specified, use the min and max
; of the actual data 
if N_elements(mindata) eq 0 then mindata=min(data,/nan)
if N_elements(maxdata) eq 0 then maxdata=max(data,/nan)

; If there is no data, return to calling program 
if finite(mindata,/nan) then begin
	print,'************No data for this species/date!'
	return
endif

; Set title 
if keyword_set(model) then begin
        title = 'Modeled ' + strupcase(Species) + ' on ' + strupcase(Platform) + ' track'
endif else begin
        title = strupcase(Platform) + ' ' + strupcase(Species)
endelse

; Set up plot
if keyword_set(save) then begin
	save_dir=!SEAC4RS+'/IDL/plots/'
	if keyword_set(model) then begin
	   filename=save_dir+$
		'mod_'+platform+'_'+species+'_map_'+flightdates+'.ps'
	endif else begin
	   filename=save_dir+$
		'obs_'+platform+'_'+species+'_map_'+flightdates+'.ps'
	endelse
     	multipanel,rows=2,cols=1
     	open_device, /ps, filename=filename, Bits=8, $
		WinParam = [0, 300,400], /color, /portrait
     	!p.font = 0 
endif
 
; Plot the data over the US
seac4rs_map, lon, lat, data, latmin=latmin, zmin=mindata, zmax=maxdata, $
            title=title, _extra=_extra
 
if keyword_set(save) then close_device

end
