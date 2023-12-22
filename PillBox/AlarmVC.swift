//
//  AlarmVC.swift
//  PillBox
//
//  Created by Humworld Solutions Private Limited on 15/12/23.
//

import Foundation
import UIKit
import CoreBluetooth

protocol ValueToSend {
    func value(time: String, alarmNumber: Int)
    func alarmSwitchDidChange(isEnabled: Bool, tag: Int)
}

class AlarmVC: UIViewController,DatePickerDelegate {
    
    let bluetoothVC = BluetoothVC()
    
    var time1: String?
    
    //    var dateLable1Time = ""
    //    var dateLable2Time = ""
    
    
    var delegate: ValueToSend?
    
    @IBOutlet var alarm1View: UIView!
    @IBOutlet var alarm2View: UIView!
    @IBOutlet var alarm3View: UIView!
    @IBOutlet var alarm4View: UIView!
    @IBOutlet var alarm5View: UIView!
    @IBOutlet var alarm6View: UIView!
    @IBOutlet var alarm7View: UIView!
    @IBOutlet var alarm8View: UIView!
    @IBOutlet var alarm9View: UIView!
    @IBOutlet var date1Lable: UILabel!
    @IBOutlet var date2Lable: UILabel!
    @IBOutlet var date3Lable: UILabel!
    @IBOutlet var date4Lable: UILabel!
    @IBOutlet var date5Lable: UILabel!
    @IBOutlet var date6Lable: UILabel!
    @IBOutlet var date7Lable: UILabel!
    @IBOutlet var date8Lable: UILabel!
    @IBOutlet var date9Lable: UILabel!
    @IBOutlet var alarmSwitch1: UISwitch!
    @IBOutlet var alarmSwitch2: UISwitch!
    @IBOutlet var alarmSwitch3: UISwitch!
    @IBOutlet var alaramSwitch4: UISwitch!
    @IBOutlet var alarmSwitch5: UISwitch!
    @IBOutlet var alarmSwitch6: UISwitch!
    @IBOutlet var alarmSwitch7: UISwitch!
    @IBOutlet var alarmSwitch8: UISwitch!
    @IBOutlet var alarmSwitch9: UISwitch!
    
    
    var dynamicAletTag: Int = 0
    
    var time1ToShow: String = "--:--"
    var time2ToShow: String = "--:--"
    var time3ToShow: String = "--:--"
    var time4ToShow: String = "--:--"
    var time5ToShow: String = "--:--"
    var time6ToShow: String = "--:--"
    var time7ToShow: String = "--:--"
    var time8ToShow: String = "--:--"
    var time9ToShow: String = "--:--"
    
