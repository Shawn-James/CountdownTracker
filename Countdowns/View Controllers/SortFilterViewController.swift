//
//  SortFilterViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit
import Combine


protocol SortFilterViewModeling: AnyObject {
   var tags: [Tag] { get }

   var currentSort: EventSort { get set }
   var currentFilter: EventFilter { get set }
}

class SortFilterViewModel: SortFilterViewModeling {
   var tags: [Tag]

   var currentSort: EventSort
   var currentFilter: EventFilter

   init(tags: [Tag], sort: EventSort, filter: EventFilter) {
      self.tags = tags
      self.currentSort = sort
      self.currentFilter = filter
   }
}

class SortFilterViewController: UIViewController {
   var viewModel: SortFilterViewModeling!

   private lazy var sortDelegate = SortPickerDelegate(viewModel)
   private lazy var filterDelegate = FilterPickerDelegate(viewModel)
   private lazy var tagDelegate = TagFilterPickerDelegate(viewModel)

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
}
