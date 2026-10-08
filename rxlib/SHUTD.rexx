         parse arg host port
         if port='' then port=3205
         rc=stargate('SEND',host,port,'$$$SHUTDOWN')
