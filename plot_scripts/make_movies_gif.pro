pro make_movies_gif, file_list, diagn, tracer, mindata, maxdata, level, ysum, output_dir, scalef

   ;--------------------------------------------------------------------
   ; Create and save a separate gif image for each entry in a bpch file
   ;    Useful for creating movies of model output
   ; skim, 8/18/13
   ;--------------------------------------------------------------------

   ; Set program defaults
   if ( n_elements( file_list  ) eq 0 ) then exit	
   if ( n_elements( diagn      ) eq 0 ) then diagn      = 'IJ-AVG-$'	
   if ( n_elements( tracer     ) eq 0 ) then tracer     = 1	
   if ( n_elements( mindata    ) eq 0 ) then mindata    = 0
   if ( n_elements( maxdata    ) eq 0 ) then maxdata    = 100
   if ( n_elements( level      ) eq 0 ) then level      = 0
   if ( n_elements( ysum       ) eq 0 ) then ysum       = 0
   if ( n_elements( output_dir ) eq 0 ) then output_dir = './'
   if ( n_elements( scalef     ) eq 0 ) then scalef     = 1

   flightdays = [ '20130806', '20130808', '20130812', '20130814', $
	          '20130816', '20130819'                          ]

   ; Loop through each given file
   for n = 0, n_elements( file_list )-1 do begin
	
      print, "Processing File: ", file_list(n)

      ; Cleanup before reading in the new datafile
      ctm_cleanup
	
      ctm_get_data, datainfo, diagn, filename=file_list(n), tracer=tracer
	
      ; Retrieve grid information
      getmodelandgridinfo, datainfo[0], modelinfo, gridinfo
      ifirst = (datainfo.first[0])[0]-1
      jfirst = (datainfo.first[1])[0]-1
      nx     = (datainfo.dim[0])[0]
      ny     = (datainfo.dim[1])[0]
      nz     = (datainfo.dim[2])[0]
      xmid   = gridinfo.xmid
      ymid   = gridinfo.ymid
      zmid   = gridinfo.zmid
	
      ; Loop through each variable
      for v = 0, n_elements( datainfo )-1 do begin
			
         var = temporary( *( datainfo[v].data ) ) * scalef

 	 ; Get time info for the bpch file
	 ; Update for each variable, especially for timeseries files
	 date_float  = tau2yymmdd( datainfo[v].tau0 )
		
	 year  = string(date_float.year,  '(i4.4)')
         month = string(date_float.month, '(i2.2)')
         day =   string(date_float.day,   '(i2.2)')
         hour =  string(date_float.hour,  '(i2.2)')
		
	 ; Daniel wants this string as a month
	 if ( date_float.month eq 8 ) then begin
	     month_str = 'Aug'
	 endif else begin
	     	month_str = 'Sep'
	 endelse
		
	 date_string = month_str + ' ' + day + ', ' + hour + ' UTC'

	 ; Change this to the z buffer device
	 set_plot, 'z'

         ; Check if we are plotting a 2D or 3D field
	 if ( n_elements( size( var, /dimensions ) ) eq 2 ) then begin

            tvmap, var, gridinfo.xmid[ifirst:ifirst + nx - 1],      $
            	gridinfo.ymid[jfirst:jfirst + ny - 1], /continents, $
            	/isotropic, /usa, /cbar, divisions=7, 	    	    $
            	mindata=mindata, maxdata=maxdata,                   $
            	title = datainfo[v].category + ' ' +                $
            			  datainfo[v].unit     + ' ' +      $
            			  date_string

	 endif else begin

	    if ( ysum ) then begin

	    temp = size( var, /dimensions )

	    ; Add up to the max level of the variable if less than the specified value
            if ( temp[2] le level ) then height = temp[2]-1 $
            else height = level

            tvmap, total( var[*, *, 0:height], 3),             $
               gridinfo.xmid[ifirst:ifirst + nx - 1],          $
               gridinfo.ymid[jfirst:jfirst + ny - 1],          $
               /continents, /isotropic, /usa, /cbar,           $
               divisions=7, mindata=mindata, maxdata=maxdata,  $
               title = datainfo[v].category + ' ' +            $
            			  datainfo[v].unit     + ' ' + $
            			  date_string
            			  
            endif else begin

	    ; Check to see if this was a flight day
	    ind = where( year + month + day eq flightdays )

	    ; Set species default
            species_in = 'soa_fake'

	    ; Make pretty title strings
            case tracer of
            1: begin
               title      = 'NO (ppb)'
               species_in = 'no'
               conversion = 1.0
            end
	    2: begin
	       title      = 'Ozone (ppb)'
	       species_in = 'o3'
	       conversion = 1.0
	    end
	    4: begin
               title      = 'Carbon Monoxide (ppb)'
	       species_in = 'co'
	       conversion = 1.0
	    end
            6: begin
               title      = 'Isoprene (ppb)'
               species_in = 'isop'
               conversion = 1.0
            end
            20: begin
               title      = 'Formaldehyde (ppb)'
               species_in = 'hcho_cams'
               conversion = 1 / 1e3
            end
            26: begin
               title      = 'SO2 (ppb)'
               species_in = 'so2'
               conversion = 1 / 1e3
            end
            27: begin
               title      = 'SO4 (ppb)'
               species_in = 'so4'
	       ; Convert from ug/m3 to ppb
               conversion = 1 / (1e3 * (96d-3 * ( 1.29 / 28.97 )))
            end
            64: begin
               title      = 'NO2 (ppb)'
               species_in = 'no2'
               conversion = 1.0
            end
            endcase

	    title = title + ' at ' + strtrim(string(gridinfo.pmid(level), $
		format='(f4.0)'), 2) + ' hpa'

            tvmap, var[*, *, level],                           $
               gridinfo.xmid[ifirst:ifirst + nx - 1],          $
               gridinfo.ymid[jfirst:jfirst + ny - 1],          $
               /continents, /isotropic, /usa, /cbar,           $
               divisions=7, mindata=mindata, maxdata=maxdata,  $
               title = title, /nogxlabels, /noadvance
  
	    xyouts, /dev, 87, 97, date_string, color=1, charsize=2.5, charthick=2, font=1

	    ; Check to see if there was a flight on this day
	    if ( ind[0] ge 0 ) then begin

              species = get_field_data_seac4rs(species_in, 'dc8', year + month + day)
              lat     = get_field_data_seac4rs('lat'     , 'dc8', year + month + day)
              lon     = get_field_data_seac4rs('lon'     , 'dc8', year + month + day)
              press   = get_field_data_seac4rs('pressure', 'dc8', year + month + day)

	      ; Make sure there is data to use
	      if ( n_elements( species ) eq 1 and finite( species[0] ) eq 0 ) then begin
	         print, 'No Data For This Species!'
	         goto, get_figure
	      endif

	      ; Check the levels
              data_ind = where( press ge gridinfo.pmid(level)-100 and $
	                        press le gridinfo.pmid(level)+100 ) 

	      ; Skip if there is no data in this range
	      if ( data_ind[0] lt 0 ) then begin
	         print, 'No Data In This Pressure Range!'
	         goto, get_figure
	      endif

              ; Add to map
              plotsym,0,thick=2
              scatterplot_datacolor, lon(data_ind), lat(data_ind), species(data_ind) * conversion, $
                 /overplot, zmin=mindata, zmax=maxdata, /xstyle, /ystyle, /nocb,$
                 color=1,psym=8,symsize=1.2
              scatterplot_datacolor, lon(data_ind), lat(data_ind), species(data_ind) * conversion, $
                 /overplot, zmin=mindata, zmax=maxdata, /xstyle, /ystyle, /nocb, symsize=1.0

	    endif

            endelse

         endelse

	 get_figure: screen2gif, date_string + ' ' + datainfo[v].category
	 erase

	endfor
      endfor

      ; Move all of the gif files to the desired directory
      spawn, 'mv *.gif ' + output_dir

end
