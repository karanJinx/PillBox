//
//  AddAlarmVC.swift
//  PillBox
//
//  Created by Humworld Solutions Private Limited on 11/12/23.
//

import Foundation
import UIKit

class AddAlarmVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        //let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//        self.navigationController?.popToViewController((self.navigationController?.viewControllers[0] as! ViewController), animated: true)
        navigationController?.popViewController(animated: true)
    }
}
