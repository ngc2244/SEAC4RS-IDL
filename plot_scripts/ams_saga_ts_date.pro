pro ams_saga_ts_date, Flightdates=Flightdates,halign=halign,valign=valign,$
	_extra=_extra

  plot_2var_ts,'SO4','DC8',flightdates=Flightdates,$
  	title='Sulfate, '+Flightdates, /minavg,$
  	thick=2, colors=[1,!myct.gray67],mindata2=0,_extra=_extra

  t = get_field_data_seac4rs('DOY','DC8',Flightdates,/minavg,_extra=_extra)
  d = get_field_data_seac4rs('AMS_SO4', 'DC8',Flightdates,/minavg,_extra=_extra)
  oplot, t, d, color=4, thick=2

  if (n_elements(halign) eq 0) then halign=0.9
  if (n_elements(valign) eq 0) then valign=0.9

  legend, lcolor=[1,4], line=intarr(2), thick=intarr(2)+2,$
	label=['SAGA SO4','AMS SO4'],$
	halign=halign, valign=valign, charsize=1.2, /color

end

