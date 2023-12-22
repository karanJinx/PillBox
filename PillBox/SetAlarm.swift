//
//  SetAlarm.swift
//  PillBox
//
//  Created by Humworld Solutions Private Limited on 18/12/23.
//

import Foundation
import UIKit

protocol DatePickerDelegate {
    func didSelectDate(date: String, for viewTag: Int)
}
class SetAlarmVC: UIViewController {
    @IBOutlet var setAlarmView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var remarksTextField: UITextField!
    
    //    let switch1State:Bool = false
    
    var datePickerDelegate: DatePickerDelegate? = nil
    var selectedTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonPressedToSaveAlarm))
        navigationItem.rightBarButtonItem = saveBarButton
        
        let backBarButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backButtonPressedToExitpage))
        navigationItem.leftBarButtonItem = backBarButton
        
        
    }
    
    @objc func saveButtonPressedToSaveAlarm() {
        guard let selectedDate = datePicker?.date else {return}
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "HH:mm a"
        let dateString = dateFormat.string(from: selectedDate)
        if datePickerDelegate != nil {
            self.datePickerDelegate?.didSelectDate(date: dateString, for: selectedTag)
        }
        navigationController?.popViewController(animated: true)
    }
    @objc func backButtonPressedToExitpage() {
        navigationController?.popViewController(animated: true)
    }
    
}
