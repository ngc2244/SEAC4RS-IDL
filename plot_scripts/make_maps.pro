; $Id: make_maps.pro,v 1.6 2008/07/07 17:10:42 jaf Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_MAPS
;
; PURPOSE:
;        Wrapper routine for making maps of various species during the
;        SEAC4RS field campaign.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        MAKE_MAPS, Species, Platform[, Keywords]
;
; INPUTS:
;        Species  - Name of species being mapped. e.g. 'CO', 'O3', 'ALTP'
;        Platform - Name of Aircraft. Current options: 'DC8','ER2'
;
; KEYWORD PARAMETERS:
;        FlightDates - Dates (as takeoff dates) as 'YYYYMMDD'. Can also
;                      accept '*'.
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        SEAC4RS_SPECIESMAP
;
; NOTES:
;
; EXAMPLE:
;        SEAC4RS_SPECIESMAP,'CO','DC8',Flightdates='*'
;
;        Plots CO from the DC8 flighttrack for all flights
;
; MODIFICATION HISTORY:
;        jaf, 06 Jul 2008: VERSION 1.00
;        jaf, 08 Aug 2013: updated for SEAC4RS
;
;-
; Copyright (C) 2008, Jenny Fisher, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to jaf@io.as.harvard.edu
; or with subject "IDL routine make_maps"
;-----------------------------------------------------------------------


pro make_maps,species,platform,flightdates=flightdates,_extra=_extra

; Set defaults, and alert user to choices being made.
; Default is to plot CO observations from the DC8 for all dates 
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
 
species = strupcase(species)

; For frequently plotted species, specify the min/max and unit to be used. 
CASE species of
    'CO' : begin
	MinData = 50
	MaxData = 200 
	unit = 'ppbv'
    end
    'CH4' : begin
	;MinData = 50
	;MaxData = 200
	Unit = 'ppbv'
    end
    'CO2' : begin
	MinData = 380
	MaxData = 400
	Unit = 'ppmv'
    end
    'HCN' : begin
	MinData = 0
	MaxData = 850
	Unit = 'pptv'
    end
    'SO4' : begin
	MinData = 0
	MaxData = 20
	Unit = 'nmol/m3'
    end
    'SO2' : begin
	MinData = 0
	MaxData = 2
	Unit = 'ppbv'
    end
    'CH3CN' : begin
	MinData = 0
	MaxData = 300
	Unit = 'ppbv'
    end
    'PNS' : begin
	MinData = 0
	MaxData = 500
	Unit = 'pptv'
    end
    'ISOP' : begin
	MinData = 0
	MaxData = 6
	Unit = 'ppbC'
    end
    'Pressure' : begin
	MinData = 0
	MaxData = 1100
	Unit = 'hPa'
    end
    else:
ENDCASE

; Plot the data over the US
seac4rs_speciesmap,species,platform,flightdates=flightdates,mindata=mindata,$
                  maxdata=maxdata,unit=unit,_extra=_extra
 
end
