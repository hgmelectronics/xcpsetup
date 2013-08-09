import CANInterface
import XCPConnection
import sys

try:
    interface = CANInterface.SocketCANInterface("can0")
    slaves = XCPConnection.XCPGetCANSlaves(interface, 0x9F000000, 0.2)
    for i in range(0, len(slaves)):
        print(str(i) + ': ' + slaves[i].description())
    index = int(input('Slave: '))
    if index >= len(slaves):
        exit
    slave = slaves[index]
    interface.connect(slave)
    conn = XCPConnection.XCPConnection(interface, 0.2)
    data = []
    for i in range(0, 72):
        data.append(conn.upload32(XCPConnection.XCPPointer(i * 4, 0)))
        print(hex(data[i]))
    
    idAddr = XCPConnection.XCPPointer(0, 0)
    print('Board ID: ' + str(conn.upload8(idAddr)))
    newId = int(input('New board ID: '))
    conn.download8(idAddr, newId)
except:
    interface.close()
    raise
interface.close()
