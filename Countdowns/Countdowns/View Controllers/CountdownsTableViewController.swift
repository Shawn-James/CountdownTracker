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
    var amViewingArchive: Bool = false
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var archiveButton: UIBarButtonItem!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateViews()
    }
    
    /// Updates all cells (showing alerts for and removing events that have passed), reloads all table data, and colors the filter button as needed if the table is currently being filtered.
    func updateViews() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        for event in eventController.events {
            if event.dateTimeHasPassed {
                if !event.didNotifyDone {
                    alertForCountdownEnd(for: event)
                    eventController.archive(event)
                } else {
                    eventController.archive(event)
                }
            }
        }
        
        tableView.reloadData()
        
        if eventController.currentFilterStyle != .none {
            sortButton.tintColor = .systemRed
            sortButton.image = UIImage(systemName: .sortImageActive)
        } else {
            sortButton.tintColor = .systemBlue
            sortButton.image = UIImage(systemName: .sortImageInactive)
        }
        
        if amViewingArchive {
            archiveButton.tintColor = .systemRed
            archiveButton.image = UIImage(systemName: .archiveImageActive)
        } else {
            archiveButton.tintColor = .systemBlue
            archiveButton.image = UIImage(systemName: .archiveImageInactive)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if amViewingArchive {
            return eventController.archivedEvents.count
        } else {
            return eventController.filteredEvents.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: .countdownCellReuseID,
            for: indexPath
        ) as? CountdownTableViewCell else {
            return UITableViewCell()
        }

        updateCellData(for: cell, at: indexPath.row)

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event: Event
            if amViewingArchive {
                event = eventController.archivedEvents[indexPath.row]
            } else {
                event = eventController.filteredEvents[indexPath.row]
            }
            confirmDeletion(for: event, at: indexPath)
        }
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
    
    // MARK: - Private Methods
    
    @IBAction func archiveButtonTapped(_ sender: UIBarButtonItem) {
        amViewingArchive.toggle()
        updateViews()
    }
    
    
    /// Colors cells in alternating pattern (adaptive based on whether in light or dark mode).
    private func updateCellData(for cell: CountdownTableViewCell, at indexRow: Int) {
        if amViewingArchive {
            cell.event = eventController.archivedEvents[indexRow]
        } else {
            cell.event = eventController.filteredEvents[indexRow]
        }
        
        if indexRow % 2 == 0 {
            cell.backgroundColor = UIColor(named: .secondaryCellBackgroundColor)
        } else {
            cell.backgroundColor = UIColor(named: .cellBackgroundColor)
        }
        
        cell.parentViewController = self
    }
    
    /// Shows an alert that asks for user confirmation to delete the given event.
    private func confirmDeletion(for event: Event, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete event?",
            message: "Are you sure you want to delete event \"\(event.name)\"? This cannot be undone.",
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
    
    /// Lets the user know that the countdown has ended.
    private func alertForCountdownEnd(for event: Event) {
        let alert = UIAlertController(
            title: .countdownEndedNotificationTitle,
            message: .countdownEndedNotificationBody(for: event),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { alert in
            event.didNotifyDone = true
        })
        
        present(alert, animated: true, completion: nil)
    }
}

extension CountdownsTableViewController: AddEventViewControllerDelegate {}
extension CountdownsTableViewController: SortFilterViewControllerDelegate {}
