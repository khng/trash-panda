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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTaskViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
        taskTextField.delegate = self
        taskTextField.placeholder = placeholderText
        
        updateSaveButtonState()
    }
    
    // MARK: - Navigation
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            fatalError("Save button was not pressed, cancelling")
        }
        let text = taskTextField.text ?? ""
        self.rootRef.child("trash").childByAutoId().setValue(["name": "\(text)", "timestamp": Int(Date().timeIntervalSince1970)])
        // return some data
    }

    // MARK: Text Field Delegate
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
    
    // MARK: Action
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        saveButton.isEnabled = (taskTextField.text?.characters.count)! > 0
    }
    
    // MARK: Private Method
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = taskTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // MARK: Helper Method
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
