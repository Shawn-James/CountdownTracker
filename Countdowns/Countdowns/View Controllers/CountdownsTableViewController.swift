//
//  CountdownsTableViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class CountdownsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var eventController = EventController.shared
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        reloadViews()
    }
    
    func reloadViews() {
        tableView.reloadData()
        if eventController.currentFilterStyle != .none {
            sortButton.tintColor = .systemRed
        } else {
            sortButton.tintColor = .systemBlue
        }
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventController.filteredEvents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: .countdownCellReuseID,
            for: indexPath
        ) as? CountdownTableViewCell else {
            return UITableViewCell()
        }

        cell.event = eventController.filteredEvents[indexPath.row]
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(named: .secondaryCellBackgroundColor)
        } else {
            cell.backgroundColor = UIColor(named: .cellBackgroundColor)
        }

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = eventController.filteredEvents[indexPath.row]
            confirmDeletion(for: event, at: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .addEventSegue {
            guard let addEventVC = segue.destination as? AddEditEventViewController
                else { return }
            
            addEventVC.addEventDelegate = self
            
        } else if segue.identifier == .eventDetailSegue {
            guard let eventDetailVC = segue.destination as? EventDetailViewController,
                let eventCell = sender as? CountdownTableViewCell,
                let event = eventCell.event else { return }
            
            eventDetailVC.event = event
        
        } else if segue.identifier == .sortFilterSegue {
            guard let sortFilterVC = segue.destination as? SortFilterViewController
                else { return }
            
            let sortDelegate = SortPickerDelegate()
            let filterDelegate = FilterPickerDelegate(delegate: sortFilterVC)
            let tagDelegate = TagFilterPickerDelegate()
            
            sortFilterVC.sortDelegate = sortDelegate
            sortFilterVC.filterDelegate = filterDelegate
            sortFilterVC.tagDelegate = tagDelegate
            
            sortFilterVC.delegate = self
        }
    }
    
    // MARK: - Private
    
    private func confirmDeletion(for event: Event, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete event?",
            message: "Are you sure you want to delete event \"\(event.name)\"?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { action in
                self.eventController.delete(event)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension CountdownsTableViewController: AddEventViewControllerDelegate {}
extension CountdownsTableViewController: SortFilterViewControllerDelegate {}
