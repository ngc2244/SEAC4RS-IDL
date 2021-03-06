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

pro seac4rs_map, lon, lat, data, region=region, mindata=mindata, $
	maxdata=maxdata, diff=diff, limit=limit, outline=outline,$
	cities=cities, _extra=_extra

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

  myct,/WhGrYlRd

  ; Set up the map region.
  tvmap,fltarr(2,2),/isotropic,/USA,limit=limit,/nodata,$
        /continents,/noadvance, _extra=_extra
 
  if keyword_set(diff) then myct,/diff,ncolors=30 else myct,33,ncolors=30

  ; Overplot some city locations (e.g. Atlanta, Birmingham) since these were
  ; plume targets for flights. Add more here as needed!
  if keyword_set(cities) then begin

     ; Atlanta, Birmingham
     clat=[33.755,  33.525 ]
     clon=[-84.390, -86.813]

     oplot,clon,clat,psym=sym(4),color=5,symsize=2
     oplot,clon,clat,psym=sym(9),color=1,symsize=2

  endif

  ; Plot the data, coloring the points by value
  if keyword_set(outline) then begin
      plotsym,0,thick=2
      scatterplot_datacolor,lon,lat,data,/overplot,$
         /nocb,color=1,psym=8,symsize=1.2
  endif

  scatterplot_datacolor,lon,lat,data,/overplot,zmin=mindata,$
        zmax=maxdata,/xstyle,/ystyle,_extra=_extra,$
        CBposition=[0.2,-0.1,0.8,-0.07]

end
