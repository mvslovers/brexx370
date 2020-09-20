/* ---------------------------------------------------------------------
 * Example extended DATE functions                  PEJ 3. December 2018
 * ---------------------------------------------------------------------
 */
 /* Date Output Formats
    Base      is days since 01.01.0001            **1
    JDN       is days since 24. November 4714 BC  **1
    Julian    is yyyyddd    e.g. 2018257          **1
    Days      is ddd days in this year e.g. 257
    Weekday   is weekday of day e.g. Monday
    Century   is dddd days in this century
    European  is dd/mm/yyyy e.g. 11/11/2018       **1
    German    is dd.mm.yyyy e.g. 20.09.2018       **1
    USA       is mm/dd/yyyy e.g. 12.31.2018       **1
    STANDARD  is yyyymmdd        e.g. 20181219    **1
    ORDERED   is yyyy/mm/dd e.g. 2018/12/19       **1
    SHORT     is dd mon yyyy e.g. 28. OCT 2018
    LONG      is dd month yyyy e.g. 12. MARCH 2018
 
    **1 are also Date Input Formats
*/
 
RC=IMPORT(RXDATE)
if rc>0 then do
   say "Import of RXDATE Failed, Please check Allocations"
   exit 8
end
/* ---------------------------------------------------------------------
 * Examples of today()
 * ---------------------------------------------------------------------
 */
say 'Default      'today()      /* Output Format defaults to European */
say 'JDN          'today('jdn')
say 'Julian       'today('julian')
say 'Base         'today('base')
say 'USA          'today('usa')
say 'European     'today('EUROPEAN')
say 'German       'today('GERMAN')
say 'Standard     'today('standard')
say 'Short        'today('SHort')
say 'Long         'today('LONg')
say 'Ordered      'today('Ordered')
say 'Weekday      'today('weekday')
say 'Days/Year    'today('days')
say 'Days/Century 'today('century')
exit
/* ---------------------------------------------------------------------
 * Examples of RXDATE()
 * ---------------------------------------------------------------------
 */
 say 'Christmas 2018      'RXDATE('LONG',24.12.2018)
 say 'Weekday  XMAS 2018  'RXDATE('weekday',24.12.2018)
 say 'days/year Xmas 2018 'RXDATE('days',24.12.2018)
 say 'days since 1.1.1    'RXDATE('base',24.12.2018)
