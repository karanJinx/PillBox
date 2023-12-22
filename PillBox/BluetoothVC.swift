//
//  BluetoothVC.swift
//  PillBox
//
//  Created by Humworld Solutions Private Limited on 11/12/23.
//

import CoreBluetooth
import UIKit


class BluetoothVC: UIViewController, ValueToSend {
    
    var firstTime: String?
    var dynamicTag: Int?
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    
    var pillBoxRegistrationArray: [UInt8] = []
    var macAddress: [UInt8] = []
    var byteArrayForTime: [UInt8] = []
    
    var notify_characteristics: CBCharacteristic!
    var write_characteristics: CBCharacteristic!
    var ourService: CBService?
    
    let service2 = CBUUID(string: "2F2DFFF0-2E85-649D-3545-3586428F5DA3")
    let service3 = CBUUID(string: "00010203-0405-0607-0809-0A0B0C0D1911")
    
    let service2_characteristic1 = CBUUID(string: "2F2DFFF4-2E85-649D-3545-3586428F5DA3") // notify
    let service2_characteristic2 = CBUUID(string: "2F2DFFF5-2E85-649D-3545-3586428F5DA3") // write, writeWithoutResponse
    
    let service3_characteristic1 = CBUUID(string: "00010203-0405-0607-0809-0A0B0C0D2B12") // read, writeWithoutResponse
    
    static var responseForAlarmStatus: [String]? = []
    
    var time1ToShowinNextVC: String?
    var time2ToShowinNextVC: String?
    var time3ToShowinNextVC: String?
    var time4ToShowinNextVC: String?
    var time5ToShowinNextVC: String?
    var time6ToShowinNextVC: String?
    var time7ToShowinNextVC: String?
    var time8ToShowinNextVC: String?
    var time9ToShowinNextVC: String?
    
    var time1Switch: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func AddAlarmButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "AlarmVC") as! AlarmVC
        vc.delegate = self
        vc.dateLable1Time = firstTime ?? "--:--"
        vc.dynamicAletTag = dynamicTag ?? 0
        vc.time1ToShow = time1ToShowinNextVC ?? "--:--"
        vc.time2ToShow = time2ToShowinNextVC ?? "--:--"
        vc.time3ToShow = time3ToShowinNextVC ?? "--:--"
        vc.time4ToShow = time4ToShowinNextVC ?? "--:--"
        vc.time5ToShow = time5ToShowinNextVC ?? "--:--"
        vc.time6ToShow = time6ToShowinNextVC ?? "--:--"
        vc.time7ToShow = time7ToShowinNextVC ?? "--:--"
        vc.time8ToShow = time8ToShowinNextVC ?? "--:--"
        vc.time9ToShow = time9ToShowinNextVC ?? "--:--"
