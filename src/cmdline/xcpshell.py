'''
Created on Dec 3, 2013

@author: gcardwel
'''

import sys, argparse, shlex
import cmd2
from comm import CANInterface
from comm import XCPConnection
from util import plugins
from util import STCRC
from util import srec



if not '..' in sys.path:
    sys.path.append('..')


plugins.loadPlugins()

def hexInt(param):
    return int(param, 0)

class ShellArgParserExit(Exception):
    pass

class ShellArgParser(argparse.ArgumentParser):
    def exit(self, status=0, message=None):
        raise ShellArgParserExit()


class XCPShell(cmd2.Cmd):
    intro = 'Welcome to the xcpshell.   Type help or ? to list commands.\n'
    file = None
    prompt = '(xcp) '
    interface = None
    connection = None
    calibration_page = 0
    paramFile = None
    boardType = None


    def onecmd(self, line):
        """Interpret the argument as though it had been typed in response
        to the prompt.

        This may be overridden, but should not normally need to be;
        see the precmd() and postcmd() methods for useful execution hooks.
        The return value is a flag indicating whether interpretation of
        commands by the interpreter should stop.

        """
        cmd, arg, line = self.parseline(line)
        if not line:
            return self.emptyline()
        if cmd is None:
            return self.default(line)
        self.lastcmd = line
        if line == 'EOF' :
            self.lastcmd = ''
        if cmd == '':
            return self.default(line)
        else:
            try:
                func = getattr(self, 'do_' + cmd)
            except AttributeError:
                return self.default(line)
            if hasattr(func, 'needConnection') and self.connection == None:
                return "Needs to be connected"
            if hasattr(func, "needInterface") and self.interface == None:
                return "Needs interface"
            return func(arg)

    def do_source(self, arg):
        'Run commands from a file:  source file.txt'
        self.close()
        with open(arg) as f:
            self.cmdqueue.extend(f.read().splitlines())


    def do_open(self, arg):
        pass

    def do_close(self, arg):
        pass

    def do_import(self, arg):
        pass


    def do_interface(self, cmdLine):
        'Connect to the CAN interface'
        try:
            parser = ShellArgParser(prog='interface', description=__doc__)
            parser.add_argument('-d', help="CAN device URI", dest="deviceURI", default=None)
            args = parser.parse_args(shlex.split(cmdLine))
            self.interface = CANInterface.MakeInterface(args.deviceURI);
            self.connection = None;
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    def do_connect(self, cmdLine):
        'connect to an XCP slave'
        try:
            parser = ShellArgParser(prog='connect', description=__doc__)
            parser.add_argument('commandId', help='command CAN id', type=hexInt)
            parser.add_argument('responseId', help='response CAN id', type=hexInt)
