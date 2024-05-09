import os
import sys
import logging
import argparse
import subprocess
from pathlib import Path
from string import Formatter
from datetime import datetime
from automvs import automation

cwd = os.getcwd()

def write_jcl(jcl):
    jobname = jcl.split()[0][2:]
    print(f' # Writing {cwd}/{jobname}.jcl')
    with open(f'{cwd}/{jobname}.jcl','w') as outjcl:
        outjcl.write(jcl)
    return

def print_jcl(jcl):
    print(f'Printing {jcl.split()[0][2:]}:\n')
    for l in jcl.splitlines():
        print(l)

def make_release(jcl_builder, builder, unit=3380,volser='PUB001',mvs_type='MVSCE',out_type='MVSCE'):

    if 'MVSCE' in mvs_type:
        cat = 'UCPUB001'
    elif 'TK5' in mvs_type:
        cat = 'SYS1.UCAT.TSO'
    elif 'TK4-' in mvs_type:
        cat = 'SYS1.VMASTCAT'

    if 'MVSCE' in out_type:
        o_unit='3380'
        o_volser='PUB000'
    elif 'TK5' in out_type:
        o_unit='3390'
        o_volser='tk5001'
    else:
        o_unit='3380'
        o_volser='pub002'

    release_jcl = jcl_builder.RELEASE_jcl(unit=unit,
                                          volser=volser,
                                          mvs_type=mvs_type,
                                          o_unit=o_unit,
                                          o_volser=o_volser,
                                          catalog=cat)
    
    if args.print:
        print_jcl(release_jcl)
        sys.exit()

    print(f" # Submitting RELEASE JCL for {out_type}")

    builder.change_punchcard_output("/tmp/punch.dummy".format(cwd))
    builder.send_oper("$s punch1")

    builder.change_punchcard_output("{}/brexx_xmit.punch".format(cwd))
    builder.submit(release_jcl)
    print(" # Waiting for RELEASE to finish")

    
    found_string = builder.wait_for_strings(["SETUP -- PUNCH1   -- F = STD1","$HASP250 RELEASE  IS PURGED"])
    builder.send_oper("$s punch1")

    if 'SETUP -- PUNCH1   -- F = STD1' in found_string:
        builder.wait_for_job("RELEASE")
    # builder.send_oper("$s punch1")
    print(" # Building XMIT punchards finished")

    if mvs_type in ['TK4-','MVSCE']:
        results = builder.check_maxcc("RELEASE",steps_cc={'APFCOPY':'0004'})
    else:
        results = builder.check_maxcc("RELEASE")
    print_maxcc(results)

    builder.change_punchcard_output("/tmp/punch.dummy".format(cwd))
    
    with open("{}/brexx_xmit.punch".format(cwd), 'rb') as punchfile:
        if 'MVSCE' in mvs_type:
            punchfile.seek(160)
        rxmvsext_obj = punchfile.read()[:-80]

    with open("{}/BREXX.{}.{}.XMIT".format(cwd,VERSION,out_type), 'wb') as obj_out:
        obj_out.write(rxmvsext_obj)

    print(" # {}/BREXX_{}.{}.XMIT created".format(cwd,VERSION,out_type))

    with open("{}/BREXX.{}.{}.jcl".format(cwd,VERSION,out_type), 'w') as jcl_out:
        jcl_out.write(jcl_builder.UNXMIT_jcl(
            filename="{}/BREXX.{}.{}.XMIT".format(cwd,VERSION,out_type),
            version=VERSION,
            unit=o_unit,
            volser=o_volser,
            mvsce=True if 'MVSCE' in mvs_type else False
            ))

    command = [
                "rdrprep", 
                "{}/BREXX.{}.{}.jcl".format(cwd,VERSION,out_type),
                "{}/BREXX.{}.{}.INSTALL.jcl".format(cwd,VERSION,out_type)
                ]
    try:
        subprocess.run(command, check=True)
        print(" # {}/BREXX.{}.{}.INSTALL.jcl created".format(cwd,VERSION,out_type))
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
    print(" # {}/BREXX.{}.{}.INSTALL.jcl created".format(cwd,VERSION,out_type))

    readme = jcl_builder.template(f'{cwd}/templates/readme.template')

    with open(f'{cwd}/README.txt','w') as out_readme:
        out_readme.write(readme.format(version=VERSION))

VERSION = os.environ.get('BREXX_VERSION')
if not VERSION:
    with open(f"{cwd}/../inc/rexx.h", 'r') as rexx_header:
        for l in rexx_header.readlines():
            if "#define VERSION" in l:
                VERSION = l.split()[2].strip('"')
                break

def print_maxcc(cc_list):
    # Get the maximum length of each column
    print(" # Completed!\n # Results:\n #")
    max_lengths = {key: max(len(key), max(len(str(item[key])) for item in cc_list)) for key in cc_list[0]}  
    # Print the table headers
    print(" # "+" | ".join(f"{key.ljust(max_lengths[key])}" for key in cc_list[0]))
    # Print a separator line
    print(" # "+"-" * (sum(int(length) for length in max_lengths.values()) + len(max_lengths) + 5 ))
    # Print the table rows
    for row in cc_list:
        exitcode = str(row['exitcode'])
        
        if exitcode == '0000' or exitcode == "*FLUSH*":
            exitcode_msg = ""
        elif str.isdigit(exitcode) and int(exitcode) <= 4:
            exitcode_msg = " <-- Warning"            
        else:
            exitcode_msg = " <-- Failed"
        print(" # "+" | ".join(f"{(exitcode + exitcode_msg).ljust(max_lengths[key])}" if key == 'exitcode' else f"{str(row[key]).ljust(max_lengths[key])}" for key in row))
    
    print(" # "+"-" * (sum(int(length) for length in max_lengths.values()) + len(max_lengths) + 5 ))
    print(" #")        

