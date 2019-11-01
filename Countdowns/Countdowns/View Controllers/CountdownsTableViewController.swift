//
//  CountdownsTableViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class CountdownsTableViewController: UITableViewController {
    
    enum ViewMode {
        case activeUnfiltered
        case activeFiltered
        case archiveUnfiltered
        case archiveFiltered
    }
    
    // MARK: - Properties
    
    var eventController = EventController.shared
    
    var displayedEvents: [Event] = EventController.shared.activeEvents
    
    var amViewingArchive: Bool = false
    var currentSortStyle: EventController.SortStyle = .soonToLate
    var currentFilterStyle: EventController.FilterStyle = .none
    var currentFilterTag: Tag = ""
    var currentFilterDate: Date = Date()
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var archiveButton: UIBarButtonItem!
    @IBOutlet weak var currentModeLabel: UILabel!
    
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
        sortAndFilter()
        for event in displayedEvents {
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
            currentModeLabel.text = "Filtering"
            currentModeLabel.isHidden = false
        } else {
            sortButton.tintColor = .systemBlue
            sortButton.image = UIImage(systemName: .sortImageInactive)
            currentModeLabel.isHidden = true
        }
        
        if amViewingArchive {
            archiveButton.tintColor = .systemRed
            archiveButton.image = UIImage(systemName: .archiveImageActive)
            if eventController.currentFilterStyle != .none {
                currentModeLabel.text = "Filtering Archive"
            } else {
                currentModeLabel.text = "Viewing Archive"
            }
            currentModeLabel.isHidden = false
        } else {
            archiveButton.tintColor = .systemBlue
            archiveButton.image = UIImage(systemName: .archiveImageInactive)
            if eventController.currentFilterStyle == .none {
                currentModeLabel.isHidden = true
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedEvents.count
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
            let event: Event = displayedEvents[indexPath.row]
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
    
    private func sortAndFilter() {
        var eventsToSortFilter: [Event]
        if amViewingArchive {
            eventsToSortFilter = EventController.shared.archivedEvents
        } else {
            eventsToSortFilter = EventController.shared.activeEvents
        }
        
        eventsToSortFilter = EventController.shared.sort(
            eventsToSortFilter,
            by: currentSortStyle
        )
        eventsToSortFilter = EventController.shared.filter(
            eventsToSortFilter,
            by: currentFilterStyle,
            with: (date: currentFilterDate, tag: currentFilterTag)
        )
        
        displayedEvents = eventsToSortFilter
    }
    
    /// Colors cells in alternating pattern (adaptive based on whether in light or dark mode).
    private func updateCellData(for cell: CountdownTableViewCell, at indexRow: Int) {
        cell.event = displayedEvents[indexRow]
        
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

// MARK: - Delegate Adherences

extension CountdownsTableViewController: AddEventViewControllerDelegate {}
extension CountdownsTableViewController: SortFilterViewControllerDelegate {}