#             parser.add_argument('-t')
            args = parser.parse_args(shlex.split(cmdLine))
            slave = CANInterface.XCPSlaveCANAddr(args.commandId, args.responseId)
            self.interface.connect(slave)
            self.connection = XCPConnection.Connection(self.interface)
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_connect.needs_interface = True


    def _parseUploadArgs(self, cmdLine, **kargs):
        parser = ShellArgParser(kargs)
        parser.add_argument('address', help="address", type=int, default=None)
        return parser.parse_args(shlex.split(cmdLine))


    def do_upload8(self, cmdLine):
        'read 8 bits from an XCP slave'
        try:
            args = self._parseUpload(cmdLine, prog='upload8', description=__doc__)
            pointer = XCPConnection.Pointer(args.address)
            print(self.connection.upload8(pointer))
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_upload8.needs_connection = True;


    def do_upload16(self, cmdLine):
        'read 16 bits from an XCP slave'
        try:
            args = self._parseUpload(cmdLine, prog='upload16', description=__doc__)
            pointer = XCPConnection.Pointer(args.address)
            print(self.connection.upload16(pointer))
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_upload16.needs_connection = True;

    def do_upload32(self, cmdLine):
        'read 32 bits from an XCP slave'
        try:
            args = self._parseUpload(cmdLine, prog='upload32', description=__doc__)
            pointer = XCPConnection.Pointer(args.address)
            print(self.connection.upload32(pointer))
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_upload32.needs_connection = True;


    def _parseDownload(self, cmdLine, **kargs):
        parser = ShellArgParser(kargs)
        parser.add_argument('address', help="address", type=int, default=None)
        parser.add_argument('data', help="data", type=int, default=None)
        return parser.parse_args(shlex.split(cmdLine))


    def do_download8(self, cmdLine):
        'write 8 bits from an XCP slave'
        try:
            args = self._parseDownload(cmdLine, prog='download8', description=__doc__)
            pointer = XCPConnection.Pointer(args.address)
            print(self.connection.download8(pointer, args.data))
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_download8.needs_connection = True;

    def do_download16(self, cmdLine):
        'write 16 bits from an XCP slave'
        try:
            args = self._parseDownload(cmdLine, prog='download16', description=__doc__)
            pointer = XCPConnection.Pointer(args.address)
            print(self.connection.download16(pointer, args.data))
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_download16.needs_connection = True;

    def do_download32(self, cmdLine):
        'write 32 bits from an XCP slave'
        try:
            args = self._parseDownload(cmdLine, prog='download32', description=__doc__)
            pointer = XCPConnection.Pointer(args.address)
            print(self.connection.download32(pointer, args.data))
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_download32.needs_connection = True;

    def do_disconnect(self, cmdLine):
        'disconnect from an XCP slave'
        try:
            parser = ShellArgParser(prog='disconnect', description=__doc__)
            args = parser.parse_args(shlex.split(cmdLine))
            self.connection.close()
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_disconnect.needs_connection = True;


    def do_set_cal_page(self, cmdLine):
        'sets the XCP calibration page'
        try:
            parser = ShellArgParser(prog='set_cal_page', description=__doc__)
            parser.add_argument('segment', help="segment", type=int, default=None)
            parser.add_argument('page_num', help="page number", type=int, default=None)
            args = parser.parse_args(shlex.split(cmdLine))
            self.connection.set_cal_page(args.segment, args.page_num)
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_set_cal_page.needs_connection = True;


    def do_read_config(self, args):
        'read configuration data'
        # parse command line, extract output file name

        pass

    do_read_config.needs_connection = True
    do_read_config.needs_paramFile = True


    def do_write_config(self, args):
        pass


    do_write_config.needs_connection = True
    do_write_config.needs_paramFile = True


    def _crc(self, dataSingleBlock):
        crcCalc = STCRC.Calc()
        return crcCalc.calc(dataSingleBlock.data)

    def _readSREC(self, inputFile):
        dataBlock = srec.ReadFile(inputFile)
        inputFile.close()
        return dataBlock

    def _makeSingleBlock(self, dataBlocks):
        return srec.MakeSingleBlock(dataBlocks, b'\xFF')

    def do_srec_info(self, cmdLine):
        'gets into about the srec programming file'
        try:
            parser = ShellArgParser(prog='srec_info', description=__doc__)
            parser.add_argument('srecFile', help="file", type=argparse.FileType('r'), default=None)
            args = parser.parse_args(shlex.split(cmdLine))

            dataBlocks = self._readSREC(args.srecFile)

            for block in dataBlocks:
                print("Block " + hex(block.baseaddr) + "-" + hex(block.baseaddr + len(block.data)))

            dataSingleBlock = self._makeSingleBlock(dataBlocks)
            dataCRC = self._crc(dataSingleBlock)

            print("Total input range " + hex(dataSingleBlock.baseaddr) + "-" + hex(dataSingleBlock.baseaddr + len(dataSingleBlock.data)))
            print("CRC32-STM32: " + hex(dataCRC))
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)