class assemble: 

    def __init__(self,system='MVSCE',loglevel=logging.WARNING,username='IBMUSER',password='SYS1'):
        self.system = system
        self.linklib = 'SYSC.LINKLIB'
        if system != 'MVSCE':
            self.linklib = 'SYS2.LINKLIB'
        # Create the Logger
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.DEBUG)
        logger_formatter = logging.Formatter(
            '%(levelname)s :: %(funcName)s :: %(message)s')

        # Log to stderr
        ch = logging.StreamHandler()
        ch.setFormatter(logger_formatter)
        ch.setLevel(loglevel)
        if not self.logger.hasHandlers():
            self.logger.addHandler(ch)

        self.logger.debug("Building")
        self.logger.debug("User/Pass: {}/{}".format(username,password))
        self.logger.debug("System: {}".format(self.system))
        self.username = username
        self.password = password
    

    def jobcard(self, jobname, title, jclass='A', msgclass='A'):
        '''
        This function generates the jobcard needed to submit the jobs
        '''

        jobcard = self.template('{}/templates/jobcard.template'.format(cwd))

        if jobcard[-1] != "\n":
            jobcard += "\n"

        return jobcard.format(
            jobname=jobname.upper(),
            title=title,
            jclass=jclass,
            msgclass=msgclass,
            user=self.username.upper(),
            password=self.password.upper()
            )

    def punch_out(self, jes_class='B',dsn='&&OBJ'):
        '''
        This function returns the JCL to write &&OBJ to the punchcard writer

        jes_class: The class that sends the output to the card writer, usually 'B'
        '''
        self.logger.debug("JES CLASS for punch card output is '{}'".format(jes_class))
        
        punch_jcl = self.template('{}/templates/punchcard.template'.format(cwd))

        return punch_jcl.format(jes_class=jes_class,dsname=dsn)

    def temp_object_pds(self,temp_name='OBJECT'):
        '''
        This template uses IEFBR14 to create a temp PDS
        '''
               
        temp_obj = self.template('{}/templates/temp_obj.template'.format(cwd))
        
        self.logger.debug("Creating temp PDS: &&{}".format(temp_name))

        return temp_obj.format(temp_name=temp_name)

    def brexx_maclib(self,temp_name='MACLIB',maclib_path="{}/../maclib".format(cwd)):

        self.logger.debug("Generating temp maclib &&{} using files in {}".format(temp_name,maclib_path))

        maclib = self.template('{}/templates/maclib.template'.format(cwd))
        
        p = Path(maclib_path).glob('**/*.hlasm')
        files = [x for x in p if x.is_file()]
        dd = ''
        for macro in sorted(files):
            self.logger.debug("adding {}: ./ ADD NAME={}".format(macro,macro.stem.upper()))
            dd += "./ ADD NAME=" +macro.stem.upper() + "\n"
            with open(macro,'r') as mfile:
                dd += mfile.read().replace('¬','\x5e')
                if dd[-1] != "\n":
                    dd += "\n"

        # if self.system != 'MVSCE':
        #      dd = dd.replace('|','\x7c')c

        return(maclib.format(temp_name=temp_name,steplib=self.linklib,maclibs=dd))

    def RELEASE_jcl(self,HLQ=VERSION,
                    unit=3390,volser='pub001',
                    mvs_type="MVSCE",
                    catalog="UCPUB001",
                    o_unit='3380',o_volser='PUB000'):
        '''
        Generates the JCL needed to make a new release XMI of BREXX
        '''
        delete_template = self.template(f'{cwd}/templates/clean.template')
        new_pds_template = self.template(f'{cwd}/templates/pdsload_new.template')
        linklib_template = self.template(f'{cwd}/templates/newpds.template')
        # Make APF PDS
        # Make Non-apf
        release_template = self.template(f'{cwd}/templates/release.template')

        linklib_jcl = linklib_template.format(stepname='BRLINKLB',dsname1=f'BREXX.{HLQ}.LINKLIB',unit=unit,volser=volser.upper())
        apflib_jcl = linklib_template.format(stepname='BRAPFLNK',dsname1=f'BREXX.{HLQ}.APF.LINKLIB',unit=unit,volser=volser.upper())

        proclib = self.pdsload_folder(f'{cwd}/../proclib')
        jcl = self.pdsload_folder(f'{cwd}/../jcl')
        rxlib = self.pdsload_folder(f'{cwd}/../rxlib')
        cmdlib = self.pdsload_folder(f'{cwd}/../cmdlib')
        samples = self.pdsload_folder(f'{cwd}/../samples')
        install = self.pdsload_folder(f'{cwd}/jcl')

        delete_jcl = ''
        for dsn in [f'BREXX.{HLQ}.LINKLIB',
                    f'BREXX.{HLQ}.APF.LINKLIB',
                    f'BREXX.{HLQ}.XMIT',
                    f'BREXX.{HLQ}.INSTALL']:

            stepname = ('DL' + dsn.split('.')[-1])[:8]
            delete_jcl += delete_template.format(stepname=stepname,dsname1=dsn)
        
        new_pds_jcl = ''
        for dsn in [f'BREXX.{HLQ}.JCL',
                    f'BREXX.{HLQ}.SAMPLES',
                    f'BREXX.{HLQ}.RXLIB',
                    f'BREXX.{HLQ}.CMDLIB',
                    f'BREXX.{HLQ}.PROCLIB']:
            stepname = dsn.split('.')[-1]

            if 'PROCLIB' in dsn:
                lib = proclib
            elif 'JCL' in dsn:
                lib = jcl.format(
                        date=datetime.now().strftime("%m/%d/%y"),
                        time=datetime.now().strftime('%H:%M:%S'),
                        builder='Autobuild',
                        HLQ=HLQ,
                        version=VERSION
                        )
            elif 'RXLIB' in dsn:
                lib = rxlib
            elif 'CMDLIB' in dsn:
                lib = cmdlib
            elif 'SAMPLES' in dsn:
                lib = samples

            new_pds_jcl += new_pds_template.format(delname=('DL'+stepname)[:8],
                                                    create=stepname,
                                                    dsname1=dsn,
                                                    unit=unit,
                                                    volser=volser.upper(),
                                                    steplib=self.linklib,
                                                    rxlibs=lib)
        
        steplib = ''
        if 'MVSCE' in mvs_type:
            steplib = f"\n//STEPLIB DD DISP=SHR,DSN={self.linklib}"

        release_jcl = release_template.format(
                brexx_build_loadlib='BREXX.BUILD.LOADLIB',
                cmdlib=f'BREXX.{HLQ}.CMDLIB',
                install_jcl=install.format(
                                       date=datetime.now().strftime("%m/%d/%y"),
                                       time=datetime.now().strftime('%H:%M:%S'),
                                       builder='Autobuild',
                                       HLQ=HLQ,unit=o_unit,
                                       volser=o_volser.upper(),
                                       steplib=steplib,
                                       version=VERSION,
                                       catalog=catalog),
                install_pds=f'BREXX.{HLQ}.INSTALL',
                jcllib=f'BREXX.{HLQ}.JCL',
                proclib=f'BREXX.{HLQ}.PROCLIB',
                rxlib=f'BREXX.{HLQ}.RXLIB',
                samplib=f'BREXX.{HLQ}.SAMPLES',
                steplib=self.linklib,
                xmit_steplib=steplib,
                unit=unit,
                version=HLQ,
                volser=volser.upper(),
                xmit_pds=f'BREXX.{HLQ}.XMIT',
            )
        
        return(
            self.jobcard('RELEASE','Build BREXX Release') +
            delete_jcl +
            linklib_jcl +
            new_pds_jcl +
            apflib_jcl +
            release_jcl +
            self.punch_out(dsn=f'BREXX.{HLQ}.XMIT')
        )
    
    def RELEASE_TEST(self, mvs_type='MVSCE', unit='3380',volser='PUB001',HLQ=VERSION,
                    catalog="UCPUB001",):

        date=datetime.now().strftime("%m/%d/%y")

        steplib = ''
        if 'MVSCE' in mvs_type:
            steplib = f"\n//STEPLIB DD DISP=SHR,DSN={self.linklib}"

        with open(f'{cwd}/jcl/$CLEANUP.template','r') as injcl:
            lines = injcl.readlines()
            clean = lines[2:]
            clean = ''.join(clean)
            clean_jcl = clean.format(HLQ=HLQ,version=VERSION,date=date)
        with open(f'{cwd}/jcl/$UNPACK.template','r') as injcl:
            lines = injcl.readlines()
            clean = lines[2:]
            clean = ''.join(clean)
            unpack_jcl = clean.format(HLQ=HLQ,version=VERSION,date=date,steplib=steplib,unit=unit,volser=volser.upper())
        with open(f'{cwd}/jcl/$INSTALL.template','r') as injcl:
            lines = injcl.readlines()
            clean = lines[2:]
            clean = ''.join(clean)
            install_jcl = clean.format(HLQ=HLQ,version=VERSION,catalog=catalog,date=date)
        with open(f'{cwd}/jcl/$INSTAPF.template','r') as injcl:
            lines = injcl.readlines()
            clean = lines[2:]
            clean = ''.join(clean)
            instapf_jcl = clean.format(HLQ=HLQ,version=VERSION,catalog=catalog,date=date)
            
        return(self.jobcard('INSTTEST','TEST INSTALL') + clean_jcl + unpack_jcl + install_jcl +instapf_jcl)
                    
    def UNXMIT_jcl(self,filename,version=VERSION,unit=3390,volser='pub001',mvsce=True):
        self.logger.debug(f"Creating Install JCL with verion={version} unit={unit} volser={volser} mvsce={mvsce}")
        delete_template = self.template(f'{cwd}/templates/clean.template')


        delete_jcl = ''
        for dsn in [f'BREXX.{version}.XMIT',
                    f'BREXX.{version}.INSTALL']:

            stepname = ('DL' + dsn.split('.')[-1])[:8]
            delete_jcl += delete_template.format(stepname=stepname,dsname1=dsn)

        unxmit_template = self.template(f'{cwd}/templates/unxmit.template')
        steplib = ''
        if mvsce:
            steplib = f"\n//STEPLIB DD DISP=SHR,DSN={self.linklib}"

        return(
            self.jobcard('BRUNXMIT','Brexx UNXMIT') + delete_jcl +
            unxmit_template.format(
                brexx_filename=filename,
                steplib=steplib,
                unit=unit,
                volser=volser.upper(),
                HLQ=version
                )
        )


    def RXMVSEXT_jcl(self):
        '''
        Generates the rxmvsext object file
        '''

        self.logger.debug("Building rxmvsext.obj")

        punch_jcl = self.template('{}/templates/rxmvsext.template'.format(cwd))

        files = [i[1] for i in Formatter().parse(punch_jcl)  if i[1] is not None]

        fpath = "{}/../asm/".format(cwd)
        file_contents = {}
        for fname in files:
            hlasm_file = fpath + fname + ".hlasm"
            self.logger.debug("reading: {}".format(hlasm_file))
            with open(hlasm_file, 'r') as infile:
                hlasm = infile.read().replace('¬','\x5e')

                # if hlasm[-1] != "\n":
                #     hlasm += "\n"
            file_contents[fname] = hlasm
        rxmvsext_jcl = (
                        self.jobcard("rxmvsext",'RXMVSEXT') + 
                        self.brexx_maclib() + 
                        punch_jcl.format(**file_contents) + 
                        self.punch_out()
                       )

        return(rxmvsext_jcl)
       
    def asmfcl(self,module_name,source,alternate=False):        
        self.logger.debug("Running ASMFCL for: '{}'")

        if not alternate:
            
            asmfcl_assemble = self.template('{}/templates/asmfcl.template'.format(cwd))
            
            asmfcl_jcl = (
                    self.jobcard(module_name.upper(),module_name.upper()) + 
                    self.brexx_maclib(temp_name='MACLIB') + self.brexx_maclib(temp_name='ASMMAC',maclib_path='{}/../asm'.format(cwd)) +  
                    asmfcl_assemble.format(module=module_name.upper(),source=source)
                    )
        else:
            
            asmfcl_assemble = self.template('{}/templates/asmfcl_alternate.template'.format(cwd))
            
            asmfcl_jcl = (
                    self.jobcard(module_name.upper(),module_name.upper()) + 
                    self.brexx_maclib(temp_name='MACLIB') +  
                    asmfcl_assemble.format(module=module_name.upper(),source=source)
                    )

        return(asmfcl_jcl)

    def IRXEXCOM_jcl(self,which="SVC"):
        '''
        Links IRXEXCOM
        '''

        irxexcom_link_template = self.template('{}/templates/irxexcom_link.template'.format(cwd))
        
        return (
            self.jobcard('IRXEXCOM','IRXEXCOM') +   
            irxexcom_link_template.format(path=cwd)
               )

    def BREXX_link_jcl(self,which="SVC"):
        '''
        Links BREXX
        '''

        brexx_link_template = self.template('{}/templates/brexx_link.template'.format(cwd))
        
        return (
            self.jobcard('BREXXLNK','BREXXLNK') +   
            brexx_link_template.format(brexx_path=cwd+"/brexx.objp")
               )

    def METAL_jcl(self,which="SVC"):
        '''
        assembles SVC or GETSA
        '''

        metal_assemble = self.template('{}/templates/metal.template'.format(cwd))
        
        asmfc_jcl = ''

        if which == "SVC":
            with open('{}/../asm/svc.hlasm'.format(cwd), 'r') as svc_hlasm:
                self.logger.debug("reading: {}/../asm/svc.hlasm".format(cwd))
                asmfc_jcl = metal_assemble.format(module='SVC', source=svc_hlasm.read().replace('¬','\x5e'),jes_class='B')
        
        
        if which == "GETSA":
            with open('{}/../asm/getsa.hlasm'.format(cwd), 'r') as getsa_hlasm:
                self.logger.debug("reading: {}/../asm/getsa.hlasm".format(cwd))
                asmfc_jcl += metal_assemble.format(module='GETSA', source=getsa_hlasm.read().replace('¬','\x5e'),jes_class='B')

        metal_jcl = (
                        self.jobcard(which,'metal {}'.format(which)) +
                        self.brexx_maclib(temp_name='MACLIB') +
                        asmfc_jcl
                    )
        
        return(metal_jcl)

    def TESTS_jcl(self,unit=3390,volser='pub001'):
        '''
        generates the test.jcl from /test
        '''
        
        tests_template = self.template('{}/templates/tests.template'.format(cwd))
        clean_template = self.template('{}/templates/clean.template'.format(cwd))

        clean_jcl = ''
        for dsn in ['BREXX.BUILD.RXLIB',
                    'BREXX.BUILD.SAMPLES','BREXX.BUILD.TESTS']:

            stepname = dsn.split('.')[-1]
            clean_jcl += clean_template.format(stepname=stepname,dsname1=dsn)

        with open('{}/../test/rxtest.rxlib'.format(cwd),'r') as rexx_file:
            rxtest = rexx_file.read()

        with open('{}/../proclib/RXBATCH.jcl'.format(cwd),'r') as jcl_file:
            lines = [line.rstrip('\n') for line in jcl_file.readlines()]
            for i, line in enumerate(lines):
                if "//REXX     PROC EXEC='',P=''," in line:
                    lines[i] = line.replace("//REXX", "//RXBATCH")

                if "//         LIB='" in line:
                    lines[i] = "//         LIB='BREXX.BUILD.RXLIB',"

                if "//RXRUN" in line:
                    lines.insert(i + 1, "//STEPLIB DD DISP=SHR,DSN=BREXX.BUILD.LOADLIB")
                    break

            # Join the lines back together
            rxlib_proc = "\n".join(lines) + "\n" + "//         PEND\n"

        p = Path('{}/../test'.format(cwd)).glob('**/*.rexx')
        files = [x for x in p if x.is_file()]

        add = "./ ADD NAME={}\n"
        proc = "//{rexx:8s} EXEC RXBATCH,SLIB='BREXX.BUILD.TESTS',EXEC={rexx:8s}\n"

        dd = ''
        procs = ''

        for rexx in sorted(files):
            self.logger.debug("Opening {}".format(rexx))
            dd += add.format(rexx.stem.upper())
            procs += proc.format(rexx=rexx.stem.upper())
            with open(rexx,'r') as rexx_file:
                rfile = rexx_file.read().replace('¬','\x5e').replace('"||VER||"','BUILD')
                
                if rfile[-1] != '\n':
                    dd += rfile + "\n"
                else:
                    dd += rfile
        
        return (
            self.jobcard("TESTS",'TESTS') + clean_jcl + rxlib_proc +
            self.create_samples_build(unit=unit,volser=volser.upper()) +
            self.create_rxlib_build(unit=unit,volser=volser.upper()) +
            tests_template.format(
                rxtest=rxtest,
                test_rexx=dd,
                unit=unit,
                volser=volser.upper(),
                proc_exec=procs[:-1],
                linklib = self.linklib)
        )

        

    def IRXVTOC_jcl(self):
        '''
        Generates the irxvtoc object file
        '''

        iewl_syslin = " INCLUDE OBJ({})\n"

        self.logger.debug("Building irxvtoc.obj")

        irxvtoc_assemble = self.template('{}/templates/irxvtoc_assemble.template'.format(cwd))

        p = Path('{}/../asm'.format(cwd)).glob('**/vtoc*.hlasm')
        files = [x for x in p if x.is_file()]

        vtoc_hlasm_jcl = ''
        iewl_objs = ''
        for vtoc_hlasm in sorted(files):
            self.logger.debug("Opening {}".format(vtoc_hlasm))
            with open('{}'.format(vtoc_hlasm),'r') as vtoc_hlasm_file:
                vtoc_hlasm_jcl += irxvtoc_assemble.format(
                    module=vtoc_hlasm.stem.upper(),
                    source=vtoc_hlasm_file.read().replace('¬','\x5e'),
                    asm_maclib='ASMMAC',maclib='MACLIB'
                    )
            iewl_objs += iewl_syslin.format(vtoc_hlasm.stem.upper())

        irxvtoc_link = self.template('{}/templates/irxvtoc_link.template'.format(cwd))

        irxvtoc_jcl = (
                        self.jobcard("irxvtoc",'irxvtoc') +
                        self.temp_object_pds() +
                        self.brexx_maclib(temp_name='MACLIB') + self.brexx_maclib(temp_name='ASMMAC',maclib_path='{}/../asm'.format(cwd)) +
                        vtoc_hlasm_jcl + irxvtoc_link.format(objects=iewl_objs[:-1])
                       )

        return(irxvtoc_jcl)

    def pdsload_folder(self, folder_path): 
        self.logger.debug(f"Reading all files in {folder_path}") 
        p = Path(folder_path).glob('**/*')
        files = [x for x in p if x.is_file()]
        dd = ''
        for infile in sorted(files):
            if infile == 'README.MD':
                self.logger.debug("adding {}: ./ ADD NAME=$$README".format(infile.stem.upper()))
                dd += "./ ADD NAME=$$README\n"
            else:
                self.logger.debug("adding {}: ./ ADD NAME={}".format(infile,infile.stem.upper()))
                dd += "./ ADD NAME=" +infile.stem.upper() + "\n"
            with open(infile,'r') as mfile:
                dd += mfile.read().replace('¬','\x5e')
                if dd[-1] != "\n":
                    dd += "\n"
        return dd

    def template(self,template_file):

        with open(template_file, 'r') as template:
            self.logger.debug(f"reading: {template_file}")
            return template.read()

    def INSTALL_jcl(self,
                       hlq2 = VERSION,
                       unit='3390',volser='PUB001',
                       linklib='SYS2.LINKLIB',
                       fromdsn='BREXX.BUILD.LOADLIB'
                    ):
        install_jcl = self.template('{}/templates/install.template'.format(cwd))
        copy_template = self.template('{}/templates/copy.template'.format(cwd))
        clean_template = self.template('{}/templates/clean.template'.format(cwd))

        HLQ = hlq2

        pdses = [
                 f'BREXX.{HLQ}.PROCLIB',
                 f'BREXX.{HLQ}.JCL',
                 f'BREXX.{HLQ}.RXLIB',
                 f'BREXX.{HLQ}.CMDLIB',
                 f'BREXX.{HLQ}.SAMPLES'
                 ]

        clean_jcl = ''

        for pds in pdses:
            stepname = ('DL'+pds.split('.')[-1])[:8]
            clean_jcl += clean_template.format(stepname=stepname,dsname1=pds)

        proclib = self.pdsload_folder(f'{cwd}/../proclib')
        jcl = self.pdsload_folder(f'{cwd}/../jcl')
        rxlib = self.pdsload_folder(f'{cwd}/../rxlib')
        cmdlib = self.pdsload_folder(f'{cwd}/../cmdlib')
        samples = self.pdsload_folder(f'{cwd}/../samples')



        return(self.jobcard("INSTALL",'INSTALL') +
                clean_jcl +
                copy_template.format(indsn=fromdsn,outdsn=linklib) +
                install_jcl.format(
                    current=hlq2,
                    steplib=self.linklib,
                    unit=unit,
                    volser=volser.upper(),
                    proclib=proclib,
                    jcl=jcl,
                    rxlib=rxlib,
                    cmdlib=cmdlib,
                    samples=samples
                                ) +
                copy_template.format(indsn=f'BREXX.{hlq2}.PROCLIB',outdsn='SYS2.PROCLIB')
                ) 

    def CLEAN_jcl(self,HLQ=VERSION):
        '''
        Deletes the created pds's used for make/testing
        '''

        clean_jcl = self.template('{}/templates/clean.template'.format(cwd))
        clean_link_jcl = self.template('{}/templates/clean_linklib.template'.format(cwd))


        pdses = ['BREXX.BUILD.LOADLIB',
                 'BREXX.BUILD.RXLIB',
                 'BREXX.BUILD.SAMPLES',
                 'BREXX.BUILD.TESTS',
                 f'BREXX.{HLQ}.PROCLIB',
                 f'BREXX.{HLQ}.JCL',
                 f'BREXX.{HLQ}.RXLIB',
                 f'BREXX.{HLQ}.CMDLIB',
                 f'BREXX.{HLQ}.XMIT',
                 f'BREXX.{HLQ}.SAMPLES'
                 ]

        jcl = ''

        for pds in pdses:
            stepname = pds.split('.')[-1]
            jcl += clean_jcl.format(stepname=stepname,dsname1=pds)

        
        return(self.jobcard("CLEAN",'CLEAN') + jcl + clean_link_jcl) 
    
    def IRXVSMIO_jcl(self):
        '''
        Generates the irxvsmio object file
        '''

        self.logger.debug("Building irxvsmio.obj")

        with open("{}/../asm/rxvsmio1.hlasm".format(cwd),'r') as infile:
            rxvsmio1_source = infile.read().replace('¬','\x5e')
        
        return(self.asmfcl("IRXVSMIO",rxvsmio1_source)  )
         
    def MVSDUMP_jcl(self):
        '''
        Generates the mvsdump object file
        '''

        self.logger.debug("Building mvsdump.obj")

        with open("{}/../asm/mvsdump.hlasm".format(cwd),'r') as infile:
            mvsdump_source = infile.read().replace('¬','\x5e')
        
        return(self.asmfcl("MVSDUMP",mvsdump_source,alternate=True)  )
         
    def IRXISTAT_jcl(self):
        '''
        Generates the irxistat object file
        '''

        self.logger.debug("Building irxistat.obj")

        with open("{}/../asm/rxpdstat.hlasm".format(cwd),'r') as infile:
            rxpdstat_source = infile.read().replace('¬','\x5e')
        
        return(self.asmfcl("IRXISTAT",rxpdstat_source,alternate=True))

    def IRXNJE38_jcl(self,nje_maclib='NJE38.MACLIB',nje_authlib='NJE38.AUTHLIB'):
        '''
        Assembles and links IRXNJE38
        '''

        self.logger.debug("Assembling and linking IRXNJE38")
        nje38_jcl = self.template(f'{cwd}/templates/nje38.template')

        with open("{}/../asm/rxnje38.hlasm".format(cwd),'r') as infile:
            rxnje38_soure = infile.read().replace('¬','\x5e')

        return(
            self.jobcard('IRXNJE38','IRXNJE38') + 
            self.brexx_maclib() +
            self.brexx_maclib(temp_name='ASMMAC',maclib_path='{}/../asm'.format(cwd)) + 
            nje38_jcl.format(nje_hlasm=rxnje38_soure,nje_maclib=nje_maclib,nje_authlib=nje_authlib)
            )

    def IRXVSMTR_jcl(self):
        '''
        Generates the irxvsmtr.obj object file
        '''

        self.logger.debug("Building irxvsmtr.obj")

        with open("{}/../asm/rxvsmio2.hlasm".format(cwd),'r') as infile:
            rxvsmio2_soure = infile.read().replace('¬','\x5e')
        
        return(self.asmfcl("IRXVSMTR",rxvsmio2_soure))
    
    def check_member_length(self,folder_path):
        '''
            This function will check all files in a folder
            and return an list of all files and that have
            lines longer than 80 chars and the line number
        '''

        p = Path(folder_path).glob('**/*')
        files = [x for x in p if x.is_file()]
        dd = ''
        errors = []
        errmsg = '{}:{}'
        for mbr_file in sorted(files):
            self.logger.debug(f" Checking {mbr_file}")
            if 'HOUSING' in str(mbr_file):
                self.logger.debug(f" # ** Skipping {mbr_file} to avoid false positive **")
                # We skip the HOUSING files because they contain a lot of lines
                # and there's no easy way to change them
                continue
            with open(mbr_file,'r') as mfile:
                for i, line in enumerate(mfile.readlines()):
                    if len(line.strip()) > 80:
                        self.logger.debug(errmsg.format(mbr_file,i+1))
                        errors.append(errmsg.format(mbr_file,i+1))
        return errors

    def check_length(self):
        errors = []
        folders = ["proclib","jcl","rxlib","cmdlib","samples"]

        for f in folders:
            errors += self.check_member_length(f'{cwd}/../{f}')

        return errors

    def create_brexx_build(self,
                           dsname1="BREXX.BUILD.LOADLIB",
                           unit='3380',volser='PUB000'):
        
        new_pds = self.template('{}/templates/newpds.template'.format(cwd))

        new_jcl = (
                self.jobcard('NEWPDS','NEWPDS') +
                new_pds.format(stepname='BRXLDL',dsname1=dsname1,unit=unit,volser=volser.upper())
            )

        return(new_jcl)

    def create_samples_build(self,delname='DELSMPLS',create='SAMPLIB',
                           dsname1="BREXX.BUILD.SAMPLES",
                           unit='3380',volser='PUB000',
                           samples_path="{}/../samples".format(cwd)):
        return(self.create_rxlib_build(
                delname=delname,
                create=create,
                dsname1=dsname1,
                unit=unit,
                volser=volser,
                rxlib_path=samples_path
            ))
    
    def create_rxlib_build(self,delname='DELSMPLS',create='RXLIB',
                           dsname1="BREXX.BUILD.RXLIB",
                           unit='3380',volser='PUB000',
                           rxlib_path="{}/../rxlib".format(cwd)):
        

        self.logger.debug("Generating rxlib pds using files in {}".format(rxlib_path))

        rxlib_pds = self.template('{}/templates/pdsload_new.template'.format(cwd))
        
        p = Path(rxlib_path).glob('**/*.rexx')
        files = [x for x in p if x.is_file()]
        dd = ''
        for rxlib in sorted(files):
            self.logger.debug("adding {}: ./ ADD NAME={}".format(rxlib,rxlib.stem.upper()))
            dd += "./ ADD NAME=" +rxlib.stem.upper() + "\n"
            with open(rxlib,'r') as mfile:
                dd += mfile.read().replace('¬','\x5e')
                if dd[-1] != "\n":
                    dd += "\n"

        return(
            rxlib_pds.format(
                delname=delname,
                create=create,
                dsname1=dsname1,
                steplib=self.linklib,
                rxlibs=dd,unit=unit,volser=volser.upper()
                )
              )

    def copy_members(self,indsn='BREXX.BUILD.LOADLIB',outdsn='SYS2.LINKLIB'):
        '''
            Generates JCL to copy all members from indsn to outdsn
        '''

        copy_template = self.template('{}/templates/copy.template'.format(cwd))

        return(
                self.jobcard('COPYMBR','COPYMBR') +
                copy_template.format(indsn=indsn,outdsn=outdsn)
                )
    
    def write_jcl_file(self,jcl_file,filename):
        with open("{}/{}".format(cwd,filename),'w') as outjcl:
            outjcl.write(jcl_file)


