        call listvols                        -- which Volumes are contained this MVS
        say 'MVS Volume Statistics'
        say '                  +- TRACKS +   Track  +------ Tracks ------ % +  +-- Free -+'
        say 'Volume Type CYLS  /CYL  Total   Length Allocated not Used   used  Tracks    %'
        say '-----------------------------------------------------------------------------'
        do i=1 to volumes.0                  -- Run through every single Volume
           call VolReport word(volumes.i,1)  -- fetch details of it
        end
        return
        /* --------------------------------------------------------------------
         * Report Detail of Volume
         * --------------------------------------------------------------------
         */
        VolReport:
          parse arg volume
          Call ListVol volume
          if voltrks=0 then return   -- Volume is not properly assigned
          if VOLTRKALC>0 then pct=round(VOLTRKUSED*100/VOLTRKALC,1)
          else pct=0.0
          say VolVolume VOLTYPE right(VOLCYLS,4) right(VOLTRKCYL,5) right(VOLTRKS,6) right(VOLTRKLEN,8),
         right(VOLTRKALC,9) right(VOLTRKALC-VOLTRKUSED,8) right(pct,6),
         right(VOLTRKS-VOLTRKALC,7) right(round(VOLTRKALC*100/Voltrks,1),5)
        return