    var alarmState: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if alarmState.count >= 80 {
            print(alarmState[9] + alarmState[12])
            if alarmState[9] == "ff" && alarmState[12] == "ff" {
                date1Lable.text = "-- : --"
            } else{
                let timePart1IntFormat = Int(alarmState[9], radix: 16)
                let timePart2IntFormat = Int(alarmState[12], radix: 16)
                //                print(timePart1IntFormat,timePart2IntFormat)
                var timeOneFirstPartstring = String(timePart1IntFormat ?? 0)
                if timeOneFirstPartstring.count == 1 {
                    timeOneFirstPartstring = "0" + timeOneFirstPartstring
                }
                var timeOneSecondPartString = String(timePart2IntFormat ?? 0)
                if timeOneSecondPartString.count == 1 {
                    timeOneSecondPartString = "0" + timeOneSecondPartString
                }
                let timeOneString  = "\(timeOneFirstPartstring):\(timeOneSecondPartString)"
                date1Lable.text =  timeOneString
                //        print("Time To Show",time1ToShowinNextVC)
                print("final string", timeOneString)
            }
            
            
            if alarmState[18] == "ff" && alarmState[21] == "ff" {
                date2Lable.text = "-- : --"
            } else{
                var time2FirstPartstring = String(Int(alarmState[18], radix: 16) ?? 0)
                if time2FirstPartstring.count == 1 {
                    time2FirstPartstring = "0" + time2FirstPartstring
                }
                var time2SecondPartString = String(Int(alarmState[21], radix: 16) ?? 0)
                if time2SecondPartString.count == 1 {
                    time2SecondPartString = "0" + time2SecondPartString
                }
                let time2String  = "\(time2FirstPartstring):\(time2SecondPartString)"
                date2Lable.text = time2String
            }
            
            
            if alarmState[27] == "ff" && alarmState[30] == "ff" {
                date3Lable.text = "-- : --"
            } else{
                var time3FirstPartstring = String(Int(alarmState[27], radix: 16) ?? 0)
                if time3FirstPartstring.count == 1 {
                    time3FirstPartstring = "0" + time3FirstPartstring
                }
                var time3SecondPartString = String(Int(alarmState[30], radix: 16) ?? 0)
                if time3SecondPartString.count == 1 {
                    time3SecondPartString = "0" + time3SecondPartString
                }
                let time3String  = "\(time3FirstPartstring):\(time3SecondPartString)"
                date3Lable.text = time3String
            }
            
            if alarmState[36] == "ff" && alarmState[39] == "ff" {
                date4Lable.text = "-- : --"
            } else{
                var time4FirstPartstring = String(Int(alarmState[36], radix: 16) ?? 0)
                if time4FirstPartstring.count == 1 {
                    time4FirstPartstring = "0" + time4FirstPartstring
                }
                var time4SecondPartString = String(Int(alarmState[39], radix: 16) ?? 0)
                if time4SecondPartString.count == 1 {
                    time4SecondPartString = "0" + time4SecondPartString
                }
                let time4String  = "\(time4FirstPartstring):\(time4SecondPartString)"
                date4Lable.text = time4String
            }
            
            if alarmState[45] == "ff" && alarmState[48] == "ff" {
                date5Lable.text = "-- : --"
            } else{
                var time5FirstPartstring = String(Int(alarmState[45], radix: 16) ?? 0)
                if time5FirstPartstring.count == 1 {
                    time5FirstPartstring = "0" + time5FirstPartstring
                }
                var time5SecondPartString = String(Int(alarmState[48], radix: 16) ?? 0)
                if time5SecondPartString.count == 1 {
                    time5SecondPartString = "0" + time5SecondPartString
                }
                let time5String  = "\(time5FirstPartstring):\(time5SecondPartString)"
                date5Lable.text = time5String
            }
            if alarmState[54] == "ff" && alarmState[57] == "ff" {
                date6Lable.text = "-- : --"
            } else{
                var time6FirstPartstring = String(Int(alarmState[54], radix: 16) ?? 0)
                if time6FirstPartstring.count == 1 {
                    time6FirstPartstring = "0" + time6FirstPartstring
                }
                var time6SecondPartString = String(Int(alarmState[57], radix: 16) ?? 0)
                if time6SecondPartString.count == 1 {
                    time6SecondPartString = "0" + time6SecondPartString
                }
                let time6String  = "\(time6FirstPartstring):\(time6SecondPartString)"
                date6Lable.text = time6String
            }
            
            if alarmState[63] == "ff" && alarmState[66] == "ff" {
                date7Lable.text = "-- : --"
            } else{
                var time7FirstPartstring = String(Int(alarmState[63], radix: 16) ?? 0)
                if time7FirstPartstring.count == 1 {
                    time7FirstPartstring = "0" + time7FirstPartstring
                }
                var time7SecondPartString = String(Int(alarmState[66], radix: 16) ?? 0)
                if time7SecondPartString.count == 1 {
                    time7SecondPartString = "0" + time7SecondPartString
                }
                let time7String  = "\(time7FirstPartstring):\(time7SecondPartString)"
                date7Lable.text = time7String
            }
            
            if alarmState[72] == "ff" && alarmState[75] == "ff" {
                date8Lable.text = "-- : --"
            } else{
                var time8FirstPartstring = String(Int(alarmState[72], radix: 16) ?? 0)
                if time8FirstPartstring.count == 1 {
                    time8FirstPartstring = "0" + time8FirstPartstring
                }
                var time8SecondPartString = String(Int(alarmState[75], radix: 16) ?? 0)
                if time8SecondPartString.count == 1 {
                    time8SecondPartString = "0" + time8SecondPartString
                }
                let time8String  = "\(time8FirstPartstring):\(time8SecondPartString)"
                date8Lable.text = time8String
            }
            
            if alarmState[81] == "ff" && alarmState[84] == "ff" {
                date9Lable.text = "-- : --"
            } else{
                var time9FirstPartstring = String(Int(alarmState[81], radix: 16) ?? 0)
                if time9FirstPartstring.count == 1 {
                    time9FirstPartstring = "0" + time9FirstPartstring
                }
                var time9SecondPartString = String(Int(alarmState[84], radix: 16) ?? 0)
                if time9SecondPartString.count == 1 {
                    time9SecondPartString = "0" + time9SecondPartString
                }
                let time9String  = "\(time9FirstPartstring):\(time9SecondPartString)"
                date9Lable.text = time9String
                
            }
            
            
            let time1SwitchHex = alarmState[15]
            let time1SwitchString = String(time1SwitchHex)
            if time1SwitchString == "01" {
                alarmSwitch1.isOn = true
                alarmSwitch1.isEnabled = true
            } else {
                alarmSwitch1.isOn = false
                alarmSwitch1.isEnabled = false
            }
            let time2SwitchHex = alarmState[24]
            let time2SwitchString = String(time2SwitchHex)
            if time2SwitchString == "01" {
                alarmSwitch2.isOn = true
                alarmSwitch2.isEnabled = true
            } else {
                alarmSwitch2.isOn = false
                alarmSwitch2.isEnabled = false
            }
            let time3SwitchHex = alarmState[33]
            let time3SwitchString = String(time3SwitchHex)
            if time3SwitchString == "01" {
                alarmSwitch3.isOn = true
                alarmSwitch3.isEnabled = true
            } else {
                alarmSwitch3.isOn = false
                alarmSwitch3.isEnabled = false
            }
            let time4SwitchHex = alarmState[42]
            let time4SwitchString = String(time4SwitchHex)
            if time4SwitchString == "01" {
                alaramSwitch4.isOn = true
                alaramSwitch4.isEnabled = true
            } else {
                alaramSwitch4.isOn = false
                alaramSwitch4.isEnabled = false
            }
            let time5SwitchHex = alarmState[51]
            let time5SwitchString = String(time5SwitchHex)
            if time5SwitchString == "01" {
                alarmSwitch5.isOn = true
                alarmSwitch5.isEnabled = true
            } else {
                alarmSwitch5.isOn = false
                alarmSwitch5.isEnabled = false
            }
            let time6SwitchHex = alarmState[60]
            let time6SwitchString = String(time6SwitchHex)
            if time6SwitchString == "01" {
                alarmSwitch6.isOn = true
                alarmSwitch6.isEnabled = true
            } else {
                alarmSwitch6.isOn = false
                alarmSwitch6.isEnabled = false
            }
            let time7SwitchHex = alarmState[69]
            let time7SwitchString = String(time7SwitchHex)
            if time7SwitchString == "01" {
                alarmSwitch7.isOn = true
                alarmSwitch7.isEnabled = true
            } else {
                alarmSwitch7.isOn = false
                alarmSwitch7.isEnabled = false
            }
            let time8SwitchHex = alarmState[78]
            let time8SwitchString = String(time8SwitchHex)
            if time8SwitchString == "01" {
                alarmSwitch8.isOn = true
                alarmSwitch8.isEnabled = true
            } else {
                alarmSwitch8.isOn = false
                alarmSwitch8.isEnabled = false
            }
            let time9SwitchHex = alarmState[87]
            let time9SwitchString = String(time9SwitchHex)
            if time9SwitchString == "01" {
                alarmSwitch9.isOn = true
                alarmSwitch9.isEnabled = true
            } else {
                alarmSwitch9.isOn = false
                alarmSwitch9.isEnabled = false
            }
            
            //            print("Time1SwitchString:", time1SwitchString)
            
        }
        
