# '''
# Created on Oct 5, 2013
# 
# @author: gcardwel
# '''
# from comm import CANInterface
# import urllib
# import serial
# import io
# 
# class ELM327CANInterface(CANInterface.Interface):
#     '''
#     Interface using Linux SocketCAN
#     '''
#     _slaveAddr = None
#     _serialPort = None
#     _baudRate = None
#     
#     def __init__(self, parsedURL):
#         port = serial.Serial()
#         port.baudrate= 115220
#         port.port = int(parsedURL.path)
#         port.parity = 'N'
#         port.bytesize = 8
#         port.stopbits = 1
#         port.timeout = None
#         port.xonxoff = 0
#         port.rtscts = 0
#         port.open()
#         _serialPort = port
#         
#         queryDict = urllib.parse.parse_qs(parsedURL.query)
#         self._baudRate = int(queryDict.get("baud", "250000"));
#         self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
#        
#     def __enter__(self):
#         return self
# 
#     def __exit__(self, type, value, traceback):
#         self._s.close()
#         
#     def close(self):
#         self._sio.close()
#         self._serialPort.close()
#     
#     def _build_frame(self, data, ident):
#         can_dlc = len(data)
#         for c in data:
#             return struct.pack("=IB3x8s", ident, can_dlc, data.ljust(8, b'\x00'))
#     
#     def _decode_frame(self, frame):
#         bytearray.fromhex(string)
# 
#         ident, dlc, data = struct.unpack("=IB3x8s", frame)
#         return ident, data[0:dlc]
# 
#     def _sendCommand(self, line):
#         self._serialPort.write(line);
#         return self._serialPort.readLine();
# 
# ('%(language)s has %(number)03d quote types.' %
# ...       {'language': "Python", "number": 2})
#     
#     def _set_filter(self, ):
#     
#     def connect(self, address):
#         
#         # "ATWS" warm start
#         # "ATCSM0"  disable quiet monitoring
#         # "ATCRA XX XX XX XX"  set receive address
#         # "ATSH xx xx xx xx " set header (data transmit address)
#         # "ATSPB"  -- use J1939. more or less.
#         # "AT Z"
#         # "ATSP 2B XX "  02 = 250KB, 
#         
# #         ATL1 -- line feeds on
# # AT SP 9                    Setting to protocol to ISO 15765-4, this had specs that supported the XCP-frame
# # AT SH FCD400                Setting header to wanted XCP ID
# # AT CP 00                Setting Priority to 00, setting the Identifyer to: 00FCD400 (29 bit).
# # AT CFC0
# # AT CAF0                    Removing the data count byte in data count frame, so the default data lenght is 8 bytes.
# # AT CRA 00FCD400                Setting recieve identifyer to FCD400, so we filter out everything else.
# # then send frame with hex codes
# 
# # send frame then read a line
# 
# 
# 
#         
# # Protocols B and C may also be used with J1939 if you with ti experiment with other baud rates
# # To use them, the option value in PP 2C or 2E must be set to 42, and the baud rate divisor in PP 2D or 2F 
# # must be set to the appropriate value.  Perhaps the simplest way to provide an alternate rate is to use the AT PB command
# # that allows you to both the options byte (always 42) and the baud rate divisor (which si 500k / the destired baud rate) at the same time
# 
#         
#         self._slaveAddr = address
#         filt = struct.pack("=II", self._slaveAddr.resId.raw, 0x9FFFFFFF)
#         self._s.setsockopt(socket.SOL_CAN_RAW, socket.CAN_RAW_FILTER, filt)
#         # Now flush any packets that were previously there
#         self._s.settimeout(0.001)
#         while 1:
#             try:
#                 frame = self._s.recvfrom(16)[0]
#             except socket.timeout:
#                 break
#     
#     
#     def disconnect(self):
#         self._slaveAddr = CANInterface.XCPSlaveCANAddr(0xFFFFFFFF, 0xFFFFFFFF)
#         filt = struct.pack("=II", 0, 0)
#         self._s.setsockopt(socket.SOL_CAN_RAW, socket.CAN_RAW_FILTER, filt)
#        
#     def _sendFrame(self, frame):
#         self._s.setblocking(1)
#         while 1:
#             try:
#                 self._s.send(frame)
#                 break
#             except OSError as err:
#                 if err.errno != 105:
#                     raise
#                 else:
#                     # Need to repeatedly try to send frames if ENOBUFS (105) returned - shortcoming of SocketCAN
#                     time.sleep(0.010)
#     
#     def transmit(self, data):
#         frame = self._build_frame(data, self._slaveAddr.cmdId.raw)
#         self._sendFrame(frame)
#     
#     def transmitTo(self, data, ident):
#         frame = self._build_frame(data, ident)
#         self._sendFrame(frame)
#         
#     def receive(self, timeout):
#         if self._slaveAddr.resId.raw == 0xFFFFFFFF:
#             return []
#         
#         msgs = []
#         endTime = time.time() + timeout
#         
#         while 1:
#             if len(msgs):
#                 self._s.setblocking(0)
#             else:
#                 newTimeout = endTime - time.time()
#                 if newTimeout < 0:
#                     self._s.setblocking(0)
#                 else:
#                     self._s.settimeout(newTimeout)
#             
#             try:
#                 frame = self._s.recvfrom(16)[0]
#             except (socket.timeout, BlockingIOError):
#                 break
#             
#             ident, data = self._decode_frame(frame)
#             if data[0] == 0xFF or data[0] == 0xFE:
#                 msgs.append(data)
#         return msgs
#     
#     def receivePackets(self, timeout):
#         packets = []
#         endTime = time.time() + timeout
#         
#         while 1:
#             if len(packets):
#                 self._s.setblocking(0)
#             else:
#                 newTimeout = endTime - time.time()
#                 if newTimeout < 0:
#                     self._s.setblocking(0)
#                 else:
#                     self._s.settimeout(newTimeout)
#             
#             try:
#                 frame = self._s.recvfrom(16)[0]
#             except (socket.timeout, BlockingIOError):
#                 break
#             
#             ident, data = self._decode_frame(frame)
#             if data[0] == 0xFF or data[0] == 0xFE:
#                 packets.append(CANInterface.Packet(ident, data))
#         return packets

