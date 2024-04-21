say copies('-',60)
say "Base 64 Encoding/Decoding"
say copies('-',60)
    str='The quick brown fox jumps over the lazy dog, has nothing better to do!'
    stre=base64Enc(str)
    say 'Encoded  'stre
    strd=base64Dec(stre)
    say 'Original "'strd'"'
    say 'Decoded  "'strd'"'
