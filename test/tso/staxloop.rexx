/* A loop that never ends by itself: only an attention (PA1) stops it (#610) */
say 'STAXLOOP RUNNING'
n = 0
do forever
  n = n + 1
end
