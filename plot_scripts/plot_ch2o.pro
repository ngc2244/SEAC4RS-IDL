pro plot_ch2o

   ; To run this code, you will need several routines from David Fanning
   ; You can download all of them from the COYOTE IDL website or from my
   ; directory here: /home/skim/IDL/misc_IDL as needed

multipanel,rows=2,cols=1
ps_setup,/open,/landscape,filename=!SEAC4RS+'/IDL/plots/hcho_slide_img.ps'
!p.font=0

   ; Set the rotation angle of the figure about the z-axis
   ax = -15

   ; Set the min and max of the colorbar
   cbmin = 0
   cbmax = 800

   ; Set the 3D coordinate space with axes, but don't plot it yet
   surface, DIST(5), /NODATA, /SAVE, XRANGE=[-130, -60], $
      YRANGE=[20, 50], ZRANGE=[0, 12], XSTYLE=1,         $
      YSTYLE=5, ZSTYLE=5, CHARSIZE=2.0,                  $
      POSITION=[0.1, 0.1, 0.95, 0.95, 0.0, 1.0], az = ax

   ; Save the current plotting system variables (since MAP_SET will change them).
   bangp = !P
   bangx = !X
   bangy = !Y
   bangz = !Z

   ; Draw a map projection in the 3D coordinate space.
   cgMap_Set, /Cylindrical, /T3D, /NoErase, Position=[0.1, 0.1, 0.95, 0.95], limit=[20, -130, 50, -60], /usa
   cgMap_Continents, /Fill, /T3D, Color=!myct.lightgray, /usa,/noerase
   cgMap_Continents, /T3D, Color=!myct.black, /usa,/countries,/coasts,/continents

   ; Restore the system variables.
   !P = bangp
   !X = bangx
   !Y = bangy
   !Z = bangz

   ; Now get the axes set up 
   surface, DIST(5), /NODATA, /SAVE, XRANGE=[-130, -60], $
      YRANGE=[20, 50], ZRANGE=[0, 12], XSTYLE=1,         $
      YSTYLE=5, ZSTYLE=5, CHARSIZE=2.0,                  $
      POSITION=[0.1, 0.1, 0.95, 0.95, 0.0, 1.0], /NOERASE, az = ax
   cgAXIS, XAXIS=1, /T3D, CHARSIZE=2.0
   cgAXIS, YAXIS=1, /T3D, CHARSIZE=2.0
   ; Changing the zaxis label will switch which corner the z-axis will be plotted on
   cgAXIS, ZAXIS=2, /T3D, CHARSIZE=2.0

   ; Get the data that we are interested in
   fd=['20130806','20130808','20130812']
;   ch2o = get_field_data_seac4rs( 'CH2O_CAMS', 'dc8' ,/minavg)
   ch2o = get_field_data_seac4rs( 'CH2O_LIF', 'dc8' ,fd,/minavg)
   lat  = get_field_data_seac4rs( 'lat'     , 'dc8' ,fd,/minavg)
   lon  = get_field_data_seac4rs( 'lon'     , 'dc8' ,fd,/minavg)
   alt  = get_field_data_Seac4rs( 'alt'     , 'dc8' ,fd,/minavg)

ch2o=reverse(ch2o)
lat=reverse(lat)
lon=reverse(lon)
alt=reverse(alt)

   ; Only get the data where there are good values for all variables, has trouble with NaN's
   ind = where( finite( lat ) gt 0 and finite( lon ) gt 0 and finite( alt ) gt 0 and $
                finite(ch2o ) gt 0 and ch2o gt 0 )

;   ch2o = alog10(ch2o[ind])
;   ind = indgen(n_elements(ch2o))
;   cbmax_in=cbmax
;   cbmax=alog10(cbmax)

   ; Color each of the points in the dataset
   z_color = bytscl( ch2o(ind), top=!Myct.Ncolors-1L, /NaN,  $
                     min=cbmin, max=cbmax, _Extra=_Extra ) + $
                     !Myct.bottom
;   z_color = logscl( ch2o(ind), min=cbmin,max=cbmax,omax=!Myct.Ncolors-1L,exponent=10)$
;                   +!myct.bottom 

   ; Plot each of the data points, note that lon goes from [0, 360] so make a transformation
;   cgPlotS, lon(ind)-360, lat(ind), alt(ind), color=z_color, PSYM=sym(1), SYMSIZE=2.5, /T3D
   lon[where(lon gt 180)]=lon[where(lon gt 180)] - 360.
   cgPlotS, lon(ind), lat(ind), alt(ind), color=z_color, PSYM=sym(1), SYMSIZE=3.0, /T3D

   ; Now deal with the color bar, move around on the figure with the 4-element array
   CBposition = [0.65,0.85,0.95,0.95]  
   CBpagepos  = CBposition
   ; Width,height of the plot window
   dx = !X.window[1]-!X.window[0]
   dy = !Y.window[1]-!Y.window[0]
   ; Position of the colorbar within the plot window
   CBpagepos[[0, 2]] = CBposition[[0, 2]]*dx +!X.window[0]
   CBpagepos[[1, 3]] = CBposition[[1, 3]]*dy +!Y.window[0]

   ; Make colorbar on log scale ourselves
   c_levels=10^(indgen(!myct.ncolors+1)/(1.*!myct.ncolors)*alog10(cbmax))
   c_colors=indgen(!myct.ncolors)+!myct.bottom
   label=[0,1,10,100,1000]

   ; Add that sucker on
   colorbar, min=cbmin, max=cbmax, divisions=5, position=CBpagepos,unit='[pptv]' 
   ;colorbar, min=cbmin, max=cbmax, divisions=5, position=CBpagepos,/log, _Extra=_Extra
   ;colorbar, min=cbmin, max=cbmax, position=CBpagepos,c_levels=c_levels,$
;	c_colors=c_colors,skip=4

ps_setup,/close,/noview,/landscape
stop
end
