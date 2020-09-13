//
//  AddEditEventViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


protocol AddOrEditEventViewModeling: AnyObject {
   var tags: [Tag] { get }
   var hasCustomTime: Bool { get set }
}

protocol AddEventViewModeling: AddOrEditEventViewModeling {

}


protocol EditEventViewModeling: AddOrEditEventViewModeling {
   var event: Event { get }
}

class AddEventViewModel: AddEventViewModeling {
   let tags: [Tag]

   var hasCustomTime: Bool = false

   private let eventController: EventController

   init(eventController: EventController) {
      self.eventController = eventController
   }
}

class EditEventViewModel: EditEventViewModeling, EventDetailViewModeling {
   let tags: [Tag]

   var event: Event
   lazy var hasCustomTime: Bool = event.hasTime

   var editViewModel: EditEventViewModeling { self }

   private let controller: EventController

   init(event: Event, controller: EventController) {
      self.event = event
      self.controller = controller
   }
}


extension Either where A == AddEventViewModeling, B == EditEventViewModeling {
   var addOrEdit: AddOrEditEventViewModeling {
      switch self {
      case .a(let vm): return vm
      case .b(let vm): return vm
      }
   }

   var add: AddEventViewModeling? {
      if case .a(let vm) = self { return vm } else { return nil }
   }

   var edit: EditEventViewModeling? {
      if case .b(let vm) = self { return vm } else { return nil }
   }

   var isAdding: Bool { if case .a = self { return true } else { return false } }
   var isEditing: Bool { !isAdding }
}

class AddEditEventViewController: UIViewController {

   var viewModel: Either<AddEventViewModeling, EditEventViewModeling>!

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

      setUpViews()

      if viewModel.isEditing {
         resetViewsForEditingEvent()
      }
   }

   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
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
            else { return Date() }

         return dateFromComponents
      }
   }

   /// If tags were entered, separate by commas, strip extraneous whitespace,
   /// and return for use in saving the event. Empty tags are not allowed.
   private func getTagDataFromField() -> [Tag]? {
      var tags = [Tag]()

      if let tagsText = tagsField.text, !tagsText.isEmpty {
         let subTags = tagsText.split(separator: .tagSeparator, omittingEmptySubsequences: true)
         for subTag in subTags {
            let newTag = String(subTag).strippedMultiSpace()
            if !newTag.isEmpty { tags.append(newTag) }
         }
      }

      return tags
   }

   /// Save the event, adding it to the list if new or updating the event if editing.
   private func finalizeEventFromData(name: String, date: Date, tags: [Tag], note: String) {
      if event == nil {
         // add new event (if adding)
         let newEvent = Event(
            name: name,
            dateTime: date,
            tags: Set(tags),
            note: note,
            hasTime: hasCustomTime
         )
         EventController.shared.create(newEvent)

         addEventDelegate?.updateViews()
         addEventDelegate?.selectRow(for: newEvent)
      } else {
         // edit event (if editing)
         EventController.shared.update(
            viewModel.event!,
            withName: name,
            dateTime: date,
            tags: tags,
            note: note,
            hasTime: viewModel.hasCustomTime
         )

         editEventDelegate?.updateViews()
      }
   }

   // MARK: - Reset Views

   /// If scene called to edit event, populate views
   /// with event info for editing.
   private func resetViewsForEditingEvent() {
      guard let event = event else { return }

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

      sceneTitleLabel.text = "Edit event"
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
      if let event = event, event.archived == true {
         // if archived, we want the event date/time to remain the same!
         datePicker.minimumDate = nil
         timePicker.minimumDate = nil
         return
      }
      datePicker.minimumDate = Date()
      if Calendar.autoupdatingCurrent.dateComponents(
         [.year, .month, .day],
         from: datePicker.date
         ) == Calendar.autoupdatingCurrent.dateComponents(
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

   private func setUpViews() {
      customTimeSwitch.addTarget(self,
                                 action: #selector(hasCustomTimeDidChange(_:)),
                                 for: .touchUpInside)
   }

   @objc func hasCustomTimeDidChange(_ sender: Any?) {
      viewModel.hasCustomTime = customTimeSwitch.isOn
   }
}
