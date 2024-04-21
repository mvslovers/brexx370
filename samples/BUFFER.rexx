say "Stack demo program"
say "The numbers lines in each line shows the TOTAL number of items QUEUED()"
say "in all buffers, the number of items in the topmost buffer QUEUED('T')"
say "and the number of buffers QUEUED('B')"
push 1
push 2
say "2 items are pushed"
say queued() queued(t) queued(b)
say "Create a New buffer"
call makebuf
push 3
push 4
say "2 items are pushed"
say queued() queued(t) queued(b)
say "Create a New buffer"
call makebuf
push 5
push 6
say "2 items are pushed"
say queued() queued(t) queued(b)
say "Create a New buffer"
call makebuf
push 7
push 8
say "2 items are pushed"
say queued() queued(t) queued(b)

say "pull QUEUED()" queued() "items"
do queued()
    pull a
    say "Item" a
end
say queued() queued(t) queued(b)
