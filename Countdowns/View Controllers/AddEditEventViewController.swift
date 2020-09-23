//
//  AddEditEventViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


class AddEditEventViewController: ShiftableViewController {

   var viewModel: Either<AddEventViewModeling, EditEventViewModeling>!

   var didFinishEditing: (() -> Void)?

   @IBOutlet private weak var viewSegmentedControl: UISegmentedControl!
   @IBOutlet private weak var eventNameField: UITextField!
   @IBOutlet private weak var dateLabel: UILabel!
   @IBOutlet private weak var datePicker: UIDatePicker!
   @IBOutlet private weak var timeLabel: UILabel!
   @IBOutlet private weak var customTimeSwitch: UISwitch!
   @IBOutlet private weak var timePicker: UIDatePicker!
   @IBOutlet private weak var tagsLabel: UILabel!
   @IBOutlet private weak var tagsField: UITextField!
   @IBOutlet private weak var notesLabel: UILabel!
   @IBOutlet private weak var notesTextView: UITextView!
   @IBOutlet private weak var saveButton: UIButton!

   // MARK: - View Lifecycle

   override func viewDidLoad() {
      super.viewDidLoad()

      datePicker.layer.cornerRadius = 5
      datePicker.layer.backgroundColor = UIColor.jbBackground?.cgColor
      timePicker.layer.cornerRadius = 5
      timePicker.layer.backgroundColor = UIColor.jbBackground?.cgColor

      if viewModel.isEditing {
         resetViewsForEditingEvent()
      }

      eventNameField.addTarget(self, action: #selector(nameDidChange(_:)), for: .editingChanged)
      tagsField.addTarget(self, action: #selector(tagTextDidChange(_:)), for: .editingChanged)
      configure(notesTextView!) {
         $0.delegate = self
         $0.layer.borderColor = UIColor.systemGray.cgColor
         $0.layer.borderWidth = 0.5
         $0.layer.cornerRadius = 5
         $0.layer.cornerCurve = .continuous
         $0.font = .preferredFont(forTextStyle: .body)
      }
   }

   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      eventNameField.becomeFirstResponder()
   }

   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      didFinishEditing?()
   }

   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      view.endEditing(true)
      super.touchesBegan(touches, with: event)
   }

   // MARK: - Actions

   @objc private func nameDidChange(_ sender: Any?) {
      viewModel.addOrEdit.newName = eventNameField.text ?? ""
   }

   @objc private func tagTextDidChange(_ sender: Any?) {
      viewModel.addOrEdit.newTagText = tagsField.text ?? ""
   }

   func textViewDidChange(_ textView: UITextView) {
      guard textView == notesTextView else { return }
      viewModel.addOrEdit.newNote = notesTextView.text
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
      viewModel.addOrEdit.hasCustomTime = sender.isOn
      setTimePickerHidden()
      view.endEditing(true)
      updatePickersMinMax()
      viewModel.addOrEdit.newDateTime = getEventDateFromPickers()
   }

   @IBAction func saveButtonTapped(_ sender: UIButton) {
      guard !viewModel.addOrEdit.newName.isEmpty else { return }
      do {
         try viewModel.addOrEdit.saveEvent()
      } catch {
         NSLog("\(error)") // TODO: alert for error
      }
   }

   @IBAction func cancelTapped(_ sender: UIButton) {
      dismiss(animated: true, completion: nil)
   }

   @IBAction func datePickerChanged(_ sender: UIDatePicker) {
      view.endEditing(true)
      updatePickersMinMax()
      viewModel.addOrEdit.newDateTime = getEventDateFromPickers()
   }

   @IBAction func timePickerTouched(_ sender: UIDatePicker) {
      view.endEditing(true)
      viewModel.addOrEdit.newDateTime = getEventDateFromPickers()
   }

   // MARK: - Private Methods

   /// If custom time being used, concatenate the date and the time from the
   /// two pickers and return for use in saving the event.
   private func getEventDateFromPickers() -> Date {
      if !customTimeSwitch.isEnabled {
         return datePicker.date
      } else {
         let cal = Calendar.current
         let date = cal.dateComponents([.year, .month, .day], from: datePicker.date)
         let time = cal.dateComponents([.hour, .minute], from: timePicker.date)

         let dateComponents = DateComponents(
            calendar: cal,
            timeZone: .current,
            year: date.year,
            month: date.month,
            day: date.day,
            hour: time.hour,
            minute: time.minute)
         guard let dateFromComponents = dateComponents.date
            else { fatalError() }

         return dateFromComponents
      }
   }

   // MARK: - Reset Views

   /// If scene called to edit event, populate views
   /// with event info for editing.
   private func resetViewsForEditingEvent() {
      guard let event = viewModel.edit?.event else { return }

      let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
      let eventDateTimeComponents = Calendar.autoupdatingCurrent.dateComponents(
         components,
         from: event.dateTime)
      let nowComponents = Calendar.autoupdatingCurrent.dateComponents(
         components,
         from: Date())
      let timePickerMinComponents = DateComponents(
         calendar: .autoupdatingCurrent,
         timeZone: .autoupdatingCurrent,
         year: nowComponents.year,
         month: nowComponents.month,
         day: nowComponents.day,
         hour: eventDateTimeComponents.hour,
         minute: eventDateTimeComponents.minute)

      navigationItem.title = "Edit event"
      eventNameField.text = event.name
      datePicker.date = event.dateTime
      timePicker.date = timePickerMinComponents.date ?? event.dateTime
      customTimeSwitch.isOn = event.hasTime
      tagsField.text = event.tagsText
      notesTextView.text = event.note

      updatePickersMinMax()
      setTimePickerHidden()

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
      if let event = viewModel.edit?.event, event.archived == true {
         // if archived, we want the event date/time to remain the same!
         datePicker.minimumDate = event.dateTime
         datePicker.maximumDate = event.dateTime
         timePicker.minimumDate = event.dateTime
         timePicker.maximumDate = event.dateTime
         return
      }
      let cal = Calendar.current
      datePicker.minimumDate = Date()
      if cal.dateComponents([.year, .month, .day], from: datePicker.date)
         == cal.dateComponents([.year, .month, .day], from: Date())
      {
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
