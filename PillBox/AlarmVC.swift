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
    
    var dateLable1Time = ""
    var dateLable2Time = ""
    
    
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
    
    
    var dynamicAletTag: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        if dynamicAletTag == 1 {
            date1Lable.text = dateLable1Time
        }
        if dynamicAletTag == 2 {
            date2Lable.text = dateLable1Time
        }
        if dynamicAletTag == 3 {
            date3Lable.text = dateLable1Time
        }
        if dynamicAletTag == 4 {
            date4Lable.text = dateLable1Time
        }
        if dynamicAletTag == 5 {
            date5Lable.text = dateLable1Time
        }
        if dynamicAletTag == 6 {
            date6Lable.text = dateLable1Time
        }
        if dynamicAletTag == 7 {
            date7Lable.text = dateLable1Time
        }
        if dynamicAletTag == 8 {
            date8Lable.text = dateLable1Time
        }
        if dynamicAletTag == 9 {
            date9Lable.text = dateLable1Time
        }

        setUpGesture()
        alarmSwitch1.isOn = false
        alarmSwitch2.isOn = false
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
        handleSwitchChange(sender: sender, viewNumber: dynamicAletTag)
    }
    @IBAction func switchAction2(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: dynamicAletTag)
    }
    @IBAction func switchAction3(_ sender: UISwitch) {
        handleSwitchChange(sender: sender, viewNumber: dynamicAletTag)
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
//            print("time1", time1)
        } else if viewTag == 2 {
            date2Lable.text = date
            time1 = date
        } else if viewTag == 3 {
            date3Lable.text = date
            time1 = date
        } else if viewTag == 4 {
            date4Lable.text = date
            time1 = date
        } else if viewTag == 5 {
            date5Lable.text = date
            time1 = date
        } else if viewTag == 6 {
            date6Lable.text = date
            time1 = date
        } else if viewTag == 7 {
            date7Lable.text = date
            time1 = date
        } else if viewTag == 8 {
            date8Lable.text = date
            time1 = date
        } else if viewTag == 9 {
            date9Lable.text = date
            time1 = date
        }
    }
}