desc = 'A tool that Generates JCL, submits it, and (if applicable) generates the needed obj file'
arg_parser = argparse.ArgumentParser(description=desc)
arg_parser.add_argument('-d', '--debug', help="Print debugging statements", action="store_const", dest="loglevel", const=logging.DEBUG, default=logging.WARNING)
arg_parser.add_argument('-f', '--folder', help="MVS/CE or tk4- or tk5 folder location", default="/MVSCE")
arg_parser.add_argument('-s','--system',help="Either MVSCE, TK4-, or TK5", default="MVSCE")
arg_parser.add_argument('--ip',help="If the system is TK4-, or TK5 provide the IP address", default="127.0.0.1")
arg_parser.add_argument('--punch',help="If the system is TK4-, or TK5 provide the card reader port", default=3505)
arg_parser.add_argument('--web',help="If the system is TK4-, or TK5 provide the web server port", default=8038)
arg_parser.add_argument('-u','--user',help="MVS system username for jobcard", default="IBMUSER")
arg_parser.add_argument('-p','--password',help="MVS system password for jobcard", default="SYS1")
arg_parser.add_argument('--print',help="Just print the JCL generated", action='store_true')

group = arg_parser.add_mutually_exclusive_group(required=True)
group.add_argument('--BREXX',help="Links the BREXX objp file to BREXX.BUILD.LOADLIB", action='store_true')
group.add_argument('--CLEAN',help="Removes the datasets used in building: BREXX.BUILD.LOADLIB/RXLIB/TESTS", action='store_true')
group.add_argument('--INSTALL',help=f"Installs BREXX to BREXX.{VERSION} and SYS2.LINKLIB", action='store_true')
group.add_argument('--IRXEXCOM',help="Assembles and Links the IRXEXCOM file", action='store_true')
group.add_argument('--IRXISTAT',help="Assembles and Links the IRXISTAT file", action='store_const', const='IRXISTAT', dest='step')
group.add_argument('--IRXNJE38',help="Assembles and Links the IRXNJE38 file", action='store_const', const='IRXNJE38', dest='step')
group.add_argument('--IRXVSMIO',help="Assembles and Links the IRXVSMIO file", action='store_const', const='IRXVSMIO', dest='step')
group.add_argument('--IRXVSMTR',help="Assembles and Links the IRXVSMTR file", action='store_const', const='IRXVSMTR', dest='step')
group.add_argument('--IRXVTOC',help="Assembles and Links the IRXVTOC file", action='store_const', const='IRXVTOC', dest='step')
group.add_argument('--LENGTH',help="Checks files in rxlib, samples, etc for any files with more than 80 chars", action='store_true')
group.add_argument('--METAL',help="Builds the METAL object file", action='store_true')
group.add_argument('--MVSDUMP',help="Assembles and Links the MVSDUMP file", action='store_const', const='MVSDUMP', dest='step')
group.add_argument('--RELEASE',help="Generates the BREXX XMIT Release", action='store_true')
group.add_argument('--RELEASE_TEST',help="Tests the release JCL and install JCL files", action='store_true')
group.add_argument('--RXMVSEXT',help="Builds the RXMVSEXT object file", action='store_true')
group.add_argument('--TESTS',help="Runs the BREXX tests in /test", action='store_true')
group.add_argument('--write_all',help="Writes every steps JCL to a file named after the step", action='store_true')

