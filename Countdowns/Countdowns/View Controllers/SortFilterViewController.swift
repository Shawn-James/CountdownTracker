//
//  SortFilterViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class SortFilterViewController: UIViewController {
    
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sortPickerDelegate = SortPickerDelegate()
        let filterPickerDelegate = FilterPickerDelegate()
        
        sortPicker.dataSource = sortPickerDelegate
        sortPicker.delegate = sortPickerDelegate
        filterPicker.dataSource = filterPickerDelegate
        filterPicker.delegate = filterPickerDelegate
    }

}
