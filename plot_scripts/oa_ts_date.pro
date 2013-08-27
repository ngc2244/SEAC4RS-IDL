pro oa_ts_date, Flightdates=Flightdates,halign=halign,valign=valign,$
	model_only=model_only,_extra=_extra

  plot_2var_ts,'OA','DC8',flightdates=Flightdates,$
  	title='DC-8 OA, '+Flightdates, /model, $
  	thick=2, colors=[1,!myct.gray67],mindata2=0,_extra=_extra

  if ~keyword_set(model_only) then begin 
     t = get_field_data_seac4rs('DOY','DC8',Flightdates,_extra=_extra)
     d = get_field_data_seac4rs('OA', 'DC8',Flightdates,_extra=_extra)
     oplot, t, d, color=1, thick=2
  endif

  t = get_model_data_seac4rs('DOY','DC8',Flightdates,_extra=_extra)
  d = get_model_data_seac4rs('OA', 'DC8',Flightdates,_extra=_extra)

  POA = get_model_data_seac4rs('POA', 'DC8',Flightdates,_extra=_extra)
  ASOA = get_model_data_seac4rs('ASOA', 'DC8',Flightdates,_extra=_extra)
  BBSOA = get_model_data_seac4rs('BBSOA', 'DC8',Flightdates,_extra=_extra)
  BGSOA = get_model_data_seac4rs('BGSOA', 'DC8',Flightdates,_extra=_extra)

  oplot, t, d, color=2, thick=2
  oplot, t, POA, color=5, thick=2
  oplot, t, ASOA, color=3, thick=2
  oplot, t, BBSOA, color=4, thick=2
  oplot, t, BGSOA, color=6, thick=2

  if (n_elements(halign) eq 0) then halign=0.9
  if (n_elements(valign) eq 0) then valign=0.9

  legend, lcolor=[1,2,5,3,4,6], line=intarr(6), thick=intarr(6)+2,$
	label=['Obs Total OA','Model Total OA','  POA','  An. SOA',$
               '  BB SOA', '  BG SOA'],$
	halign=halign, valign=valign, charsize=1.2, /color

end

