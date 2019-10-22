//
//  SortFilterViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

protocol SortFilterViewControllerDelegate: UITableViewController {}

class SortFilterViewController: UIViewController {
    
    var delegate: SortFilterViewControllerDelegate?
    
    var sortDelegate: SortPickerDelegate?
    var filterDelegate: FilterPickerDelegate?
    
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set picker delegates & reload data
        sortPicker.delegate = sortDelegate
        filterPicker.delegate = filterDelegate
        sortPicker.reloadAllComponents()
        filterPicker.reloadAllComponents()
        
        // set current picker selections from current saved setting
        let sortStyle = EventController.shared.currentSortingStyle
        guard let sortStyleIndex = EventController.SortingStyle.allCases.firstIndex(of: sortStyle) else { return }
        let filterStyle = EventController.shared.currentFilterStyle
        guard let filterStyleIndex = EventController.FilterStyle.allCases.firstIndex(of: filterStyle) else { return }
        
        sortPicker.selectRow(sortStyleIndex, inComponent: 0, animated: false)
        filterPicker.selectRow(filterStyleIndex, inComponent: 0, animated: false)
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        let sortChoiceIndex = sortPicker.selectedRow(inComponent: 0)
        let sortChoice = EventController.SortingStyle.allCases[sortChoiceIndex]
        let filterChoiceIndex = filterPicker.selectedRow(inComponent: 0)
        let filterChoice = EventController.FilterStyle.allCases[filterChoiceIndex]
        
        EventController.shared.sort(by: sortChoice)
        // filter method here
        EventController.shared.currentSortingStyle = sortChoice
        EventController.shared.currentFilterStyle = filterChoice
        
        delegate?.tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}
