//
//  AddTaskViewController.swift
//  trash-panda
//
//  Created by Pivotal on 2017-05-10.
//
//

import UIKit
import Firebase

class AddTaskViewController: UIViewController, UITextFieldDelegate {

    let rootRef = FIRDatabase.database().reference()
    let placeholderText: String = "Trash name"
    
    // MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var taskTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        taskTextField.delegate = self
        taskTextField.placeholder = placeholderText
        
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            fatalError("Save button was not pressed, cancelling")
        }
        let text = taskTextField.text ?? ""
        self.rootRef.child("trash").childByAutoId().setValue(["name": "\(text)"])
        // return some data
    }

    // MARK: Text Field Delegate
    // TODO: add tap gesture on view to lose text field focus
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        taskTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
        taskTextField.placeholder = placeholderText
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        taskTextField.placeholder = placeholderText
    }
    
    // MARK: Private Method
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = taskTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}
