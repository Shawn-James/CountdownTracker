//
//  SortFilterViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

protocol SortFilterViewControllerDelegate {}

class SortFilterViewController: UIViewController {
    
    var delegate: SortFilterViewControllerDelegate?
    
    var sortDelegate: SortPickerDelegate?
    var filterDelegate: FilterPickerDelegate?
    
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortPicker.delegate = sortDelegate
        filterPicker.delegate = filterDelegate
        
        sortPicker.reloadAllComponents()
        filterPicker.reloadAllComponents()
    }

}
