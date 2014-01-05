pro map_all_tracks,dc8=dc8,er2=er2, color=color, region=region,$
	legend=legend,save=save

; Set up filename, plot
if keyword_set(dc8) and keyword_set(er2) then filename='all_tracks.ps' else $
if keyword_set(dc8) then filename='dc8_tracks.ps' else $
if keyword_set(er2) then filename='er2_tracks.ps'

if keyword_set(save) then $
open_device, /ps, /color, bits=8, $
   filename=!SEAC4RS+'/IDL/flight/'+filename

if n_elements(region) eq 0 then region=''
case strlowcase(region) of 
    'southeast': limit=[25,-100,40,-75]
    'se'       : limit=[25,-100,40,-75]
    else       : limit=[25,-127,52,-65]
endcase

tvmap,fltarr(2,2),/isotropic,/continents,/USA,limit=limit,$
	 /noadvance,/nodata,cfill=1,ccolor=!myct.darkgray,$
	 /nogxlabel,/nogylabel
map_continents,/usa,/countries,/hires

; Set up arrays
ldate=''
lcolor=[0]

; Get DC8 flight tracks
if Keyword_Set(dc8) then begin
   NewFiles = [MFindFile(!SEAC4RS + '/IDL/flight/DC8/*.ict')]
   Date = strarr(n_elements(NewFiles))
 
   for i = 0L, n_elements( NewFiles )-1L do begin

      ; Get flight date
      loc = strpos(NewFiles[i],'2013')
      date[i]=string((byte(NewFiles[i]))[loc:loc+7])

      Get_DC8, NewFiles[i],DC8_Long = lon, DC8_Lat =lat

      ; Don't include test flights, first two files
      if ( i gt 1 ) then begin

         if keyword_set(color) then begin
            if (i ge 11) then line=5 else line=0
	    oplot,lon,lat,color=(i mod 11)+2,thick=2,line=line
            lcolor = [lcolor,i]
            ldate = [ldate,Date[i]]
         endif else oplot,lon,lat,color=2,thick=2

      endif

   endfor
   close,/all

endif

if keyword_set(color) and keyword_set(legend) then begin
   lcolor=lcolor[1:*]
   ldate =ldate[1:*]
   nl = n_elements(lcolor)
   legend,lcolor=lcolor,line=intarr(nl),thick=intarr(nl)+2,charsize=1.1,$
          boxcolor=!myct.darkgray,label=ldate,halign=1.,valign=0.1,/color
endif

; Get ER2 flight tracks
if Keyword_Set(er2) then begin
   NewFiles = [MFindFile(!SEAC4RS + '/IDL/flight/ER2/*.ict')]
 
   for i = 0L, n_elements( NewFiles )-1L do begin
      Get_ER2, NewFiles[i],ER2_Long = lon, ER2_Lat =lat

      ; Don't include test flights, first two files
      if ( i gt 1 ) then begin

         if keyword_set(color) then oplot,er2lon,er2lat,color=i,thick=2 $
         else oplot,er2lon,er2lat,color=2,thick=2

      endif

   endfor
   close,/all

endif

; Don't have sondes yet; fill this in later
;sonde_lon=$
;[-108.67,-94.06,-85.9,-122.33,-71.46,-95.0,-59.9,-114.00,-38.5,-124.2,-135.1]
;sonde_lat=$
;[  50.17, 58.74, 80.0,  49.05, 41.30, 74.7, 45.0,  53.53, 72.6,  40.0,  60.7]

;oplot,sonde_lon,sonde_lat,psym=sym(1),symsize=1.25,color=29
;oplot,sonde_lon,sonde_lat,psym=sym(6),symsize=1.25,color=1

if keyword_set(dc8) and keyword_set(er2) then $
  legend, lcolor=[2,4], line=[0,0], lthick=[2,2], $
  label=['DC8','ER2'],halign=0.95, valign=0.1, charsize=1.2, /color
  

if keyword_set(save) then close_device

stop
end