        //        print("TimeToShoww", time1ToShow)
        //        if dynamicAletTag == 1 {
        //            date1Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 2 {
        //            date2Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 3 {
        //            date3Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 4 {
        //            date4Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 5 {
        //            date5Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 6 {
        //            date6Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 7 {
        //            date7Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 8 {
        //            date8Lable.text = dateLable1Time
        //        }
        //        if dynamicAletTag == 9 {
        //            date9Lable.text = dateLable1Time
        //        }
        
        setUpGesture()
        //        alarmSwitch1.isOn = false
        //        alarmSwitch2.isOn = false
        //        alarmSwitch3.isOn = false
        //        alaramSwitch4.isOn = false
        //        alarmSwitch5.isOn = false
        //        alarmSwitch6.isOn = false
        //        alarmSwitch7.isOn = false
        //        alarmSwitch8.isOn = false
        //        alarmSwitch9.isOn = false
        //        
        //        alarmSwitch1.isEnabled = false
        //        alarmSwitch2.isEnabled = false
        //        alarmSwitch3.isEnabled = false
        //        alaramSwitch4.isEnabled = false
        //        alarmSwitch5.isEnabled = false
        //        alarmSwitch6.isEnabled = false
        //        alarmSwitch7.isEnabled = false
        //        alarmSwitch8.isEnabled = false
        //        alarmSwitch9.isEnabled = false
    }
    func setUpGesture() {
        if let alarm1View = alarm1View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap1))
            alarm1View.addGestureRecognizer(tapGesture)
        }
        if let alarm2View = alarm2View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap2))
            alarm2View.addGestureRecognizer(tapGesture)
        }
        if let alarm3View = alarm3View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap3))
            alarm3View.addGestureRecognizer(tapGesture)
        }
        if let alarm4View = alarm4View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap4))
            alarm4View.addGestureRecognizer(tapGesture)
        }
        if let alarm5View = alarm5View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap5))
            alarm5View.addGestureRecognizer(tapGesture)
        }
        if let alarm6View = alarm6View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap6))
            alarm6View.addGestureRecognizer(tapGesture)
        }
        if let alarm7View = alarm7View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap7))
            alarm7View.addGestureRecognizer(tapGesture)
        }
        if let alarm8View = alarm8View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap8))
            alarm8View.addGestureRecognizer(tapGesture)
        }
        if let alarm9View = alarm9View {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap9))
            alarm9View.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func viewTap1() {
        navigateToSetAlarm(viewTag: 1)
    }
    @objc func viewTap2() {
        navigateToSetAlarm(viewTag: 2)
    }
    @objc func viewTap3() {
        navigateToSetAlarm(viewTag: 3)
    }
    @objc func viewTap4() {
        navigateToSetAlarm(viewTag: 4)
    }
    @objc func viewTap5() {
        navigateToSetAlarm(viewTag: 5)
    }
    @objc func viewTap6() {
        navigateToSetAlarm(viewTag: 6)
    }
    @objc func viewTap7() {
        navigateToSetAlarm(viewTag: 7)
    }
    @objc func viewTap8() {
        navigateToSetAlarm(viewTag: 8)
    }
    @objc func viewTap9() {
        navigateToSetAlarm(viewTag: 9)
    }
    
    func navigateToSetAlarm(viewTag: Int) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SetAlarmVC") as! SetAlarmVC
        vc.datePickerDelegate = self
        vc.selectedTag = viewTag
        dynamicAletTag = viewTag
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popToViewController((self.navigationController?.viewControllers[0]) as! BluetoothVC, animated: true)
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        delegate?.value(time: time1 ?? "", alarmNumber: dynamicAletTag)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func switchAction1(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 1)
    }
    @IBAction func switchAction2(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 2)
    }
    @IBAction func switchAction3(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 3)
    }
    @IBAction func switchAction4(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 4)
    }
    @IBAction func switchAction5(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 5)
    }
    @IBAction func switchAction6(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 6)
    }
    @IBAction func switchAction7(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 7)
    }
    @IBAction func switchAction8(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 8)
    }
    @IBAction func switchAction9(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: 9)
    }
    func handleSwitchChange(sender: UISwitch, viewNumber: Int) {
        let isEnabled = sender.isOn
        delegate?.alarmSwitchDidChange(isEnabled: isEnabled, tag: viewNumber)
    }
}

extension AlarmVC {
    func didSelectDate(date: String, for viewTag: Int) {
        if viewTag == 1 {
            date1Lable.text = date
            time1 = date
            alarmSwitch1.isEnabled = true
            //            print("time1", time1)
        } else if viewTag == 2 {
            date2Lable.text = date
            time1 = date
            alarmSwitch2.isEnabled = true
        } else if viewTag == 3 {
            date3Lable.text = date
            time1 = date
            alarmSwitch3.isEnabled = true
        } else if viewTag == 4 {
            date4Lable.text = date
            time1 = date
            alaramSwitch4.isEnabled = true
        } else if viewTag == 5 {
            date5Lable.text = date
            time1 = date
            alarmSwitch5.isEnabled = true
        } else if viewTag == 6 {
            date6Lable.text = date
            time1 = date
            alarmSwitch6.isEnabled = true
        } else if viewTag == 7 {
            date7Lable.text = date
            time1 = date
            alarmSwitch7.isEnabled = true
        } else if viewTag == 8 {
            date8Lable.text = date
            time1 = date
            alarmSwitch8.isEnabled = true
        } else if viewTag == 9 {
            date9Lable.text = date
            time1 = date
            alarmSwitch9.isEnabled = true
        }
    }
}
