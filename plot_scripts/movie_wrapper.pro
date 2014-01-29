pro movie_wrapper, files, toggle_species

	;------------------------------------------------------------
	; Driver program to create gif movies of tracers of interest
	; skim, 8/18/13
	;------------------------------------------------------------

	; Tracer Concentrations
	if ( 1 ) then begin

        ; NO
        if ( toggle_species(0) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 1 ]

        ; Set the plot bounds
        mindata = [   0,   0,   0 ]
        maxdata = [ 0.5, 0.5, 0.5 ]
        level   = [  10,  22,  28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ '~/movies/seac4rs/', $
                       '~/movies/seac4rs/', $
                       '~/movies/seac4rs/'  ]

	scale_factor = 1

        endif

	; Ozone
	if ( toggle_species(1) gt 0 ) then begin

	; Set the tracers to plot
	diagn  = [ 'IJ-AVG-$' ]
	tracer = [ 2 ]

	; Set the plot bounds
	mindata = [   0,   0,   0 ]
	maxdata = [ 100, 100, 100 ]
	level   = [  10,  22,  28 ]
	sum     = 0

	; Set the directory where gif files will be saved
	output_dir = [ './movies/o3_850hpa/', $
		       './movies/o3_500hpa/', $
		       './movies/o3_250hpa/'  ]

	scale_factor = 1

	endif

        ; Carbon Monoxide
        if ( toggle_species(2) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 4 ]

        ; Set the plot bounds
        mindata = [  50,  50,  50 ]
        maxdata = [ 250, 150, 100 ]
        level   = [  10,  22,  28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/co_850hpa/', $
                       './movies/co_500hpa/', $
                       './movies/co_250hpa/'  ]

	scale_factor = 1

        endif

	; Isoprene
        if ( toggle_species(3) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 6 ]

        ; Set the plot bounds
        mindata = [   0,    0,    0 ]
        maxdata = [  10, 0.25, 0.25 ]
        level   = [  10,   22,   28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/isop_850hpa/', $
                       './movies/isop_500hpa/', $
                       './movies/isop_250hpa/'  ]

	scale_factor = 1

        endif

        ; Formaldehyde
        if ( toggle_species(4) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 20 ]

        ; Set the plot bounds
        mindata = [   0 ]
        maxdata = [ 0.5 ]
        level   = [  22 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ '~/movies/seac4rs/' ]

;        ; Set the plot bounds
;        mindata = [   0,    0,    0 ]
;        maxdata = [  10,  0.5,  0.5 ]
;        level   = [  10,   22,   28 ]
;        sum     = 0
;
;        ; Set the directory where gif files will be saved
;        output_dir = [ './movies/seac4rs/', $
;                       './movies/seac4rs/', $
;                       './movies/seac4rs/'  ]

	scale_factor = 1

        endif

        ; SO2
        if ( toggle_species(5) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 26 ]

        ; Set the plot bounds
        mindata = [   0,    0,    0 ]
        maxdata = [   5,    1,    1 ]
        level   = [  10,   22,   28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/so2_850hpa/', $
                       './movies/so2_500hpa/', $
                       './movies/so2_250hpa/'  ]
	
	scale_factor = 1

        endif

        ; SO4
        if ( toggle_species(6) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 27 ]

        ; Set the plot bounds
        mindata = [   0,    0,    0 ]
        maxdata = [   3,    1,    1 ]
        level   = [  10,   22,   28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/so4_850hpa/', $
                       './movies/so4_500hpa/', $
                       './movies/so4_250hpa/'  ]

	scale_factor = 1

        endif

        ; NO2
        if ( toggle_species(7) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 64 ]

        ; Set the plot bounds
        mindata = [   0,    0,    0 ]
        maxdata = [ 0.5,  0.5,  0.5 ]
        level   = [  10,   22,   28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/no2_850hpa/', $
                       './movies/no2_500hpa/', $
                       './movies/no2_250hpa/'  ]

	scale_factor = 1e9

        endif

        ; ASOA
        if ( toggle_species(8) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 78 ]

        ; Set the plot bounds
        mindata = [   0,    0,    0 ]
        maxdata = [   5,  0.5,  0.5 ]
        level   = [  10,   22,   28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/asoa_850hpa/', $
                       './movies/asoa_500hpa/', $
                       './movies/asoa_250hpa/'  ]

        scale_factor = 1e9

        endif

        ; BBSOA
        if ( toggle_species(9) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 79 ]

        ; Set the plot bounds
        mindata = [   0,    0,    0 ]
        maxdata = [   5,  0.5,  0.5 ]
        level   = [  10,   22,   28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/bbsoa_850hpa/', $
                       './movies/bbsoa_500hpa/', $
                       './movies/bbsoa_250hpa/'  ]

        scale_factor = 1e9

        endif

        ; BGSOA
        if ( toggle_species(10) gt 0 ) then begin

        ; Set the tracers to plot
        diagn  = [ 'IJ-AVG-$' ]
        tracer = [ 80 ]

        ; Set the plot bounds
        mindata = [   0,    0,    0 ]
        maxdata = [   5,  0.5,  0.5 ]
        level   = [  10,   22,   28 ]
        sum     = 0

        ; Set the directory where gif files will be saved
        output_dir = [ './movies/bgsoa_850hpa/', $
                       './movies/bgsoa_500hpa/', $
                       './movies/bgsoa_250hpa/'  ]

        scale_factor = 1e9

        endif

	endif

	; NO Emissions
	if ( 0 ) then begin

	files = '/as/cache-old/2013-06/skim/standard/bpch/ctm.bpch.20080901'

	; Set the tracers to plot
	diagn  = [ 'NO-AC-$', 'NO-AN-$', 'NO-BIOB', $
		   'NO-BIOF', 'NO-LI-$', 'NO-SOIL', $
 	           'NO-FERT', 'NO-STRT'             ]
	tracer = [ 1 ]

	; Set the plot bounds
	mindata = 1e9
	maxdata = 1e11
	level   = 38
	sum     = 1

	endif

	; Loop through each of the desired levels
	for n = 0, n_elements( level )-1 do begin
	   make_movies_gif, files, diagn, tracer, $
	     mindata(n), maxdata(n), level(n), sum, output_dir(n), scale_factor
	endfor

end
