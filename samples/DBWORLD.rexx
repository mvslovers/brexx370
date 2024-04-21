/* ------------------------------------------------------------
 * Load the Key/Value Sample DB
 * ------------------------------------------------------------
 */
call import keyvalue
call dbopen
call dbroom('World')
s1=screate(1000)
/* call setg('dbOutArray',s1) */
/* ------------------------------------------------------------
 * Set Trade Unions
 * ------------------------------------------------------------
 */
EU='Austria France Malta Belgium Germany Netherlands Bulgaria Greece Poland Croatia Hungary Portugal Cyprus Ireland Romania Czech_Republic Italy Slovakia Denmark Latvia Slovenia Estonia Lithuania Spain Finland Luxembourg Sweden'
Nafta='U.S.A Mexico Canada'
ASEAN='Brunei Cambodia Indonesia Laos Malaysia Myanmar Philippines Singapore Thailand Vietnam'
brics='Argentina Argentina Egypt Ethiopia Iran Saudi_Arabia United_Arab_Emirates Algeria Bahrain Bangladesh Belarus Bolivia'
brics=brics' Cuba Honduras Kazakhstan Kuwait Palestine Senegal Thailand Venezuela Vietnam'
commonWealth=,
'Botswana Cameroon Gabon Gambia Ghana Kenya Kingdom_of_Eswatini Lesotho Malawi Mauritius Mozambique Namibia Nigeria Rwanda'
commonWealth=commonWealth' ',
'Seychelles Sierra Leone South_Africa Togo Uganda Tanzania Zambia Bangladesh Brunei India Malaysia Maldives Pakistan'
commonWealth=commonWealth' ',
'Singapore Sri Lanka Antigua_and_Barbuda Bahamas Barbados Belize Canada Dominica Grenada Guyana Jamaica Saint_Lucia'
commonWealth=commonWealth' ',
'St_Kitts_and_Nevis St_Vincent_and_The_Grenadines Trinidad_and_Tobago Cyprus Malta United Kingdom Australia Fiji'
commonWealth=commonWealth' ',
'Kiribati Nauru New_Zealand Papua_New_Guinea Samoa Solomon_Islands Tonga Tuvalu Vanuatu'
/* ------------------------------------------------------------
 * Load Countries
 * ------------------------------------------------------------
 */
dsn=MVSVAR('REXXDSN')'(COUNTRY)'
say time('l')' Start loading Countries from 'dsn
"EXECIO * DISKR '"dsn"' (STEM country. finis"
if rc>0 then signal ierror
call dbmsglv 'E'
do i=2 to country.0
   parse var country.i country','Abreviation','Capital_City','Continent','rem
   if Continent='N. America' then continent='North America'
   if Continent='S. America' then continent='South America'
   call dbset('Country.'country,Abreviation';;' Capital_City)
   call dblink('Country.'country,'Continent.'Continent,'Contained-in')
   call dblink('Country.'country,'City.'Capital_City,'Capital-is')
end
say time('l')' Loading Countries completed, 'country.0' loaded'
/* ------------------------------------------------------------
 * Link Countries and Trade Unions
 * ------------------------------------------------------------
 */
say time('l')' Link them to Trade Unions'
do i=1 to words(EU)
   call dblink('Country.'word(eu,i),'Union.European Union','Member-of')
end
do i=1 to words(Nafta)
   call dblink('Country.'word(nafta,i),'union.North American Free Trade','Member-of')
end
do i=1 to words(asean)
   call dblink('Country.'word(asean,i),'union.Southeast Asian Nations','Member-of')
end
do i=1 to words(brics)
   call dblink('Country.'word(brics,i),'union.BRICS','Member-of')
end
do i=1 to words(commonWealth)
   call dblink('Country.'word(commonWealth,i),'union.Common_Wealth','Member-of')
end
say time('l')' Link to Trade Unions completed'
/* ------------------------------------------------------------
 * Load Cities of the World (just a selection) and link them
 * to their Country
 * ------------------------------------------------------------
 */
dsn=MVSVAR('REXXDSN')'(CITIES)'
"EXECIO * DISKR '"dsn"' (STEM cities. finis"
if rc>0 then signal ierror
say time('l')' Start loading Cities and Link them to their Country'
do i=1 to cities.0
   parse var cities.i city';'country';'Population';'countryc
   if dbget('city.'city)=0 then do
      if DBRECSTAT='S' then city=city':'country  /* duplicate city in the world */
   end
   call dbset('city.'city,population)
   call dblink('city.'city,'Country.'country,'Part-of')
end
say time('l')' loading Cities completed, 'cities.0' loaded'
/* ------------------------------------------------------------
 * Store a simple Key/Value Information Model
 * Example:
 *    country: Acronym Capital Description Visited
 *      |      |       |       |           fourth-attribute
 *      |      |       |       third-attribute
 *      |      |       second-attribute
 *      |      first-attribute
 *      record-type
 * ------------------------------------------------------------
 */
call dbkvimadd 'country: Acronym Capital Description Visited'
call dbkvimadd 'city: population Description'
/* ------------------------------------------------------------
 * Build Information Model and save it in the Control Record
 * ------------------------------------------------------------
 */
call dbkvimbuild
call sfree(s1)
ierror:
call dbclose