//        if time1Switch == "01" {
//            if let alarmSwitch = vc.alarmSwitch1 {
//                alarmSwitch.isEnabled = true
//                alarmSwitch.isOn = true
//            }
//        } else {
//            if let alarmSwitch = vc.alarmSwitch1 {
//                alarmSwitch.isEnabled = false
//                alarmSwitch.isOn = false
//            }
//        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressButtonToConnect(_ sender: Any) {
        centralManager = CBCentralManager(delegate: self, queue: nil)        
    }
}
extension BluetoothVC: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Central in Unknown")
        case .resetting:
            print("Central in Resetting")
        case .unsupported:
            print("Central in Unsupported")
        case .unauthorized:
            print("Central in unauthorized")
        case .poweredOff:
            print("Central in PoweredOff")
        case .poweredOn:
            print("Central in PoweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        default:
            print("Something Wrong with the Central")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print(advertisementData)
        if var macAdress = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            var macAddressString = Conversions.byteArrayToHexString1([UInt8](macAdress))
            print("MacAddress", macAddressString )
            if macAddressString.count >= 2 {
                macAddressString.removeFirst(4)
                print("Modified Mac",macAddressString.utf8)
                let crcForMacAddress = Conversions.calculateCRC16(data: Array(macAddressString.utf8))
                let formattedCRC = String(format: "%04X", crcForMacAddress)
                let firstPart = formattedCRC.prefix(2)
                let secondPart = formattedCRC.suffix(from: formattedCRC.index(formattedCRC.startIndex, offsetBy: 2))
                let stringArray = [secondPart, firstPart]
                var byteArray: [UInt8] = []
                for hexString in stringArray {
                    if let byteValue = UInt8(hexString, radix: 16){
                        byteArray.append(byteValue)
                    }
                }
                let command: [UInt8] = [0xBB, 0x11, 0x08, 0xC4, 0x08, 0x00, 0x02, 0xD0, 0x02]
                let commandWithoutCrc = command + byteArray
                let stringArrayFromByteArray = Conversions.getPairsFromHexString(data: commandWithoutCrc) ?? []
                let finalCrc = Conversions.calculateChecksum(for: stringArrayFromByteArray)
                if let byte = UInt8(finalCrc ?? "", radix: 16) {
                    let byteArray = [byte]
                    let commandWithCRC = commandWithoutCrc + byteArray
                    //print("command with crc", Conversions.getPairsFromHexString(data: commandWithCRC))
                    macAddress = commandWithCRC
                }
            }
        }
        if let name = peripheral.name {
            if name.contains("PD_") { //"PD_6BCC"
                centralManager.stopScan()
                self.myPeripheral = peripheral
                self.myPeripheral.delegate = self
                centralManager.connect(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral connected to central")
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == service2 {
                ourService = service
                print("The services for the peripheral", service.uuid)
                peripheral.discoverCharacteristics(nil, for: service)
            }
            else {
                print("Other services found")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == service2_characteristic1 {
                notify_characteristics = characteristic
                print("notify characteristics of our service", characteristic.uuid)
            } else if characteristic.uuid == service2_characteristic2 {
                write_characteristics = characteristic
                print("write characteristics of our service", characteristic.uuid)
            } else {
                print("Other characteristics")
            }
        }
        //Method to notify pillBox
        notifyPillBox(peripheral: peripheral)
    }
    
    func notifyPillBox(peripheral: CBPeripheral) {
        peripheral.setNotifyValue(true, for: notify_characteristics)
        print("Notify success")
    }
    func writeRegistrationCommand(peripheral: CBPeripheral, characteristics: CBCharacteristic) {
        let commandData = Data(pillBoxRegistrationArray)
        peripheral.writeValue(commandData, for: characteristics, type: .withResponse)
    }
    func writeConnectionCommand(peripheral: CBPeripheral, characteristics: CBCharacteristic) {
        let commandData = Data(macAddress)
        peripheral.writeValue(commandData , for: characteristics, type: .withResponse)
        print("write Success for Connection")
    }
    func writeDateTime(peripheral: CBPeripheral) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: Date())
        let yearFirstHalf = UInt8(components.year! / 100)
        let yearSecondHalf = UInt8(components.year! % 100)
        let month = UInt8(components.month!)
        let day = UInt8(components.day!)
        let hour = UInt8(components.hour!)
        let minute = UInt8(components.minute!)
        let second = UInt8(components.second!)
        let weekday = UInt8(components.weekday!)
        
        let commandBytes: [UInt8] = [0xBB, 0x11, 0x0E, 0xC9, 0x08, 0x00, 0x08, 0xE0, 0x08, yearFirstHalf, yearSecondHalf, month, day, hour, minute, second, weekday]
        let hexPairStringArray = Conversions.getPairsFromHexString(data: commandBytes) ?? []
        let hexCRC = Conversions.calculateChecksum(for: hexPairStringArray)
        if let byte = UInt8(hexCRC ?? "", radix: 16) {
            let byteArray = [byte]
            let commandWithCRC = commandBytes + byteArray
            self.byteArrayForTime = commandWithCRC
            let command: [UInt8] = self.byteArrayForTime
            let commandData = Data(command)
            peripheral.writeValue(commandData, for: self.write_characteristics, type: .withResponse)
            print("time write completed on pillbox")
        }
    }
    func writeAlarmCommand(peripheral: CBPeripheral, characteristic: CBCharacteristic, time: String, alaramTag: Int) {
        
        let firstPart = time.prefix(2)
        if time.count >= 5 {
            let startIndex = time.index(time.startIndex, offsetBy: 3)
            let endIndex = time.index(time.startIndex, offsetBy: 4)
            let seperatedTimeString = time[startIndex...endIndex]
            let firstPartHex = String(Int(firstPart) ?? 0, radix: 16)
            let SecondPartHex = String(Int(seperatedTimeString) ?? 0,radix: 16)
            
            let constantTagForHour: UInt8 = 0x60
            let alarmHourTag: Int = Int(constantTagForHour) + alaramTag
            print("AlarmHourTag", alarmHourTag)
            let hourString: String = String(alarmHourTag,radix: 16)
            let hourStr = hourString
            print(hourStr)
            let hourByte = UInt8(hourStr,radix: 16)
            
            let constantTagForMin: UInt8 = 0x70
            let alarmMinTag: Int = Int(constantTagForMin) + alaramTag
            let minByte = UInt8(String(alarmMinTag,radix: 16), radix: 16)


            let commandWithoutCRC: [UInt8] = [0xBB, 0x11, 0x0A, 0xCE, 0x08, 0x00, 0x06, hourByte!, 0x01, UInt8(firstPartHex,radix: 16)!, minByte!, 0x01, UInt8(SecondPartHex, radix: 16)!]
            let checksum = Conversions.calculateChecksum(for: Conversions.getPairsFromHexString(data: commandWithoutCRC) ?? []) ?? ""
            if let byte = UInt8(checksum, radix: 16) {
                let byteArrayChecksum: [UInt8] = [byte]
                let commandWithCrc = commandWithoutCRC + byteArrayChecksum
                let data = Data(commandWithCrc)
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
    func writealarmForState(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
           let command: [UInt8] = [0xbb, 0x11 ,0x55, 0xc8, 0x08, 0x00, 0x05, 0x61 ,0x01 ,0x00 ,0x71 , 0x01 , 0x00 , 0x81 , 0x01 , 0x00 , 0x62 , 0x01 , 0x00 , 0x72 , 0x01 , 0x00 , 0x82 , 0x01 , 0x00 , 0x63 , 0x01 , 0x00 , 0x73 , 0x01 , 0x00 , 0x83 , 0x01 , 0x00 , 0x64 , 0x01 , 0x00 , 0x74 , 0x01 , 0x00 , 0x84 , 0x01 , 0x00 , 0x65 , 0x01 , 0x00 , 0x75 , 0x01 , 0x00 , 0x85 , 0x01 , 0x00 , 0x66 , 0x01 , 0x00 , 0x76 , 0x01 , 0x00 , 0x86 , 0x01 , 0x00 , 0x67 , 0x01 , 0x00 , 0x77 , 0x01 , 0x00 , 0x87 , 0x01 , 0x00 , 0x68 , 0x01 , 0x00 , 0x78 , 0x01 , 0x00 , 0x88 , 0x01 , 0x00 , 0x69 , 0x01 , 0x00 , 0x79 , 0x01 , 0x00 , 0x89 , 0x01 , 0x00 , 0x68]
           peripheral.writeValue(Data(command), for: write_characteristics, type: .withResponse)
    }
//    func writealarmSwitch(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
//        let command: [UInt8] = [0xBB, 0x11, 0x07, 0xCE, 0x08, 0x00, 0x06, 0x81, 0x01, 0x01, 0x32]
//        peripheral.writeValue(Data(command), for: write_characteristics, type: .withResponse)
//    }
    
//    func writealarmSwitch(peripheral: CBPeripheral, characteristic: CBCharacteristic, switchTag: Int) {
//        let constantSwitchTag: UInt8 = 0x80
//        let alarmSwitchTag = Int(constantSwitchTag) + switchTag
//        let SwitchTagByte = UInt8(String(alarmSwitchTag,radix: 16),radix: 16)
//        let commandWithoutCrc: [UInt8] = [0xBB, 0x11, 0x07, 0xCE, 0x08, 0x00, 0x06, SwitchTagByte!, 0x01, 0x01]
//        let CRC = Conversions.calculateChecksum(for: Conversions.getPairsFromHexString(data: commandWithoutCrc) ?? []) ?? ""
//        if let byte = UInt8(CRC, radix: 16) {
//            let byteArrayCrc: [UInt8] = [byte]
//            let commandWithCRC = commandWithoutCrc + byteArrayCrc
//            let data = Data(commandWithCRC)
//            peripheral.writeValue(data, for: characteristic, type: .withResponse)
//        }
//    }

    func writealarmSwitch(peripheral: CBPeripheral, characteristic: CBCharacteristic, switchTag: Int, isSwitchOn: Bool) {
        let constantSwitchTag: UInt8 = 0x80
        let alarmSwitchTag = Int(constantSwitchTag) + switchTag
        let switchTagByte = UInt8(String(alarmSwitchTag, radix: 16), radix: 16)

        // Use isSwitchOn to determine the value of the last byte
        let lastByteValue: UInt8 = isSwitchOn ? 0x01 : 0x00

        let commandWithoutCrc: [UInt8] = [0xBB, 0x11, 0x07, 0xCE, 0x08, 0x00, 0x06, switchTagByte!, 0x01, lastByteValue]

        let CRC = Conversions.calculateChecksum(for: Conversions.getPairsFromHexString(data: commandWithoutCrc) ?? []) ?? ""

        if let byte = UInt8(CRC, radix: 16) {
            let byteArrayCrc: [UInt8] = [byte]
            let commandWithCRC = commandWithoutCrc + byteArrayCrc
            let data = Data(commandWithCRC)
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }

    
    
    func commonWriteCommand(peripheral: CBPeripheral) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.writeRegistrationCommand(peripheral: peripheral, characteristics: self.write_characteristics)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.writeConnectionCommand(peripheral: peripheral, characteristics: self.write_characteristics)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.writeDateTime(peripheral: peripheral)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.writealarmForState(peripheral: peripheral, characteristic: self.write_characteristics)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value ?? Data()
        let hexString = Conversions.getPairsFromHexString(data: [UInt8](data))
        //print(hexString)
        let header = hexString?[0] ?? ""
        let protocolVersion = hexString?[1] ?? ""
        if header == "bb" && protocolVersion == "11" {
            let connectionPackage = hexString?[6]
            if hexString?.count ?? 0 >= 6 && connectionPackage == "01" {
                var array = Conversions.updatedArrayByChangingElement(at: 6, in: hexString ?? [], newValue: "81")
                //                print(array)
                let CRC = Conversions.calculateChecksum(for: array) ?? ""
                array.append(CRC)
                var byteArray: [UInt8] = []
                for hexString in array {
                    if let byteValue = UInt8(hexString, radix: 16){
                        byteArray.append(byteValue)
                    }
                }
                pillBoxRegistrationArray = byteArray
                // call this function for registration and connection and dynamic data time
                commonWriteCommand(peripheral: peripheral)
                
            } else if hexString?.count ?? 0 >= 6 && connectionPackage == "82" {
                print("HexString",hexString ?? [])
            } else if hexString?.count ?? 0 >= 6 && connectionPackage == "88" {
                print("HexString response 88 in 6th index",hexString ?? [])
            } else if hexString?.count ?? 0 >= 6 && connectionPackage == "86" {
                print("HexString response for alarm",hexString ?? [])
            } else if hexString?.count ?? 0 >= 6 && connectionPackage == "85" {
                BluetoothVC.responseForAlarmStatus = hexString
                print("response For Alarm status", BluetoothVC.responseForAlarmStatus)
//                print("HexString response for alarm state",hexString ?? [])
//                print(hexString![9] + hexString![12])
//                let timePart1IntFormat = Int(hexString![9], radix: 16)
//                let timePart2IntFormat = Int(hexString![12], radix: 16)
////                print(timePart1IntFormat,timePart2IntFormat)
//                let timeOneFirstPartstring = String(timePart1IntFormat ?? 0)
//                let timeOneSecondPartString = String(timePart2IntFormat ?? 0)
//                let timeOneString  = "\(timeOneFirstPartstring):\(timeOneSecondPartString)"
//                time1ToShowinNextVC =  timeOneString
//                print("Time To Show",time1ToShowinNextVC)
//                print("final string", timeOneString)
//                
//                let time2FirstPartstring = String(Int(hexString![18], radix: 16) ?? 0)
//                let time2SecondPartString = String(Int(hexString![21], radix: 16) ?? 0)
//                let time2String  = "\(time2FirstPartstring):\(time2SecondPartString)"
//                time2ToShowinNextVC = time2String
//                
//                let time3FirstPartstring = String(Int(hexString![27], radix: 16) ?? 0)
//                let time3SecondPartString = String(Int(hexString![30], radix: 16) ?? 0)
//                let time3String  = "\(time3FirstPartstring):\(time3SecondPartString)"
//                time3ToShowinNextVC = time3String
//                
//                let time4FirstPartstring = String(Int(hexString![36], radix: 16) ?? 0)
//                let time4SecondPartString = String(Int(hexString![39], radix: 16) ?? 0)
//                let time4String  = "\(time4FirstPartstring):\(time4SecondPartString)"
//                time4ToShowinNextVC = time4String
//                
//                let time5FirstPartstring = String(Int(hexString![45], radix: 16) ?? 0)
//                let time5SecondPartString = String(Int(hexString![48], radix: 16) ?? 0)
//                let time5String  = "\(time5FirstPartstring):\(time5SecondPartString)"
//                time5ToShowinNextVC = time5String
//                
//                let time6FirstPartstring = String(Int(hexString![54], radix: 16) ?? 0)
//                let time6SecondPartString = String(Int(hexString![57], radix: 16) ?? 0)
//                let time6String  = "\(time6FirstPartstring):\(time6SecondPartString)"
//                time6ToShowinNextVC = time6String
//                
//                let time7FirstPartstring = String(Int(hexString![63], radix: 16) ?? 0)
//                let time7SecondPartString = String(Int(hexString![66], radix: 16) ?? 0)
//                let time7String  = "\(time7FirstPartstring):\(time7SecondPartString)"
//                time7ToShowinNextVC = time7String
//                
//                let time8FirstPartstring = String(Int(hexString![72], radix: 16) ?? 0)
//                let time8SecondPartString = String(Int(hexString![75], radix: 16) ?? 0)
//                let time8String  = "\(time8FirstPartstring):\(time8SecondPartString)"
//                time8ToShowinNextVC = time8String
//                
//                let time9FirstPartstring = String(Int(hexString![81], radix: 16) ?? 0)
//                let time9SecondPartString = String(Int(hexString![84], radix: 16) ?? 0)
//                let time9String  = "\(time9FirstPartstring):\(time9SecondPartString)"
//                time9ToShowinNextVC = time9String
//                
//                let time1SwitchHex = hexString![15]
//                let time1SwitchString = String(time1SwitchHex)
//                print("Time1SwitchString:", time1SwitchString)
//                time1Switch = time1SwitchString
            }
            else {
                print("other hexastring",hexString ?? [])
                print("Other connection package found")
            }
        }
        else {
            print("Its not our byte Array")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to write value for characteristic \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            print("Successfully wrote value for characteristic \(characteristic.uuid)")
        }
    }
}

extension BluetoothVC {

    func value(time: String, alarmNumber: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.writealarmForState(peripheral: self.myPeripheral, characteristic: self.write_characteristics)
        }
        dynamicTag = alarmNumber
        print(alarmNumber)
        print(time)
        if dynamicTag == 1 {
            firstTime = time
//            print("FirstTime",firstTime)
        }
        if dynamicTag == 2 {
            firstTime = time
        }
        if dynamicTag == 3 {
            firstTime = time
        }
        if dynamicTag == 4 {
            firstTime = time
        }
        if dynamicTag == 5 {
            firstTime = time
        }
        if dynamicTag == 6 {
            firstTime = time
        }
        if dynamicTag == 7 {
            firstTime = time
        }
        if dynamicTag == 8 {
            firstTime = time
        }
        if dynamicTag == 9 {
            firstTime = time
        }
        writeAlarmCommand(peripheral: myPeripheral, characteristic: write_characteristics, time: time, alaramTag: alarmNumber)

    }
    
    func alarmSwitchDidChange(isEnabled: Bool,tag: Int) {

        switch tag {
        case 1:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 2:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 3:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 4:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 5:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 6:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 7:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 8:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }
        case 9:
            if isEnabled {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: true)
            } else {
                writealarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics, switchTag: tag, isSwitchOn: false)
            }

        default:
            fatalError("Unknown switch")
        }
        
    }

    
}


