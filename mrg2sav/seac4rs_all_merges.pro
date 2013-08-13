
startDir = file_expand_path( '.' )

;read_all_merges, 'DC8',  Dir=!SEAC4RS+'/field_data/DC8/merge_60s/'
;close,/all
read_all_merges, 'ER2',  Dir=!SEAC4RS+'/field_data/ER2/merge_60s/'
close,/all

CD, startDir

; Now convert the 60s merges to averages over the GEOS5 grid and timetep
;DirIn1  = !SEAC4RS+'/field_data/DC8/merge_60s'
;DirOut1 = !SEAC4RS+'/field_data/DC8/merge_10m_0.25x0.3125'
;mrgsav2geosgrid, DirIn1, DirOut1, $
;  'DC8', 10, CTM_Type('GEOS5_47L',res=0.25)

;CD, startDir

DirIn2  = !SEAC4RS+'/field_data/ER2/merge_60s'
DirOut2 = !SEAC4RS+'/field_data/ER2/merge_10m_0.25x0.3125'
mrgsav2geosgrid, DirIn2, DirOut2, $
  'ER2', 10, CTM_Type('GEOS5_47L',res=0.25)

;s1 = "rename.pl 's/(.*)mrg60(.*)/$1mrg60m$2/' "+DirOut1+"/*.sav"
s2 = "rename.pl 's/(.*)mrg60(.*)/$1mrg60m$2/' "+DirOut2+"/*.sav"

close,/all

end
