//
//  SortFilterViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

protocol SortFilterViewControllerDelegate {
   var currentSort: EventSort { get set }
   var currentFilter: EventFilter { get set }
   var currentFilterTag: Tag { get set }
   var currentFilterDate: Date { get set }

   func updateViews()
}

protocol SortFilterViewModeling {
   var tags: [Tag] { get }

   var currentFilter: EventFilter { get }
   var currentSort: EventSort { get }

   var sortDelegate: UIPickerViewDelegate & UIPickerViewDataSource { get }
   var filterDelegate: UIPickerViewDelegate & UIPickerViewDataSource { get }
   var tagDelegate: UIPickerViewDelegate & UIPickerViewDataSource { get }
}

struct SortFilterViewModel: SortFilterViewModeling {
   var currentFilter: EventFilter
   var currentSort: EventSort

   var tags: [Tag]

   let sortDelegate: UIPickerViewDataSource & UIPickerViewDelegate = SortPickerDelegate()
   let filterDelegate: UIPickerViewDataSource & UIPickerViewDelegate = FilterPickerDelegate()
   let tagDelegate: UIPickerViewDataSource & UIPickerViewDelegate = TagFilterPickerDelegate()
}

class SortFilterViewController: UIViewController {

   // MARK: - Properties

   var viewModel: SortFilterViewModeling!

   weak var delegate: SortFilterViewControllerDelegate?

   // MARK: - Outlets

   @IBOutlet weak var sortPicker: UIPickerView!
   @IBOutlet weak var filterPicker: UIPickerView!
   @IBOutlet weak var tagPicker: UIPickerView!
   @IBOutlet weak var datePicker: UIDatePicker!

   // MARK: - View Lifecyle

   override func viewDidLoad() {
      super.viewDidLoad()

      // set picker delegates & reload data
      sortPicker.delegate = viewModel.sortDelegate
      filterPicker.delegate = viewModel.filterDelegate
      tagPicker.delegate = viewModel.tagDelegate


      sortPicker.reloadAllComponents()
      filterPicker.reloadAllComponents()
      tagPicker.reloadAllComponents()

      resetPickerSelections()

      showHideFilterComponents(for: viewModel.currentFilter)
   }

   // MARK: - Methods

   /// Set current picker selections from current saved setting.
   func resetPickerSelections() {
      if let sortStyleIndex = EventSort.Property.allCases.firstIndex(of: viewModel.currentSort.property) {
         sortPicker.selectRow(sortStyleIndex, inComponent: 0, animated: false)
      }

      filterPicker.selectRow(viewModel.currentFilter.intValue, inComponent: 0, animated: false)
      if case .tag(let tagID) = viewModel.currentFilter,
         let tagIdx = viewModel.tags.firstIndex(where: { $0.uuid == tagID })
      {
         
      }

      if let currentTag = EventController.shared.currentFilterTag,
         let currentTagIndex = EventController.shared.tags.firstIndex(of: currentTag) {
         tagPicker.selectRow(currentTagIndex, inComponent: 0, animated: false)
      } else {
         tagPicker.selectRow(0, inComponent: 0, animated: false)
      }

      if EventController.shared.currentFilterDate < Date() {
         EventController.shared.currentFilterDate = Date()
      }
      datePicker.minimumDate = Date()
      datePicker.setDate(EventController.shared.currentFilterDate, animated: false)
   }

   /// Show or hide pickers based on the given filter setting.
   func showHideFilterComponents(for filterStyle: EventFilter) {
      switch filterStyle {
      case .noLaterThanDate, .noSoonerThanDate:
         tagPicker.isHidden = true
         datePicker.isHidden = false
      case .tag:
         tagPicker.isHidden = false
         datePicker.isHidden = true
      case .none:
         tagPicker.isHidden = true
         datePicker.isHidden = true
      }
   }

   // MARK: - IB Methods

   @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
      dismiss(animated: true, completion: nil)
   }

   /// Save the selected settings and filter the table view's list of events.
   @IBAction func saveTapped(_ sender: UIBarButtonItem) {
      let sortChoiceIndex = sortPicker.selectedRow(inComponent: 0)
      let sortChoice = EventController.SortStyle.allCases[sortChoiceIndex]

      let filterChoiceIndex = filterPicker.selectedRow(inComponent: 0)
      let filterChoice = EventController.FilterStyle.allCases[filterChoiceIndex]

      let tagChoiceIndex = tagPicker.selectedRow(inComponent: 0)
      let tagChoice: Tag
      if EventController.shared.tags.isEmpty {
         if filterChoice == .tag {
            // Prevent user from applying tag filter without having any tags to filter by
            showEmptyTagListAlert()
            return
         } else {
            tagChoice = ""
         }
      } else {
         tagChoice = EventController.shared.tags[tagChoiceIndex]
      }

      delegate?.currentSortStyle = sortChoice
      delegate?.currentFilterStyle = filterChoice
      delegate?.currentFilterTag = tagChoice
      delegate?.currentFilterDate = datePicker.date

      dismiss(animated: true) {
         self.delegate?.updateViews()
      }
   }

   // MARK: - Private Methods

   /// Show alert if the user has selected to filter by tags, but their events do not have any tags applied to them.
   private func showEmptyTagListAlert() {
      let alert = UIAlertController(
         title: "Cannot filter by tag!",
         message: "No tags are currently being used in your countdowns; please choose another filter style.",
         preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(
         title: "OK",
         style: .default,
         handler: nil
      ))

      present(alert, animated: true, completion: nil)
   }
}
