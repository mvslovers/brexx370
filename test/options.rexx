say '----------------------------------------'
say 'File options.rexx'
/* from RossPatterson/CMS-370-BREXX tests/options_.exec (#189) */
/* */
say 'Testing OPTIONS ...'
fail_count=0

options noStorage_Decimal Storage_Decimal 'noStorage_Decimal'
options asdf
options qwer 1234
options 'x y z' 7890 4**4
options 'abc'"def" ghi || 'jkl'

say 'Done options.rexx'
exit fail_count
test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
