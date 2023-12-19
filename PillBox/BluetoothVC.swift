//
//  BluetoothVC.swift
//  PillBox
//
//  Created by Humworld Solutions Private Limited on 11/12/23.
//

import CoreBluetooth
import UIKit


class BluetoothVC: UIViewController, ValueToSend {
    var firstTime: String =  ""
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPress))
        navigationItem.leftBarButtonItem = barButton
        
    }
    @objc func backButtonPress() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func AddAlarmButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "AlarmVC") as! AlarmVC
        vc.delegate = self
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
                    print("command with crc", Conversions.getPairsFromHexString(data: commandWithCRC))
                    macAddress = commandWithCRC
                }
            }
        }
        if let name = peripheral.name {
            if name.contains("PD_6C67") { //"PD_6BCC"
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
    func writeAlarmCommand(peripheral: CBPeripheral, characteristic: CBCharacteristic, time: String) {

        let firstPart = time.prefix(2)
        if time.count >= 5 {
            let startIndex = time.index(time.startIndex, offsetBy: 3)
            let endIndex = time.index(time.startIndex, offsetBy: 4)
            let seperatedTimeString = time[startIndex...endIndex]
//            print("FirtstPart",(UInt8(firstPart,radix: 16)))
//            print("SecondPart",(UInt8(seperatedTimeString,radix: 16)))
            
            let firstPartHex = String(Int(firstPart) ?? 0, radix: 16)
            let SecondPartHex = String(Int(seperatedTimeString) ?? 0,radix: 16)
            let commandWithoutCRC: [UInt8] = [0xBB, 0x11, 0x0A, 0xCE, 0x08, 0x00, 0x06, 0x61, 0x01, UInt8(firstPartHex,radix: 16)!, 0x71, 0x01, UInt8(SecondPartHex, radix: 16)!]
            let checksum = Conversions.calculateChecksum(for: Conversions.getPairsFromHexString(data: commandWithoutCRC) ?? []) ?? ""
            if let byte = UInt8(checksum, radix: 16) {
                let byteArrayChecksum: [UInt8] = [byte]
                let commandWithCrc = commandWithoutCRC + byteArrayChecksum
                let data = Data(commandWithCrc)
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }
    func alarmSwitch(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let command: [UInt8] = [0xBB, 0x11, 0x07, 0xCE, 0x08, 0x00, 0x06, 0x81, 0x01, 0x01, 0x32]
        
        let data = Data(command)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    
    func commonWriteCommand(peripheral: CBPeripheral) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.writeRegistrationCommand(peripheral: peripheral, characteristics: self.write_characteristics)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.writeConnectionCommand(peripheral: peripheral, characteristics: self.write_characteristics)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.writeDateTime(peripheral: peripheral)

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
                print("HexString response for alarm switch",hexString ?? [])
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
    func value(time: String) {
        print("the time", time)

            writeAlarmCommand(peripheral: myPeripheral, characteristic: write_characteristics, time: time)
            alarmSwitch(peripheral: myPeripheral, characteristic: write_characteristics)
        
    }
}


