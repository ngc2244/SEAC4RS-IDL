pro make_profiles,species,platform,flightdates=flightdates,_extra=_extra

if N_Elements(species) eq 0 then begin
        species='CO'
        print,'You didn''t specify a species, so CO is being plotted!'
endif
if N_Elements(platform) eq 0 then begin
        platform='DC8'
        print, 'You didn''t specify a platform, so DC8 is being plotted!'
endif
if N_Elements(flightdates) eq 0 then begin
        flightdates='2013*'
        print, 'You didn''t specify flightdates, so all dates are being plotted!'
endif

species = strupcase(species)

CASE species of
    'CO'  : Unit = 'ppbv'
    'SO4' : Unit = 'ug/m3'
    'SO2' : Unit = 'ppbv'
    'O3'  : Unit = 'ppbv'
    'HCHO' or 'CH2O' : Unit = 'pptv'
    'ISOP': Unit = 'ppbv'
    else:
ENDCASE

seac4rs_obs_mod_profiles,species,platform,flightdates=flightdates,mindata=mindata,maxdata=maxdata,unit=unit,_extra=_extra

end