args = arg_parser.parse_args()

if args.TESTS:
    timeout = 120
else:
    timeout = 60

if args.system.upper() not in ['MVSCE','TK5','TK4-']:
    print(f"{args.system} not supported. Must be one of MVSCE, TK5 or TK4-")
    sys.exit(-1)

mvs_type = args.system.upper()

print_only = any([args.print, args.write_all, args.LENGTH])

if args.system != 'MVSCE':
    mvsce = False
else:
    mvsce = True

if not print_only:
    builder = automation(system=mvs_type,
                          system_path=args.folder,
                          ip = args.ip,
                          punch_port = args.punch,
                          web_port = args.web,
                          timeout=timeout,
                          loglevel = args.loglevel,
                          username=args.user,
                          password=args.password
                    )
    mvstk = builder
    if not mvsce:
        mvstk.change_punchcard_output("/tmp/dummy.punch".format(cwd))
        mvstk.send_oper("$s punch1")
        mvstk.send_oper("$z punch1")
        mvstk.send_herc("CODEPAGE  819/1047")

jcl_builder = assemble(system=args.system, loglevel=args.loglevel,username=args.user,password=args.password)

if args.write_all:
    print(" # Writing all JCL files")
    jcl_to_print = []
    for f in dir(assemble):
        jcl_funct = getattr(jcl_builder,f)
        if "_jcl" in f and "write_jcl_file" not in f:
            if f in ["TESTS_jcl", "INSTALL_jcl", "UNXMIT_jcl"]:
                if mvs_type == "TK5":
                    jcl_to_print.append(jcl_funct(unit=3390,volser='tk5001'))
                elif mvs_type == "TK4-":
                    jcl_to_print.append(jcl_funct(unit='3380',volser='pub001'))
            elif "METAL_jcl" in f:
                jcl_to_print.append(jcl_funct(which='SVC'))
                jcl_to_print.append(jcl_funct(which='GETSA'))
            else:
                jcl_to_print.append(jcl_funct())
        if "create_brexx_build" in f:
                jcl_to_print.append(jcl_funct())
    for job in jcl_to_print:
        write_jcl(job)
    sys.exit(0)

