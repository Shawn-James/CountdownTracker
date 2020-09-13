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

   var currentSort: EventSortDescriptor { get set }
   var currentFilter: UserFilterOption { get set }
}

class SortFilterViewModel: SortFilterViewModeling {
   var tags: [Tag] { (try? controller.fetchTags(.all)) ?? [] }

   var currentSort: EventSortDescriptor {
      get { controller.currentSortStyle }
      set { controller.currentSortStyle = newValue }
   }
   var currentFilter: UserFilterOption {
      get { UserFilterOption(controller.currentFilter) ?? .all }
      set { controller.currentFilter = newValue.filterDescriptor }
   }

   private let controller: EventController

   init(_ controller: EventController) {
      self.controller = controller
   }
}

enum UserFilterOption {
   case all
   case before(Date)
   case after(Date)
   case tag(UUID?)

   init?(_ filter: EventFilterDescriptor) {
      switch filter {
      case .all:
         self = .all
      case let .date(date, endIsBefore):
         self = endIsBefore ? .before(date) : .after(date)
      case .tag(let tag):
         self = .tag(tag)
      default: return nil
      }
   }

   var filterDescriptor: EventFilterDescriptor {
      get {
         switch self {
         case .all:
            return .all
         case .before(let date):
            return .before(date)
         case .after(let date):
            return .after(date)
         case .tag(let tagID):
            return .tag(tagID)
         }
      }
      set {
         switch newValue {
         case let .date(date, endIsBefore):
            self = endIsBefore ? .before(date) : .after(date)
         case .tag(let tagID):
            self = .tag(tagID)
         default: self = .all
         }
      }
   }

   var intValue: Int {
      get { filterDescriptor.intValue }
      set { filterDescriptor.intValue = newValue }
   }
   var date: Date? {
      switch self {
      case .before(let date), .after(let date):
         return date
      default: return nil
      }
   }
   var tagID: UUID? {
      if case .tag(let tagID) = self {
         return tagID
      } else {
         return nil
      }
   }

   static var descriptions: [String] {
      ["(none)",
       "Now → ...",
       "... → ∞",
       "Tag...",]
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
      if let sortStyleIndex = EventSortDescriptor.Property.allCases.firstIndex(of: viewModel.currentSort.property) {
         sortPicker.selectRow(sortStyleIndex, inComponent: 0, animated: false)
      }

      filterPicker.selectRow(
         viewModel.currentFilter.intValue,
         inComponent: 0,
         animated: false)

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
   private func showHideFilterComponents(for filterStyle: UserFilterOption) {
      switch filterStyle {
      case .before, .after:
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
