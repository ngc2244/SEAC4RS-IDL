
function ER2_LineSplit, Line

;====================================================================
; Function ER2_LINESPLIT splits a line by spaces or horizontal tabs.
; (bmy, 5/16/05)
;====================================================================

   ; First try to break the line by comma-spaces ...
   Result = StrBreak( Line, ', ' )

   ; ... then if that doesn't work, by spaces
   if ( N_Elements( Result ) eq 1 ) $
      then Result = StrBreak( Line, ' ' )

   ; ... then if that doesn't work, by tabs
   if ( N_Elements( Result ) eq 1 ) $
      then Result = StrBreak( Line, BYTE(9B) )

   ; ... then if that doesn't work, by commas
   if ( N_Elements( Result ) eq 1 ) $
      then Result = StrBreak( Line, ',' )

   ; Return success or stop w/ error
   if ( N_Elements( Result ) gt 0 ) then begin
      return, Result
   endif else begin
      S = 'Could not split line by spaces or tabs or commas!'
      Message, S
   endelse
end

;====================================================================
; End function ER2_LINESPLIT
;====================================================================

pro read_er2_merge, FileNames

   ;; =============================
   ;; Specify a file if none is given
   ;; =============================

   if ( N_Params() EQ 0 ) Then $
      FileNames = [ '~/data/INTEXB/mrg_Hg/mrgUNHMERC_er2_20060319_R3']

   ;; =============================
   ;; Read in datafile
   ;; =============================

   ;; for testing
   ;;FileNames = FileNames[2]

   For F=0, n_elements(FileNames)-1L Do Begin
      
      InFile  = FileNames[F] + '.ict'
      OutFile = FileNames[F] + '.sav'
      
      print, ' ### Processing ', InFile

      ;; Logical flag is TRUE if ER2 data exists
      Is_Data  = ( File_Exist( InFile) )
      if not Is_Data then Stop,  'Data file not found!'

      ;; Only proceed if data exists for this date
      If ( Is_Data ) then begin

         ; Get number of lines in file
         s=query_ascii( InFile, info )
         nlines = info.lines

         Open_File, InFile, Ilun_Flt, /Get_LUN

         Line = ' '

         ;; Read first line
         ReadF, Ilun_Flt, Line

         ;; Split line by spaces or tabs
         Result = ER2_LineSplit( Line )

         ;; Get # of lines in the header
         N_Hdr = Long( Result[0] )

         ;; Skip header
         for N = 0L, N_Hdr-2L do begin

            ;; Read each lines
            ReadF, Ilun_Flt, Line

            ;; Get number of variables
            if ( N eq 8 ) then begin

               ;; Split the line
               Result = ER2_LineSplit( Line )

               ;; Save into variables
               NVars  = Long( Result[0] )

               ;; Undefine
               Undefine, Result

            endif


            ;; Parse the line w/ the data field names (bmy, 3/6/06)
            if ( N eq N_Hdr-2L ) then begin

               ;; Split the line
               VarNames  = ER2_LineSplit( Line )

            endif

         endfor

         ;; Read in data
         ;; Preallocate data to avoid memory lags (cdh, 12/7/2009)
         Data = dblarr( nVars+1, nlines-n_hdr )

         i=0L
         while ( not EOF( Ilun_Flt ) ) do begin
            ReadF, Ilun_Flt, Line
            junk   = StrBreak( Line, ' ' )

            data[*,i] = double( junk )
            i=i+1L
         endwhile
; CDH, before 12/7/2009
;         First = 1
;         while ( not EOF( Ilun_Flt ) ) do begin
;            ReadF, Ilun_Flt, Line
;            junk   = StrBreak( Line, ' ' )
;
;            if ( First ) then data = [double( junk )] $
;            else data = [ [data], [double( junk )] ]
;            First = 0
;         endwhile

         Close,    Ilun_Flt
         Free_LUN, Ilun_Flt


         ;; Put into a structure
         First_Time = 1L
         FOR V = 0L, NVars Do Begin

            Name = VarNames[V]

            Ind = where( VarNames eq Name )
            ThisData     = [reform( data[Ind[0], *])]


            ;; ==========================
            ;; Remove illegal characters from vector name
            ;; ==========================

            ; None so far for SEAC4RS (jaf, 8/13/13)
            ;If ( Name EQ 'GPS-ALT' ) Then Name = 'ALTGPS'
                 

            Name = StrRepl(Name, '/', '_')
            Name = StrRepl(Name, '(', '_')
            Name = StrRepl(Name, ')', '_')
            Name = StrRepl(Name, '-', '_')
            Name = StrRepl(Name, '@', '_')
            Name = StrRepl(Name, '+', '_')
            Name = StrRepl(Name, '.', '_')

            ;print, Name

            ;; ==========================
            ;; Deal with missing values
            ;; ==========================

            ;; ------------------
            ;; Leave this out to allow folks to treat ULOD, LLOD as they wish
            ;; ------------------
            ;; Replace < LOD values with 0
         Ind  = Where( ThisData eq -888888, Ct )
         If (Ct gt 0) then ThisData[Ind] = 0.0D0

         ;; Check for ULOD flags
         Ind  = Where( ThisData eq -777777, Ct )
;         If (Ct gt 0) Then Stop, 'ULOD Flags Found!!'
         If (Ct gt 0) Then Begin
            ThisData[Ind] = !Values.F_NAN
            Print, 'ULOD Flags found for ', Name
         EndIf

            ;; Replace missing values with NA
         Ind  = Where( ThisData eq -999999, Ct )
         If (Ct gt 0) then ThisData[Ind] = !VALUES.F_NAN
            ;; ------------------

            IF FIRST_TIME THEN BEGIN
               er2 = CREATE_STRUCT(NAME, ThisData)
            ENDIF ELSE BEGIN
               er2 = CREATE_STRUCT(er2, Name, ThisData)
            ENDELSE

            FIRST_TIME = 0L

            ;; End loop over variables
         ENDFOR

         ;; ==========================
         ;; Save data structure
         ;; ==========================

         save, er2, filename= OutFile, /COMPRESS

      Endif

   Endfor

END
