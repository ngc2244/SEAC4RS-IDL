;-----------------------------------------------------------------------
; Based on make_movies_gif.pro by skim
; lei, 08/21/2013
; example: seac4rs_column, 20130815, 190000, 20, /save

pro seac4rs_column, date, time, tracer, save=save

  ; Cal tau
  tau = nymd2tau(date, time)

  ; Compute yesterday's date
  date_yst   = Add_Date( date, -1 )

  ; Convert integer to string
  YYYYMMDD   = String( date,     Format='(i8.8)' )
  YYYYMMDD_1 = String( date_Yst, Format='(i8.8)' )
  HHMMSS     = String( time,     Format='(i6.6)' )

  ; Default NRT bpch files folder 
  NRT_folder = "/as/tmp/all/bmy/NRT/run.NA/timeseries/"

  ; Notice there is a 21 hours lag
  filename   = NRT_folder + "ts" + YYYYMMDD_1 + ".bpch"

  ; Get column density
  VCD = CTM_COLUMN_DU   ( 'IJ-AVG-$',          $
                          FileName=filename,   $
                          Tracer=tracer,       $
                          Tau0=tau             )

  ; Cleanup before reading in the new datafile
  ctm_cleanup
  ctm_get_data, datainfo, 'IJ-AVG-$', filename=filename, tracer=tracer

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

  ; Plot 
  if ( tracer eq 20 ) then begin
    species = 'HCHO'
  endif

  title = species + ' column density at ' + YYYYMMDD + ' ' + HHMMSS + '(UTC)'

  tvmap, VCD[ifirst:ifirst + nx - 1, jfirst:jfirst + ny - 1],  $
               gridinfo.xmid[ifirst:ifirst + nx - 1],          $
               gridinfo.ymid[jfirst:jfirst + ny - 1],          $
               /continents, /isotropic, /usa, /cbar,           $
               divisions=7, mindata=0, maxdata=5e16,           $
               title = title, /nogxlabels, /noadvance

  ; save
  if keyword_set(save) then begin
    save_dir=!SEAC4RS+'/IDL/plots/'
    filename=save_dir+ species + '_column_'+YYYYMMDD+'_'+HHMMSS+'.ps'
    open_device, /ps, filename=filename, Bits=8, $
               WinParam = [0, 300,400], /color, /portrait
    !p.font = 0

    tvmap, VCD[ifirst:ifirst + nx - 1, jfirst:jfirst + ny - 1],                    $
               gridinfo.xmid[ifirst:ifirst + nx - 1],          $
               gridinfo.ymid[jfirst:jfirst + ny - 1],          $
               /continents, /isotropic, /usa, /cbar,           $
               divisions=7, mindata=5e15, maxdata=4e16,        $
               title = title, /nogxlabels, /noadvance
  endif

  if keyword_set(save) then close_device

end