#         for attempt in range(1, maxAttempts + 1):
#             try:
#                 conn = boardType.Connect(interface, targetSlave)
#                 conn.program_start()
#
#                 if not args.ignoreCRCMatch and conn.program_check(XCPConnection.Pointer(dataSingleBlock.baseaddr, 0), len(dataSingleBlock.data), dataCRC):
#                     print('CRC matched flash contents')
#                     # Success, don't need to do anything further with this slave
#                 else:
#                     # Either CRC check was not done or it didn't match
#                     conn.program_clear(XCPConnection.Pointer(dataSingleBlock.baseaddr, 0), len(dataSingleBlock.data))
#                     for block in dataBlocks:
#                         conn.program_range(XCPConnection.Pointer(block.baseaddr, 0), block.data)
#                     # MTA should now be one past the end of the last block
#                     conn.program_verify(dataCRC)
#                 conn.program_reset()
#                 print('Program OK')
#                 programOK = True
#                 break
#             except XCPConnection.Error as err:
#                 print('Program failure (' + str(err) + '), attempt #' + str(attempt))
#                 programOK = False
#         if not programOK:
#             sys.exit(1)


    def do_program(self, cmdLine):
        'program an XCP slave'
        try:
            parser = ShellArgParser(prog='program', description=__doc__)
            parser.add_argument('address', help="address", type=int, default=None)
            parser.add_argument('length', help="length", type=int, default=None)
            args = parser.parse_args(shlex.split(cmdLine))
            self.connection.program
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_program.needs_connection = True



    def do_program_start(self, cmdLine):
        'starts a program running on the XCP device'
        try:
            parser = ShellArgParser(prog='program_start', description=__doc__)
            args = parser.parse_args(shlex.split(cmdLine))
            self.connection.program_start()
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_program_start.needs_connection = True;

    def do_program_clear(self, cmdLine):
        'clears a range of program data on the target device'
        try:
            parser = ShellArgParser(prog='program_clear', description=__doc__)
            parser.add_argument('address', help="address", type=int, default=None)
            parser.add_argument('length', help="length", type=int, default=None)
            args = parser.parse_args(shlex.split(cmdLine))
            self.connection.program_clear(args.ptr, args.length)
            self.connection.set_cal_page(args.segment, args.page_num)
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_program_clear.needs_connection = True;

    def do_program_verify(self, arg):
        pass

    do_program_verify.needs_connection = True;

    def do_program_reset(self, cmdLine):
        'resets the target device'
        try:
            parser = ShellArgParser(prog='program_reset', description=__doc__)
            args = parser.parse_args(shlex.split(cmdLine))
            self.connection.program_reset()
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_program_reset.needs_connection = True;

    def do_program_range(self, arg):
        pass

    do_program_range.needs_connection = True;

    def do_program_app(self, arg):
        pass

    do_program_app.needs_connection = True;

    def do_program_check(self, arg):
        pass

    do_program_check.needs_connection = True;

    def do_nvwrite(self, cmdLine):
        'write data to non-volatile memory'
        try:
            parser = ShellArgParser(prog='nvwrite', description=__doc__)
            args = parser.parse_args(shlex.split(cmdLine))
            self.connection.nvwrite()
        except ShellArgParserExit:
            return
        except Exception as e:
            print(e)

    do_nvwrite.needs_connection = True;


    def do_exit(self, arg):
        'exits the XCP shell'
        return True

    def close(self):
        if self.file:
            self.file.close()
            self.file = None

    def precmd(self, line):
        return cmd.Cmd.precmd(self, line)

    def postcmd(self, stop, line):
        return cmd.Cmd.postcmd(self, stop, line)

    def preloop(self):
        cmd.Cmd.preloop(self)

    def postloop(self):
        cmd.Cmd.postloop(self)

def parse(arg):
    'Convert a series of zero or more numbers to an argument tuple'
    return tuple(map(int, arg.split()))

if __name__ == '__main__':
    XCPShell().cmdloop()
