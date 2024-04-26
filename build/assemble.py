import sys
import logging
from string import Formatter
from pathlib import Path
import socket

# This python script assembles the required objects for BREXX/370
logname = 'assemble.log'
logging.basicConfig(filename=logname,
                            filemode='w',
                            format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                            datefmt='%H:%M:%S',
                            level=logging.DEBUG)

class assemble: 

    def __init__(self,system='MVSCE'):
        self.system = system
        logging.debug("Building")

    

    def jobcard(self, jobname, title, jclass='A', msgclass='A',user='IBMUSER',password='SYS1'):
        '''
        This function generates the jobcard needed to submit the jobs
        '''

        if self.system != 'MVSCE':
            user = 'HERC01'
            password = 'CUL8TR'

        with open('templates/jobcard.template', 'r') as template:
            jobcard = template.read()

            if jobcard[-1] != "\n":
                jobcard += "\n"

        return jobcard.format(
            jobname=jobname.upper(),
            title=title,
            jclass=jclass,
            msgclass=msgclass,
            user=user,
            password=password
            )

    def punch_out(self, jes_class='B'):
        '''
        This function returns the JCL to write &&OBJ to the punchcard writer

        jes_class: The class that sends the output to the card writer, usually 'B'
        '''
        with open('templates/punchcard.template', 'r') as template:
            punch_jcl = template.read()

        return punch_jcl.format(jes_class=jes_class)

    def brexx_maclib(self):
        linklib = 'SYSC.LINKLIB'

        if self.system != 'MVSCE':
            linklib = 'SYS2.LINKLIB'


        with open('templates/maclib.template', 'r') as template:
            logging.debug("reading: templates/maclib.template")
            maclib = template.read()
        
        p = Path("../maclib").glob('**/*.hlasm')
        files = [x for x in p if x.is_file()]
        dd = ''
        for macro in sorted(files):
            dd += "./ ADD NAME=" +macro.stem + "\n"
            with open(macro,'r') as mfile:
                dd += mfile.read()
                if dd[-1] != "\n":
                    dd += "\n"
        
        return(maclib.format(steplib=linklib,maclibs=dd))

    def RXMVSEXT_jcl(self):
        '''
        Generates the rxmvsext object file
        '''

        logging.debug("Building rxmvsext.obj")

        with open('templates/rxmvsext.template', 'r') as template:
            logging.debug("reading: templates/rxmvsext.template")
            punch_jcl = template.read()

        files = [i[1] for i in Formatter().parse(punch_jcl)  if i[1] is not None]

        fpath = "../asm/"
        file_contents = {}
        for fname in files:
            hlasm_file = fpath + fname + ".hlasm"
            logging.debug("reading:" + hlasm_file)
            print("reading:",hlasm_file)
            with open(hlasm_file, 'r') as infile:
                hlasm = infile.read()

                # if hlasm[-1] != "\n":
                #     hlasm += "\n"
            file_contents[fname] = hlasm
        rxmvsext_jcl = (self.jobcard("rxmvsext",'Builds RXMVSEXT obj') + self.brexx_maclib()
                       )           
# + 
                        #self.brexx_maclib() +
#                        punch_jcl.format(**file_contents) + 
 #                       self.punch_out()
#

        print("*" * 100)
        with open('test.jcl','w') as outf:
            outf.write(rxmvsext_jcl)
        self.submit(rxmvsext_jcl,host='192.168.0.102')

    def submit(self,jcl, host='127.0.0.1',port=3505):
        '''submits a job (in ASCII) to hercules listener'''

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        try:
            # Connect to server and send data
            sock.connect((host, port))
            sock.send(jcl.encode())
        finally:
            sock.close()

go = assemble(system='MVSCE')
go.RXMVSEXT_jcl()


    