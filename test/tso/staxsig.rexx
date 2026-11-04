/* Same loop, with SIGNAL ON HALT: the attention reaches the handler (#610) */
signal on halt
say 'STAXSIG RUNNING'
n = 0
do forever
  n = n + 1
end
halt:
say 'STAXSIG HANDLER'
exit 0
