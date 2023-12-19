//
//  BlueToothManager.swift
//  PillBox
//
//  Created by Humworld Solutions Private Limited on 19/12/23.
//

import Foundation
import CoreBluetooth

//protocol BluetoothManagerDelegate: AnyObject {
//    func didConnectToPeripheral()
//    func didFailToConnect(error: Error?)
//    func didSendCommandSuccessfully()
//    func didFailToSendCommand(error: Error?)
//}

class BluetoothManager {

    static let shared = BluetoothManager()

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?

    //weak var delegate: BluetoothManagerDelegate?

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func connectToDevice() {
        // Replace with your Bluetooth device's UUID
        let deviceUUID = CBUUID(string: "Your_Device_UUID")
        centralManager.scanForPeripherals(withServices: [deviceUUID], options: nil)
    }

    func sendCommand(_ command: [UInt8]) {
        guard let peripheral = peripheral, let writeCharacteristic = writeCharacteristic else {
            print("Peripheral or characteristic not available")
            return
        }

        let data = Data(command)
        peripheral.writeValue(data, for: writeCharacteristic, type: .withResponse)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        default:
            print("Bluetooth is not available or powered off")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        print("Discovered Peripheral: \(peripheral)")

        // Connect to the discovered peripheral
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to Peripheral: \(peripheral)")

        // Save a reference to the connected peripheral
        self.peripheral = peripheral

        // Discover services and characteristics
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to Peripheral: \(peripheral), Error: \(String(describing: error))")
        //delegate?.didFailToConnect(error: error)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            if characteristic.properties.contains(.write) {
                // Save a reference to the writable characteristic
                writeCharacteristic = characteristic
                //delegate?.didConnectToPeripheral()
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to write value, Error: \(error)")
            //delegate?.didFailToSendCommand(error: error)
        } else {
            print("Value written successfully")
            //delegate?.didSendCommandSuccessfully()
        }
    }
}
