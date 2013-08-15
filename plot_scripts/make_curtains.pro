; $Id: make_curtains.pro,v 1.4 2008/07/07 17:04:00 jaf Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_CURTAINS
;
; PURPOSE:
;	 Wrapper routines for making curtains of GEOS-Chem model
;	 output along SEAC4RS flight tracks
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        MAKE_CURTAINS, Species, Platform[, Keywords]
;
; INPUTS:
;	 Species  - Name of observation variable. e.g. 'CO','ALTP'
;			Default is 'CO'.
;	 Platform - Name of aircraft. Current options: 'DC8','ER2'
;			Default is 'DC8'.
;
; KEYWORD PARAMETERS:
;        Flightdates - Date of takeoff as 'YYYYMMDD'. Only one date
;                      can be used.
;                       Default is '20130806'.
;
; OUTPUTS:
;	 None
;
; SUBROUTINES:
;	 None
;
; REQUIREMENTS:
;	 Calls SEAC4RS_OBS_MOD_CURTAINS, which calls a number of
;	 other SEAC4RS and GAMAP routines
;
; NOTES:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        jaf, 13 May 2008: VERSION 1.00
;        jaf, 08 Aug 2013: Updated for SEAC4RS
;
;-
; Copyright (C) 2008, Jenny Fisher, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to jaf@io.as.harvard.edu
; with subject "IDL routine make_curtains"
;-----------------------------------------------------------------------

pro make_curtains, species, platform, flightdates = flightdates, $
	_extra=_extra
 
 
   if n_elements(species) eq 0 then species= 'co'
   if n_elements(platform) eq 0 then platform = 'DC8'
 
   ; Set default plotting unit
   Unit = '[ppbv]'
 
   species = strupcase(species)
 
   case species of
      'CO': begin
         MinData = 50
         MaxData = 200
         MMinData = 50
         MMaxData = 200
         DiagN = 'IJ-AVG-$'
         Tracer = 4
      end
     'O3': begin
         MinData = 30
         MaxData = 100
         DiagN = 'IJ-AVG-$'
         Tracer = 2
      end
     'HCN': begin
         MinData = 0
         MaxData = 850
     end
     'SO4': begin
         MinData = 0
         MaxData = 1
	 fscale = 96.*( 1.29 / 28.97 )
         Unit = 'ug/m3'
         DiagN = 'IJ-AVG-$'
         Tracer = 27
      end
     'SO2': begin
         MinData = 0
         MaxData = 1d3
	 fscale = 1d3
         Unit = 'pptv'
         DiagN = 'IJ-AVG-$'
         Tracer = 26
      end
      'ISOP' : begin
         MinData = 0
         MaxData = 1.5
	 fscale = 1./5
         Unit = 'ppbv'
         DiagN = 'IJ-AVG-$'
         Tracer = 6
       end
      'HCHO' : begin
         MinData = 0
         MaxData = 3d3
	 fscale = 1d3
         Unit = 'pptv'
         DiagN = 'IJ-AVG-$'
         Tracer = 20 
       end
      else:
   endcase
 
seac4rs_obs_mod_curtains, species, platform, diagn, tracer, fscale=fscale, $
   flightdates=flightdates, mindata=mindata, maxdata=maxdata,             $
   mmindata=mmindata, mmaxdata=mmaxdata, unit=unit, _extra=_extra
 
ctm_cleanup   
end