try:
    
    if mvsce and not print_only:
        attempts = 1
        while attempts < 3:
            try:
                builder.ipl(clpa=False)
                break 
            except Exception as e:
                print("IPL attempt {attempt} failed with error: {e}".format(attempt=attempts,e=e))
                attempts += 1
        else:
            raise Exception("Unable to start MVS/CE Automation, enable debugging with -d to observe what part is failing")
        

        if 'MVSCE' not in mvs_type:
            builder.send_herc("detach c")
            builder.send_herc("attach c 3505 3505 sockdev ascii trunc eof")

    try:
        # create the brexx.build.loadlib pds

        if 'MVSCE' in mvs_type:
            unit='3380'
            volser='PUB000'
        elif 'TK5' in mvs_type:
            unit='3390'
            volser='tk5001'
        else:
            unit='3380'
            volser='pub002'

        new_pds = jcl_builder.create_brexx_build(unit=unit,volser=volser)
        
        if args.print:
            print_jcl(new_pds)

        if not print_only:
            builder.submit(new_pds)
            builder.wait_for_job("NEWPDS")
            builder.check_maxcc("NEWPDS",ignore=True)
        
        # if for some reason we crash during a step this resets 000c device

    except ValueError as error:
        if 'Job NEWPDS not found in printer output' not in str(error):
            raise ValueError(error)

    if args.RXMVSEXT:
        print(" # Creating rxmvsext.punch")
        RXMVSEXT_jcl = jcl_builder.RXMVSEXT_jcl()
        if args.print:
            print_jcl(RXMVSEXT_jcl)
            sys.exit()

        if mvs_type.upper() in ['TK5','TK4-']:
            mvstk.change_punchcard_output("/tmp/dummy.punch".format(cwd))
            mvstk.send_oper("$s punch1")

        builder.change_punchcard_output("{}/rxmvsext.punch".format(cwd))
        print(" # Submitting RXMVSEXT JCL")
        builder.submit(RXMVSEXT_jcl)
        print(" # Waiting for RXMVSEXT to finish")

        if mvs_type.upper() in 'MVSCE':
            builder.wait_for_string("$HASP190 RXMVSEXT SETUP -- PUNCH1   -- F = STD1")
            builder.send_oper("$s punch1")
        
        builder.wait_for_job("RXMVSEXT")
        print(" # RXMVSEXT finished")
        results = builder.check_maxcc("RXMVSEXT")
        print_maxcc(results)

        if mvs_type.upper() in ['TK5','TK4-']:
            mvstk.change_punchcard_output("/tmp/punch.dummy".format(cwd))

        with open("{}/rxmvsext.punch".format(cwd), 'rb') as punchfile:
            if mvs_type.upper() in 'MVSCE':
                punchfile.seek(160)
            rxmvsext_obj = punchfile.read()[:-80]

        with open("{}/rxmvsext.punch".format(cwd), 'wb') as obj_out:
            obj_out.write(rxmvsext_obj)

        print(" # {}/rxmvsext.punch created".format(cwd))

    if args.step:
        jcl_funct = getattr(jcl_builder,f'{args.step}_jcl')
        jcl = jcl_funct()

        if args.print:
            print_jcl(jcl)
            sys.exit()
        

        print(f" # Submitting {args.step} JCL")
        builder.submit(jcl)
        print(f" # Waiting for {args.step} to finish")
        builder.wait_for_job(args.step)
        results = builder.check_maxcc(args.step)
        print_maxcc(results)

    if args.METAL:

        print(" # Assembling SVC and GETSA")
        print(" # Assembling SVC")
        METAL_SVC_jcl = jcl_builder.METAL_jcl(which='SVC')
        METAL_GETSA_jcl = jcl_builder.METAL_jcl(which='GETSA')

        if args.print:
            print_jcl(METAL_SVC_jcl)
            print_jcl(METAL_GETSA_jcl)
            sys.exit()
        

        builder.change_punchcard_output("{}/SVC.punch".format(cwd))
        builder.send_oper("$s punch1")
        print(" # Submitting SVC JCL")
        builder.submit(METAL_SVC_jcl)
        print(" # Waiting for SVC to finish")

        if 'MVSCE' in mvs_type:
            builder.wait_for_string("$HASP190 SVC      SETUP -- PUNCH1   -- F = STD1")
            builder.send_oper("$s punch1")

        builder.wait_for_job("SVC")
        results = builder.check_maxcc("SVC")
        print_maxcc(results)

        builder.change_punchcard_output("{}/GETSA.punch".format(cwd))
        builder.send_oper("$s punch1")
        print(" # Submitting GETSA JCL")
        builder.submit(METAL_GETSA_jcl)
        print(" # Waiting for GETSA to finish")
        builder.wait_for_job("GETSA")
        results = builder.check_maxcc("GETSA")
        print_maxcc(results)

        with open("{}/SVC.punch".format(cwd), 'rb') as punchfile:
            if mvsce:
                punchfile.seek(160)
            SVC_obj = punchfile.read()[:-80]

        with open("{}/SVC.punch".format(cwd), 'wb') as obj_out:
            obj_out.write(SVC_obj)
        print(" # {}/SVC.punch created".format(cwd))

        with open("{}/GETSA.punch".format(cwd), 'rb') as punchfile:
            if mvsce:
                punchfile.seek(160)
            GETSA_obj = punchfile.read()[:-80]

        with open("{}/GETSA.punch".format(cwd), 'wb') as obj_out:
            obj_out.write(GETSA_obj)
        print(" # {}/GETSA.punch created".format(cwd))

    if args.IRXEXCOM:
        
        print(" # Linking IRXEXCOM in to BREXX.BUILD.LOADLIB")

        irxexcom_jcl = jcl_builder.IRXEXCOM_jcl()

        if args.print:
            print_jcl(irxexcom_jcl)
            sys.exit()
            

        with open("{}/irxexcom.jcl".format(cwd),'w') as outjcl:
            outjcl.write(irxexcom_jcl)

        command = ["rdrprep", "{}/irxexcom.jcl".format(cwd),"{}/irxexcom_reader.jcl".format(cwd)]
        try:
            subprocess.run(command, check=True)
            print(" # irxexcom_reader.jcl created")
        except subprocess.CalledProcessError as e:
            print(f"Error executing command: {e}")

        with open('{}/irxexcom_reader.jcl'.format(cwd),'rb') as injcl:

            if 'MVSCE' not in mvs_type:
                    builder.send_herc("detach c")
                    builder.send_herc("attach c 3505 3506 sockdev ebcdic trunc eof")
            
            builder.submit(injcl.read(),port=3506, ebcdic=True)
            print(" # Waiting for IRXEXCOM to finish")
            builder.wait_for_job("IRXEXCOM")
            if 'MVSCE' not in mvs_type:
                builder.send_herc("detach c")
                builder.send_herc("attach c 3505 3505 sockdev ascii trunc eof")
            results = builder.check_maxcc("IRXEXCOM",steps_cc={'LKED':'0004'})
                

        print_maxcc(results)

    if args.BREXX:
        print(" # Linking BREXX in to BREXX.BUILD.LOADLIB")
        brexx_link = jcl_builder.BREXX_link_jcl()
        if args.print:
            print_jcl(brexx_link)
            sys.exit()
            
        with open("{}/brexx_link.jcl".format(cwd),'w') as outjcl:
            outjcl.write(brexx_link)

        command = ["rdrprep", "{}/brexx_link.jcl".format(cwd),"{}/brexx_reader.jcl".format(cwd)]
        try:
            subprocess.run(command, check=True)
            print(" # brexx_reader.jcl created")
        except subprocess.CalledProcessError as e:
            print(f"Error executing command: {e}")
        
        with open('{}/brexx_reader.jcl'.format(cwd),'rb') as injcl:
            brexx_jcl = injcl.read()
            
        if 'MVSCE' not in mvs_type:
            builder.send_herc("detach c")
            builder.send_herc("attach c 3505 3506 sockdev ebcdic trunc eof")
    
        builder.submit(brexx_jcl,port=3506, ebcdic=True)
        print(" # Waiting for BREXX to finish")
        builder.wait_for_job("BREXXLNK")
        if 'MVSCE' not in mvs_type:
            builder.send_herc("detach c")
            builder.send_herc("attach c 3505 3505 sockdev ascii trunc eof")
        results = builder.check_maxcc("BREXXLNK")


        print_maxcc(results)

    if args.TESTS:

        test_jcl = jcl_builder.TESTS_jcl(unit=unit,volser=volser)

        if args.print:
            print_jcl(test_jcl)
            sys.exit()
            
        print(" # Running all REXX scripts from ../test and TESTRX")
        
        builder.submit(test_jcl)
        builder.wait_for_job("TESTS")
        results = builder.check_maxcc("TESTS",ignore=False)
        print_maxcc(results)

    if args.CLEAN:
        print(f" # Removing all BREXX.BUILD and BREXX.{VERSION} datasets")
        clean_jcl = jcl_builder.CLEAN_jcl()

        if args.print:
            print_jcl(clean_jcl)
            sys.exit()

        builder.submit(clean_jcl)
        builder.wait_for_job("CLEAN")
        results = builder.check_maxcc("CLEAN",ignore=True)
        print_maxcc(results)

    if args.RELEASE:
        print(" # Generating BREXX Release XMI Files")

        if 'builder' not in locals():
            builder = False

        make_release(jcl_builder=jcl_builder,builder=builder,mvs_type=mvs_type,unit=unit,volser=volser,out_type='TK5')
        make_release(jcl_builder=jcl_builder,builder=builder,mvs_type=mvs_type,unit=unit,volser=volser,out_type='TK4-')
        make_release(jcl_builder=jcl_builder,builder=builder,mvs_type=mvs_type,unit=unit,volser=volser,out_type='MVSCE')

    if args.RELEASE_TEST:

        if 'MVSCE' in mvs_type:
            cat = 'UCPUB001'
        elif 'TK5' in mvs_type:
            cat = 'SYS1.MCAT.TK5'
        elif 'TK4-' in mvs_type:
            cat = 'SYS1.VMASTCAT'

        print(" # Testing {} install".format(mvs_type))
        
        test_install = jcl_builder.RELEASE_TEST(mvs_type=mvs_type, 
                                                unit=unit,
                                                volser=volser,
                                                HLQ=VERSION,
                                                catalog=cat)
        
        if args.print:
            print_jcl(test_install)
            sys.exit()
        
        with open("{}/BREXX.{}.{}.INSTALL.jcl".format(cwd,VERSION,mvs_type).format(cwd),'rb') as injcl:

            if 'MVSCE' not in mvs_type:
                    builder.send_herc("detach c")
                    builder.send_herc("attach c 3505 3506 sockdev ebcdic trunc eof")
            print("Submitting {}/BREXX.{}.{}.INSTALL.jcl".format(cwd,VERSION,mvs_type))
            builder.submit(injcl.read(),port=3506, ebcdic=True)
            print(" # Waiting for BRUNXMIT to finish")
            builder.wait_for_job("BRUNXMIT")
            if 'MVSCE' not in mvs_type:
                builder.send_herc("detach c")
                builder.send_herc("attach c 3505 3505 sockdev ascii trunc eof")
            results = builder.check_maxcc("BRUNXMIT")
            
            print(" # Results of {} install".format(mvs_type))
            print_maxcc(results)


        print(" # Testing $CLEANUP, $UNPACK, $INSTALL, and $INSTAPF for {} install".format(mvs_type))

        builder.submit(test_install)
        builder.wait_for_job("INSTTEST")
        results = builder.check_maxcc("INSTTEST")
        print_maxcc(results)

    if args.INSTALL:
        print(" # Installing BREXX to SYS2.LINKLIB")
        
        install_jcl = jcl_builder.INSTALL_jcl(unit=unit,volser=volser)

        if args.print:
            print_jcl(install_jcl)
            sys.exit()
            
        builder.submit(install_jcl)
        builder.wait_for_job("INSTALL")
        results = builder.check_maxcc("INSTALL")
        print_maxcc(results)

    if args.LENGTH:
        errors = jcl_builder.check_length()
        for e in errors:
            print(f" # {e}")
        if len(errors) > 0:
            raise Exception("Multiple files with lines longer than 80 " + 
                            "characters these will be cutoff during the " + 
                            "upload process")

finally:
    if mvsce and not print_only:
        builder.quit_hercules()