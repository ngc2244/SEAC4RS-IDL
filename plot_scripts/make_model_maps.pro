; $Id: make_model_maps.pro,v 1.6 2008/07/07 17:10:42 jaf Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_MODEL_MAPS
;
; PURPOSE:
;        Wrapper routine for making maps of modeled concentrations during
;        the SEAC4RS field campaign.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        MAKE_MODEL_MAPS, Species, Platform[, Keywords]
;
; INPUTS:
;        Species  - Name of species being mapped. e.g. 'CO', 'O3', 'ALTP'
;        Platform - Name of Aircraft. Current options: 'WP3D'
;
; KEYWORD PARAMETERS:
;        FlightDates - Date (as takeoff date) as 'YYYYMMDD'. Can only
;                      accept one date at a time
;        OPlot_Data  - Plot observed data atop model map
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        SEAC4RS_MODEL_MAP
;
; NOTES:
;
; EXAMPLE:
;        MAKE_MODEL_MAPS,'CO','WP3D',Flightdates='20130708',/OPlot_Data
;
;        Plots modeled CO from the WP3D over modeled CO for July 8 2013
;
; MODIFICATION HISTORY:
;        jaf, 09 Aug 2013: VERSION 1.00
;
;-
; Copyright (C) 2013, Jenny Fisher, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
;-----------------------------------------------------------------------

pro make_model_maps,species,platform,flightdates=flightdates,ppt=ppt,_extra=_extra

; Set defaults, and alert user to choices being made.
; Default is to plot CO observations from the WP3D for all dates 
if N_Elements(species) eq 0 then begin
        species='CO'
        print,'You didn''t specify a species, so CO is being plotted!'
endif
if N_Elements(platform) eq 0 then begin
        platform='WP3D'
        print, 'You didn''t specify a platform, so WP3D is being plotted!'
endif
if N_Elements(flightdates) eq 0 then begin
        flightdates='20130708'
        print, 'You didn''t specify flightdates, so 20130708 being plotted!'
endif
 
; Allow user to specify min/max data
if n_elements(mindata) ne 0 then mindata_in=mindata
if n_elements(maxdata) ne 0 then maxdata_in=maxdata
fscale=1

; For frequently plotted species, specify the min/max and unit to be used. 
species = strupcase(species)

if ( species eq 'HCHO_LIF' or species eq 'HCHO_CAMS' or species eq 'HCHO' or $
     species eq 'CH2O_LIF' or species eq 'CH2O_CAMS' ) then mspecies='CH2O' else $
if ( species eq 'SAGA_SO4' or species eq 'AMS_SO4'   ) then mspecies='SO4' else $
if ( species eq 'NO2_TDLIF' ) then mspecies='NO2' else $
   mspecies = species

CASE mspecies of
    'CO' : begin
	MinData = 50
	MaxData = 200 
	unit = 'ppbv'
    end
    'SO4' : begin
	MinData = 0
        if keyword_set(ppt) then begin
	MaxData = 1d3
        fscale = 1d3
	Unit = 'ppt'
        endif else begin
	MaxData = 1
        fscale = 96.*( 1.29 / 28.97 )
	Unit = 'ug/m3'
        endelse
    end
    'SO2' : begin
	MinData = 0
	MaxData = 1d3
	fscale = 1d3
	Unit = 'pptv'
    end
    'HNO3' : begin
	MinData = 0
	MaxData = 1d3
	fscale = 1d3
	Unit = 'pptv'
    end
    'NO2' : begin
	MinData = 0
	MaxData = 1.0
	Unit = 'ppbv'
    end
    'ISOP' : begin
	MinData = 0
	MaxData = 1 
	Unit = 'ppb'
        fscale = 1./5
    end
    'CH2O' : begin
	MinData = 0
	MaxData = 3d3 
	Unit = 'ppt'
        fscale = 1d3
    end
    'OA' : begin
	MinData = 0
;	MaxData = 1
        fscale = 12 * 2.1 / 22.4
	Unit = 'ug/m3'
    end
    'BC' : begin
	MinData = 0
;	MaxData = 1
        fscale = 12d3 * 2.1 / 22.4
	Unit = 'ng/m3'
    end
    else:
ENDCASE

if n_elements(mindata_in) ne 0 then mindata=mindata_in
if n_elements(maxdata_in) ne 0 then maxdata=maxdata_in
if ~keyword_set(oplot_data) then oplot_data=0
if ~keyword_set(oplot_track) then oplot_track=0

; Plot the data over the US
seac4rs_model_map,species,platform,flightdates=flightdates,mindata=mindata,$
                  maxdata=maxdata,unit=unit,oplot_data=oplot_data,       $
		  fscale=fscale,mspecies=mspecies,ppt=ppt,oplot_track=oplot_track,$
		  _extra=_extra
 
end
