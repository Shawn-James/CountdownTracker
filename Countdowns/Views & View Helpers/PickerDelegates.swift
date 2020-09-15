//
//  PickerDelegates.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-22.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


// MARK: - Sort

class SortPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
   // COMPONENT 1: ASCENDING/DESCENDING
   // COMPONENT 2: PROPERTY BY WHICH TO SORT

   var viewModel: SortFilterViewModeling

   init(_ viewModel: SortFilterViewModeling) {
      self.viewModel = viewModel
   }

   func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

   func pickerView(
      _ pickerView: UIPickerView,
      numberOfRowsInComponent component: Int
   ) -> Int {
      if component == 0 {
         return 2
      } else {
         return EventSortDescriptor.Property.allCases.count
      }
   }

   func pickerView(
      _ pickerView: UIPickerView,
      titleForRow row: Int,
      forComponent component: Int
   ) -> String? {
      if component == 0 {
         return (row == 1) ? "↑" : "↓"
      } else {
         return EventSortDescriptor.Property(rawValue: UInt8(row))?.description
      }
   }

   func pickerView(
      _ pickerView: UIPickerView,
      didSelectRow row: Int,
      inComponent component: Int
   ) {
      if component == 0 {
         let ascending = (row == 1)
         viewModel.currentSort.ascending = ascending
      } else if let property = EventSortDescriptor.Property(rawValue: UInt8(row)) {
         viewModel.currentSort.property = property
      }
   }

   func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
      if component == 0 {
         return pickerView.intrinsicContentSize.width * 0.15
      } else {
         return pickerView.intrinsicContentSize.width * 0.85
      }
   }
}

// MARK: - Filter

class FilterPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
   var viewModel: SortFilterViewModeling

   init(_ viewModel: SortFilterViewModeling) {
      self.viewModel = viewModel
   }

   func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      // if no tags, don't let user filter by tag
      let filterCount = EventFilterDescriptor.Option.descriptions.count
      if viewModel.tags.count > 0 {
         return filterCount
      } else {
         return filterCount - 1
      }
   }

   func pickerView(
      _ pickerView: UIPickerView,
      titleForRow row: Int,
      forComponent component: Int
   ) -> String? {
      EventFilterDescriptor.Option.descriptions[row]
   }

   func pickerView(
      _ pickerView: UIPickerView,
      didSelectRow row: Int,
      inComponent component: Int
   ) {
      viewModel.currentFilter.option.intValue = row
   }
}

// MARK: - Filter by Tag

class TagFilterPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
   var viewModel: SortFilterViewModeling

   init(_ viewModel: SortFilterViewModeling) {
      self.viewModel = viewModel
   }

   func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

   func pickerView(
      _ pickerView: UIPickerView,
      numberOfRowsInComponent component: Int
   ) -> Int {
      viewModel.tags.count + 1
   }

   func pickerView(
      _ pickerView: UIPickerView,
      titleForRow row: Int,
      forComponent component: Int
   ) -> String? {
      (row == 0) ? "" : viewModel.tags[row - 1].name
   }

   func pickerView(
      _ pickerView: UIPickerView,
      didSelectRow row: Int,
      inComponent component: Int
   ) {
      viewModel.currentFilter.option.tagID = (row == 0) ?
         nil
         : viewModel.tags[row - 1].uuid
   }
}
