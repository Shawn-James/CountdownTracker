//
//  SortFilterViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit
import Combine


protocol SortFilterViewModeling {
   var tags: [Tag] { get }

   var currentSort: EventSort { get set }
   var currentFilter: EventFilter { get set }
}

struct SortFilterViewModel: SortFilterViewModeling {
   var tags: [Tag]

   var currentSort: EventSort
   var currentFilter: EventFilter
}

class SortFilterViewController: UIViewController {

   var viewModel: SortFilterViewModeling!

   private lazy var sortDelegate = SortPickerDelegate(viewModel.currentSort)
   private lazy var filterDelegate = FilterPickerDelegate()
   private lazy var tagDelegate = TagFilterPickerDelegate(viewModel)

   private var cancellables = Set<AnyCancellable>()

   // MARK: - Outlets

   @IBOutlet private weak var sortPicker: UIPickerView!
   @IBOutlet private weak var filterPicker: UIPickerView!
   @IBOutlet private weak var tagPicker: UIPickerView!
   @IBOutlet private weak var datePicker: UIDatePicker!

   // MARK: - View Lifecyle

   override func viewDidLoad() {
      super.viewDidLoad()

      // set picker delegates & reload data

      sortPicker.delegate = sortDelegate
      filterPicker.delegate = filterDelegate
      tagPicker.delegate = tagDelegate

      sortPicker.reloadAllComponents()
      filterPicker.reloadAllComponents()
      tagPicker.reloadAllComponents()

      resetPickerSelections()

      showHideFilterComponents(for: viewModel.currentFilter)

      sortDelegate.$selectedSort
         .sink { [weak self] in self?.viewModel.currentSort = $0 }
         .store(in: &cancellables)
   }

   // MARK: - Methods

   /// Set current picker selections from current saved setting.
   private func resetPickerSelections() {
      if let sortStyleIndex = EventSort.Property.allCases.firstIndex(of: viewModel.currentSort.property) {
         sortPicker.selectRow(sortStyleIndex, inComponent: 0, animated: false)
      }

      filterPicker.selectRow(viewModel.currentFilter.intValue, inComponent: 0, animated: false)

      if case .tag(let tagID) = viewModel.currentFilter {
         let tagIdx = viewModel.tags.firstIndex(where: { $0.uuid == tagID }) ?? 0
         tagPicker.selectRow(tagIdx, inComponent: 0, animated: false)
      }

      if let date = viewModel.currentFilter.date {
         datePicker.setDate(date, animated: false)
      }

      datePicker.minimumDate = Date()
   }

   /// Show or hide pickers based on the given filter setting.
   private func showHideFilterComponents(for filterStyle: EventFilter) {
      switch filterStyle {
      case .before, .after:
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

   // MARK: - Actions

   @IBAction private func cancelTapped(_ sender: UIBarButtonItem) {
      dismiss(animated: true, completion: nil)
   }

   /// Save the selected settings and filter the table view's list of events.
   @IBAction private func saveTapped(_ sender: UIBarButtonItem) {
      let sort = sortDelegate.selectedSort

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
}
