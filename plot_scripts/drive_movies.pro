pro drive_movies

   ;------------------------------------------------------
   ; Automate the calls to movie_wrapper for each species
   ; skim, 8/19/13
   ;------------------------------------------------------

   ; Get the list of files to process
   dir   = "/as/tmp/all/bmy/NRT/run.NA/timeseries/"
   files = file_search( dir + "ts*" )

   ; Ignore the first 3 days
   ; This is to flush out any changes due to regridding from the
   ;    4x5 simulation to the nested simulation
   ; files = files(4:(n_elements(files)-1))
  
   files = files(4:n_elements(files)-1)
   print, files

   ;movie_wrapper, files, [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]	; no
   ;movie_wrapper, files, [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]	; o3
   ;movie_wrapper, files, [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ]	; co
   ;movie_wrapper, files, [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ]	; isoprene
   movie_wrapper, files, [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ]	; formaldehyde
   ;movie_wrapper, files, [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 ]	; so2
   ;movie_wrapper, files, [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ]	; so4
   ;movie_wrapper, files, [ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ] 	; no2
   ;movie_wrapper, files, [ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 ]	; asoa
   ;movie_wrapper, files, [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 ]	; bbsoa
   ;movie_wrapper, files, [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ]   ; bgsoa

end
