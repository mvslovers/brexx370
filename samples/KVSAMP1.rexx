/* -------------------------------------------------------------
 * Update an Read in a REXX Large Object RXLOB
 * -------------------------------------------------------------
 */
   say "OPEN  "DBOPEN()

/* Add Continents  */
   SAY DBSET('Cont.Europe','Continent Europe')
   SAY DBSET('Cont.Asia','Continent Asia')
   SAY DBSET('Cont.Africa','Continent Africa')
   SAY DBSET('Cont.North America','Continent North America')
   SAY DBSET('Cont.South America','Continent South America')
   SAY DBSET('Cont.Australia','Australia and Oceania')

/* Get Continents  */
   call DBGET('Cont.Europe')
   say dbresult
   call DBGET('Cont.Asia')
   say dbresult
   call DBGET('Cont.Africa')
   say dbresult
   call DBGET('Cont.North America')
   say dbresult
   call DBGET('Cont.South America')
   say dbresult
   call DBGET('Cont.Australia')
   say dbresult

/* List all continents, and those starting with A */
   call dblist("cont.",20)
   call dblist("cont.A",20)

/* Remove Europe and Asia, add Eurasia instead */
   say "Delete "DBDEL('Cont.Europe')
   say dbresult
   say "Delete "DBDEL('Cont.Asia')
   say dbresult
   call DBSET('Cont.Eurasia','Continent of Eurasia')
   say dbresult
   call DBGET('Cont.Eurasia')
   say dbresult

/* Locate North America and read all contintents following */
   say DBLOCATE('Cont.North America')
   do forever
      rc=DBNEXT()
      if rc>0 then leave
      say DBRESULT
   end

/* Add some Countries in North America */
   SAY DBSET('Country.Canada','Canada is part of North America')
   SAY DBSET('Country.USA','U.S.A is part of North America')
   SAY DBSET('Country.Mexico','Mexico is part of North America')
   SAY DBSET('Country.El Salvador','El Salvador is part of North America')
   SAY DBSET('Country.Jamaica','Jamaica is part of North America')

/* List all countries */
   call dblist("country.",20)

/* Add some Trade Agreement(s) */
   SAY DBSET('Trade.NAFTA','North American Free Trade Agreement')

/* Link them to North America */
   SAY DBLINK('Country.Canada','Cont.North America','part of')
   SAY DBLINK('Country.USA','Cont.North America','part of')
   SAY DBLINK('Country.Mexico','Cont.North America','part of')
   SAY DBLINK('Country.El Salvador','Cont.North America','part of')
   SAY DBLINK('Country.Jamaica','Cont.North America','part of')

/* Link the NAFTA Countries */
   SAY DBLINK('Trade.NAFTA','Country.Canada','Economy')
   SAY DBLINK('Trade.NAFTA','Country.USA','Economy')
   SAY DBLINK('Trade.NAFTA','Country.Mexico','Economy')

/* Report on North America Links */
   SAY DBREFerence('Country.USA')
   SAY DBUSAGE('Country.USA')
   SAY DBReference('Trade.NAFTA')

/* Remove some records */
   say DBREMOVE('Continent.A')

/* List entire DBcontent */
   call dblist(,20)
/* Remove all Countries */
   call dbremove('Country.')

   say "CLOSE "DBCLOSE()
exit 0
