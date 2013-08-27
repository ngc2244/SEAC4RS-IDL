pro ts_date, Species, Platform, Flightdates=Flightdates,halign=halign,_extra=_extra

  plot_2var_ts,Species,Platform,flightdates=Flightdates,$
  	title=strupcase(Platform)+' '+strupcase(species)+' '+Flightdates, $
  	thick=2,color=[!myct.black,!myct.gray67], _extra=_extra

  d = get_model_data_seac4rs(Species, Platform,Flightdates,_extra=_extra)
  t = get_model_data_seac4rs('DOY',Platform,Flightdates,_extra=_extra)

  oplot, t, d, color=2, thick=2

  if (n_elements(halign) eq 0) then halign=0.9
  legend, lcolor=[1,2], line=[0,0], thick=[2,2],$
	label=['Observed','Model'],$
	halign=halign, valign=0.9, charsize=1.2, /color

end

