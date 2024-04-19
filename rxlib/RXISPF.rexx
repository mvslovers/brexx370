/* REXX */
call ispfrun arg(1)
return 0
/* ---------------------------------------------------------------------
 * Switch To ISPF (not all selections are implemented)
 * ............................... Created by PeterJ on 28. January 2019
 * ---------------------------------------------------------------------
 */
ISPFrun: Procedure
  parse arg option
  ADDRESS TSO 'CLS'
  if option='0' then ADDRESS ISPEXEC SELECT 'PANEL(ISPOP0)'
  else if option='1' then ADDRESS ISPEXEC SELECT 'PANEL(ISPREVB)'
  else if option='2' then ADDRESS ISPEXEC SELECT 'PANEL(ISPREVE)'
  else if option='3' then ADDRESS ISPEXEC SELECT 'PANEL(ISPUTILS)'
  else if option='3.1' then ADDRESS ISPEXEC SELECT 'CMD(RFE 3.1)'
  else if option='3.2' then ADDRESS ISPEXEC SELECT 'CMD(RFE 3.2)'
  else if option='3.3' then ADDRESS ISPEXEC SELECT 'CMD(RFE 3.3)'
  else if option='3.4' then ADDRESS ISPEXEC SELECT 'CMD(RFE 3.4)'
  else if option='3.8' then ADDRESS ISPEXEC SELECT 'CMD(REVOUT *)'
  else if option='4' then ADDRESS ISPEXEC SELECT 'PANEL(ISRFPA)'
  else if option='6' then ADDRESS ISPEXEC SELECT 'PANEL(ISPOP6)'
  else ADDRESS ISPEXEC SELECT 'PANEL(ISP@PRIM)'
RETURN 0
