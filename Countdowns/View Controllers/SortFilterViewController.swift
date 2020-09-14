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

   var didChange: (() -> Void)? { get set }
   var didFinish: (() -> Void)? { get set }

   var currentSort: EventSortDescriptor { get set }
   var currentFilter: EventFilterDescriptor { get set }
}


class SortFilterViewController: UIViewController {
   var viewModel: SortFilterViewModeling!

   private lazy var sortDelegate = SortPickerDelegate(viewModel)
   private lazy var filterDelegate = FilterPickerDelegate(viewModel)
   private lazy var tagDelegate = TagFilterPickerDelegate(viewModel)

   @IBOutlet private weak var sortPicker: UIPickerView!
   @IBOutlet private weak var filterPicker: UIPickerView!
   @IBOutlet private weak var tagPicker: UIPickerView!
   @IBOutlet private weak var datePicker: UIDatePicker!

   // MARK: - View Lifecyle

   override func viewDidLoad() {
      super.viewDidLoad()

      viewModel.didChange = { [unowned self] in
         self.showHideFilterComponents(for: self.viewModel.currentFilter)
      }

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

   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      viewModel.didFinish?()
   }

   // MARK: - Methods

   /// Set current picker selections from current saved setting.
   private func resetPickerSelections() {
      if let sortStyleIndex = EventSortDescriptor.Property.allCases.firstIndex(of: viewModel.currentSort.property) {
         sortPicker.selectRow(sortStyleIndex, inComponent: 0, animated: false)
      }

      filterPicker.selectRow(
         viewModel.currentFilter.option.intValue,
         inComponent: 0,
         animated: false)

      if case .tag(let tagID) = viewModel.currentFilter.option {
         let tagIdx = viewModel.tags.firstIndex(where: { $0.uuid == tagID }) ?? 0
         tagPicker.selectRow(tagIdx, inComponent: 0, animated: false)
      }

      if let date = viewModel.currentFilter.option.date {
         datePicker.setDate(date, animated: false)
      }

      datePicker.minimumDate = Date()
   }

   /// Show or hide pickers based on the given filter setting.
   private func showHideFilterComponents(for filterStyle: EventFilterDescriptor) {
      switch filterStyle.option {
      case .date:
         tagPicker.isHidden = true
         datePicker.isHidden = false
      case .tag:
         tagPicker.isHidden = false
         datePicker.isHidden = true
      case .all:
         tagPicker.isHidden = true
         datePicker.isHidden = true
      }
   }
}
