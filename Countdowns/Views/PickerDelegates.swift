//
//  PickerDelegates.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-22.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

/// Delegates/DataSources for Sort/Filter scene pickers.

// MARK: - Sort

class SortPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
   // COMPONENT 1: ASCENDING OR DESCENDING
   // COMPONENT 2: PROPERTY BY WHICH TO SORT

   private static let moreThanTwoComponentsErrorMsg =
      "Expected only two components in sort picker but found more than two"
   private static let moreThanAllowedRowsErrorMsg =
      "Found more rows in picker component than expected"

   func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      switch component {
      case 0: return 2
      case 1: return EventSort.Property.allCases.count
      default:
         preconditionFailure(Self.moreThanTwoComponentsErrorMsg)
      }
   }

   func pickerView(
      _ pickerView: UIPickerView,
      titleForRow row: Int,
      forComponent component: Int
   ) -> String? {
      switch component {
      case 0:
         switch row {
         case 0: return "↓"
         case 1: return "↑"
         default:
            preconditionFailure(Self.moreThanAllowedRowsErrorMsg)
         }
      case 1:
         guard let property = EventSort.Property(rawValue: UInt8(row)) else {
            preconditionFailure(Self.moreThanAllowedRowsErrorMsg)
         }
         return property.description
      default:
         preconditionFailure(Self.moreThanTwoComponentsErrorMsg)
      }
   }
}

// MARK: - Filter

class FilterPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventController.FilterStyle.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventController.FilterStyle.allCases[row].rawValue
    }
}

// MARK: - Filter by Tag

class TagFilterPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventController.shared.tags.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if EventController.shared.tags[row] == "" {
            return .emptyTagDisplayText
        }
        return EventController.shared.tags[row]
    }
}
