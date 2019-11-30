//
//  AddEditEventViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

// MARK: - Delegates

protocol AddEventViewControllerDelegate {
    func selectRow(for event: Event)
    func updateViews()
}

protocol EditEventViewControllerDelegate {
    func updateViews()
}

class AddEditEventViewController: UIViewController {
    
    // MARK: - Properties
    
    var addEventDelegate: AddEventViewControllerDelegate?
    var editEventDelegate: EditEventViewControllerDelegate?
    var event: Event?
    
    var hasCustomTime: Bool {
        return customTimeSwitch.isOn
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var sceneTitleLabel: UILabel!
    @IBOutlet weak var viewSegmentedControl: UISegmentedControl!
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var customTimeSwitch: UISwitch!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event != nil {
            resetViewsForEditingEvent()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        eventNameField.becomeFirstResponder()
    }
    
    // MARK: - UI Actions / Overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func viewSegmentControlChanged(_ sender: UISegmentedControl) {
        view.endEditing(true)
        switch sender.selectedSegmentIndex {
        case 0:
            dateLabel.isHidden = false
            datePicker.isHidden = false
            timeLabel.isHidden = false
            timePicker.isHidden = !customTimeSwitch.isOn
            customTimeSwitch.isHidden = false
            
            tagsLabel.isHidden = true
            tagsField.isHidden = true
            notesLabel.isHidden = true
            notesTextView.isHidden = true
        case 1:
            dateLabel.isHidden = true
            datePicker.isHidden = true
            timeLabel.isHidden = true
            timePicker.isHidden = true
            customTimeSwitch.isHidden = true
            
            tagsLabel.isHidden = false
            tagsField.isHidden = false
            notesLabel.isHidden = false
            notesTextView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func customTimeSwitchChanged(_ sender: UISwitch) {
        setTimePickerHidden()
        view.endEditing(true)
        updatePickersMinMax()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let eventName = eventNameField.text, !eventName.isEmpty
            else { return }

        let eventDate = getEventDateFromPickers()
        
        guard let tags = getTagDataFromField() else { return }
        
        // get note
        let hasNote = !notesTextView.text.isEmpty
        let note: String = hasNote ? notesTextView.text : ""
        
        finalizeEventFromData(
            name: eventName,
            date: eventDate,
            tags: tags,
            note: note)
        
        dismiss(animated: true) {
            self.addEventDelegate?.updateViews()
            self.editEventDelegate?.updateViews()
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        view.endEditing(true)
        updatePickersMinMax()
    }
    
    @IBAction func timePickerTouched(_ sender: UIDatePicker) {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    
    /// If custom time being used, concatenate the date
    /// and the time from the two pickers and return
    /// for use in saving the event.
    private func getEventDateFromPickers() -> Date {
        if !hasCustomTime {
            return datePicker.date
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
            guard let dateFromComponents = dateComponents.date
                else { return Date() }
            
            return dateFromComponents
        }
    }
    
    /// If tags were entered, separate by commas,
    /// strip extraneous whitespace, and return
    /// for use in saving the event.
    /// Empty tags are not allowed.
    private func getTagDataFromField() -> [Tag]? {
        var tags = [Tag]()
        
        if let tagsText = tagsField.text, !tagsText.isEmpty {
            let subTags = tagsText.split(separator: .tagSeparator, omittingEmptySubsequences: true)
            for subTag in subTags {
                let newTag = String(subTag).stripMultiSpace()
                if newTag == .emptyTagDisplayText {
                    showAlertForEmptyTag()
                    return nil
                }
                if !newTag.isEmpty { tags.append(newTag) }
            }
        }
        
        return tags
    }
    
    /// Save the event, adding it to the list if new
    /// or updating the event if editing.
    private func finalizeEventFromData(name: String, date: Date, tags: [Tag], note: String) {
        if event == nil {
            // add new event (if adding)
            let newEvent = Event(
                name: name, dateTime: date,
                tags: tags, note: note, hasTime: hasCustomTime
            )
            EventController.shared.create(newEvent)
            
            addEventDelegate?.updateViews()
            addEventDelegate?.selectRow(for: newEvent)
        } else {
            // edit event (if editing)
            EventController.shared.update(
                event!, withName: name, dateTime: date,
                tags: tags, note: note, hasTime: hasCustomTime
            )
            
            editEventDelegate?.updateViews()
        }
    }
    
    private func showAlertForEmptyTag() {
        let alert = UIAlertController(
            title: "Bad tag(s)!",
            message: "Cannot add tag that is empty or named '\(String.emptyTagDisplayText)'; please remove bad tag(s) and try again.",
            preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: nil)))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Reset Views
    
    /// If scene called to edit event, populate views
    /// with event info for editing.
    private func resetViewsForEditingEvent() {
        guard let event = event else { return }
        
        sceneTitleLabel.text = "Edit event"
        eventNameField.text = event.name
        datePicker.date = event.dateTime
        timePicker.date = event.dateTime
        customTimeSwitch.isOn = event.hasTime
        tagsField.text = event.tagsText
        notesTextView.text = event.note
        
        setTimePickerHidden()
        updatePickersMinMax()
        
        if event.archived {
            datePicker.isEnabled = false
            timePicker.isEnabled = false
            customTimeSwitch.isEnabled = false
        }
    }
    
    /// Update the date/time-pickers, partially based on the date-picker's current selection.
    /// If archived, pickers will be locked to event date/time.
    /// Otherwise, the date-picker's minimum date is set to today.
    /// If today's date is selected, no time before now is allowed in the time picker.
    /// Otherwise, allow any time to be chosen from the time-picker.
    private func updatePickersMinMax() {
        if let event = event, event.archived {
            // if archived, we want the event date/time to remain the same!
            datePicker.minimumDate = nil
            timePicker.minimumDate = nil
            return
        }
        datePicker.minimumDate = Date()
        if Calendar.autoupdatingCurrent.dateComponents(
                [.year, .month, .day],
                from: datePicker.date)
            == Calendar.autoupdatingCurrent.dateComponents(
                [.year, .month, .day],
                from: Date()
        ) {
            timePicker.minimumDate = Date()
        } else {
            timePicker.minimumDate = nil
        }
    }
    
    private func setTimePickerHidden() {
        switch customTimeSwitch.isOn {
        case true:
            timePicker.isHidden = false
        case false:
            timePicker.isHidden = true
        }
    }
}
