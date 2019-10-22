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
        return EventController.SortingStyle.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventController.SortingStyle.allCases[component].rawValue
    }
}

class FilterPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventController.FilterStyle.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventController.FilterStyle.allCases[component].rawValue
    }
}
