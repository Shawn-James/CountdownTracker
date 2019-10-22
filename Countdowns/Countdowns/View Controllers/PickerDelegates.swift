//
//  PickerDelegates.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-22.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class SortPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventController.SortStyle.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventController.SortStyle.allCases[row].rawValue
    }
}

class FilterPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let delegate: SortFilterViewController
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventController.FilterStyle.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventController.FilterStyle.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let filterStyle = EventController.FilterStyle.allCases[row]
        delegate.showHideFilterComponents(for: filterStyle)
    }
    
    init(delegate: SortFilterViewController) {
        self.delegate = delegate
    }
}

class TagFilterPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventController.shared.tags.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventController.shared.tags[row]
    }
}
