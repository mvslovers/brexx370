/* ---------------------------------------------------------------------
 * Translates ASCII String to EBCDIC
 *   estring=A2E(ascii-string)
 * .................................. Created by PeterJ on 8. April 2019
 * ---------------------------------------------------------------------
 */
/* ..... ASCII to EBCDIC table .......*/
a2e:
if _#trttable=1 then nop
else do
     _#ascii2ebcdic= ,
        '00010203372D2E2F1605250B0C0D0E0F'x '' , /* 00 */
        '101112133C3D322618193F271C1D1E1F'x '' , /* 10 */
        '405A7F7B5B6C507D4D5D5C4E6B604B61'x '' , /* 20 */
        'F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F'x '' , /* 30 */
        '7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6'x '' , /* 40 */
        'D7D8D9E2E3E4E5E6E7E8E94AE05A5F6D'x '' , /* 50 */
        '79818283848586878889919293949596'x '' , /* 60 */
        '979899A2A3A4A5A6A7A8A9C04FD0A107'x '' , /* 70 */
        '202122232415061728292A2B2C090A1B'x '' , /* 80 */
        '30311A333435360838393A3B04143EE1'x '' , /* 90 */
        '41424344454647484951525354555657'x '' , /* A0 */
        '58596263646566676869707172737475'x '' , /* B0 */
        '767778808A8B8C8D8E8F909A9B9C9D9E'x '' , /* C0 */
        '9FA0AAABACADAEAFB0B1B2B3B4B5B6B7'x '' , /* D0 */
        'B8B9BABBBCBDBEBFCACBCCCDCECFDADB'x '' , /* E0 */
        'DCDDDEDFEAEBECEDEEEFFAFBFCFDFEFF'x      /* F0 */
/* ..... EBCDIC to ASCII table .......*/
     _#ebcdic2ascii = ,
        '000102039C09867F978D8E0B0C0D0E0F'x '' , /* 00 */
        '101112139D8508871819928F1C1D1E1F'x '' , /* 10 */
        '80818283840A171B88898A8B8C050607'x '' , /* 20 */
        '909116939495960498999A9B14159E1A'x '' , /* 30 */
        '20A0A1A2A3A4A5A6A7A85B2E3C282B7C'x '' , /* 40 */
        '26A9AAABACADAEAFB0B121242A293B5E'x '' , /* 50 */
        '2D2FB2B3B4B5B6B7B8B97C2C255F3E3F'x '' , /* 60 */
        'BABBBCBDBEBFC0C1C2603A2340273D22'x '' , /* 70 */
        'C3616263646566676869C4C5C6C7C8C9'x '' , /* 80 */
        'CA6A6B6C6D6E6F707172CBCCCDCECFD0'x '' , /* 90 */
        'D17E737475767778797AD2D3D4D5D6D7'x '' , /* A0 */
        'D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7'x '' , /* B0 */
        '7B414243444546474849E8E9EAEBECED'x '' , /* C0 */
        '7D4A4B4C4D4E4F505152EEEFF0F1F2F3'x '' , /* D0 */
        '5C9F535455565758595AF4F5F6F7F8F9'x '' , /* E0 */
        '30313233343536373839FAFBFCFDFEFF'x      /* F0 */
     _#trttable=1
end
return translate(arg(1),_#ebcdic2ascii,_#ascii2ebcdic)
