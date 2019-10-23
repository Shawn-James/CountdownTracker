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
    // MARK: - Properties
    var delegate: SortFilterViewControllerDelegate?
    
    var sortDelegate: SortPickerDelegate?
    var filterDelegate: FilterPickerDelegate?
    var tagDelegate: TagFilterPickerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet weak var filterPicker: UIPickerView!
    @IBOutlet weak var tagPicker: UIPickerView!
    
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
        
        // set current picker selections from current saved setting
        let sortStyle = EventController.shared.currentSortStyle
        guard let sortStyleIndex = EventController.SortStyle.allCases.firstIndex(of: sortStyle) else { return }
        let filterStyle = EventController.shared.currentFilterStyle
        guard let filterStyleIndex = EventController.FilterStyle.allCases.firstIndex(of: filterStyle) else { return }
        let currentTag = EventController.shared.currentFilterTag
        guard let currentTagIndex = EventController.shared.tags.firstIndex(of: currentTag) else { return }
        
        sortPicker.selectRow(sortStyleIndex, inComponent: 0, animated: false)
        filterPicker.selectRow(filterStyleIndex, inComponent: 0, animated: false)
        tagPicker.selectRow(currentTagIndex, inComponent: 0, animated: false)
        
        showHideFilterComponents(for: filterStyle)
    }
    
    // MARK: - Methods
    
    func showHideFilterComponents(for filterStyle: EventController.FilterStyle) {
        switch filterStyle {
        case .noLaterThanDate, .noSoonerThanDate:
            tagPicker.isHidden = true
        case .tag:
            tagPicker.isHidden = false
        case .none:
            tagPicker.isHidden = true
        }
    }

    // MARK: - Action Methods
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        let sortChoiceIndex = sortPicker.selectedRow(inComponent: 0)
        let sortChoice = EventController.SortStyle.allCases[sortChoiceIndex]
        let filterChoiceIndex = filterPicker.selectedRow(inComponent: 0)
        let filterChoice = EventController.FilterStyle.allCases[filterChoiceIndex]
        let tagChoiceIndex = tagPicker.selectedRow(inComponent: 0)
        let tagChoice = EventController.shared.tags[tagChoiceIndex]
        
        EventController.shared.currentSortStyle = sortChoice
        EventController.shared.currentFilterStyle = filterChoice
        EventController.shared.currentFilterTag = tagChoice
        EventController.shared.sort(by: sortChoice)
        
        delegate?.tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
