; $Id: seac4rs_map.pro,v 1.4 2008/07/06 17:08:57 jaf Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SEAC4RS_MAP
;
; PURPOSE:
;        This program plots data as colored points along a latitude, longitude
;        track. This program currently only supports the Rainbow colorscale
;        (IDL colortable 33).
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        SEAC4RS_MAP, LON, LAT, DATA[, MINDATA=MINDATA, MAXDATA=MAXDATA]
;
; INPUTS:
;        LON, LAT  - Longitude and latitude coordinates to plot (must be same length)
;        DATA      - Values which determine the color of each point
;                    (must be same length as LON, LAT)
;
; KEYWORD PARAMETERS:
;        MINDATA   - Data values less than MINDATA will all be the same color
;        MAXDATA   - Data values greater than MAXDATA will all be the same color 
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        cdh, 15 Apr 2008: VERSION 1.00
;        jaf, 06 Jul 2008: Added suppression of lat labels since
;                          they were obscuring the title.
;        lei, 29 Jul 2013: Updated for SEAC4RS
;-
; Copyright (C) 2008, Christopher Holmes, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to cdh@io.as.harvard.edu
; with subject "IDL routine seac4rs_map"
;-----------------------------------------------------------------------


pro seac4rs_map, lon, lat, data, latmin=latmin, mindata=mindata, $
	maxdata=maxdata, diff=diff, _extra=_extra

  if n_elements(latmin) eq 0 then latmin = 15

  myct,/WhGrYlRd

  ; Set up the map region. Suppress lat labels to avoid obscuring the title.
  ;tvmap,fltarr(2,2),/orthographic,/isotropic,/USA,$
  tvmap,fltarr(2,2),/isotropic,/USA,limit=[latmin,-130,60,-60],/nodata,$
        /continents,/grid,/noadvance,/nogylabels, _extra=_extra
 
  if keyword_set(diff) then myct,/diff,ncolors=30 else myct,33,ncolors=30

  ; Truncate data at latmin to avoid plotting outside the map window.
  ; The default works well for the DC8 and NASA ER2 during SEAC4RS 
  IND = where(lat ge latmin)

  ; Plot the data, coloring the points by value
  scatterplot_datacolor,lon[IND],lat[IND],data[IND],/overplot,zmin=mindata,$
        zmax=maxdata,/xstyle,/ystyle,_extra=_extra,$
        CBposition=[0.2,0.1,0.8,0.13]
end
