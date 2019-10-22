//
//  AddEventViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

protocol AddEventViewControllerDelegate: UITableViewController {}

class AddEventViewController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: AddEventViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var sceneTitleLabel: UILabel!
    @IBOutlet weak var viewSegmentedControl: UISegmentedControl!
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var customTimeSwitch: UISwitch!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func viewSegmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dateLabel.isHidden = false
            datePicker.isHidden = false
            timeLabel.isHidden = false
            timePicker.isHidden = !customTimeSwitch.isOn
            customTimeSwitch.isHidden = false
            
            notesLabel.isHidden = true
            notesTextView.isHidden = true
            
            if notesTextView.isFirstResponder {
                notesTextView.resignFirstResponder()
            }
        case 1:
            dateLabel.isHidden = true
            datePicker.isHidden = true
            timeLabel.isHidden = true
            timePicker.isHidden = true
            customTimeSwitch.isHidden = true
            
            notesLabel.isHidden = false
            notesTextView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func customTimeSwitchChanged(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            timePicker.isHidden = false
        case false:
            timePicker.isHidden = true
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let eventName = eventNameField.text, !eventName.isEmpty
            else { return }
        
        let eventDate: Date
        if !customTimeSwitch.isOn {
            eventDate = datePicker.date
        } else {
            let date = Calendar.autoupdatingCurrent.dateComponents(
                [.year, .month, .day],
                from: datePicker.date
            )
            let time = Calendar.autoupdatingCurrent.dateComponents(
                [.hour, .minute],
                from: timePicker.date
            )
            
            let dateComponents = DateComponents(
                calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent,
                year: date.year, month: date.month, day: date.day,
                hour: time.hour, minute: time.minute
            )
            guard let dateFromComponents = dateComponents.date else { return }
            
            eventDate = dateFromComponents
        }
        
        let event: Event
        if let note = notesTextView.text, !note.isEmpty {
            event = Event(name: eventName, dateTime: eventDate, note: note)
        } else {
            event = Event(name: eventName, dateTime: eventDate)
        }
        
        EventController.shared.create(event)
            
        delegate?.tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
