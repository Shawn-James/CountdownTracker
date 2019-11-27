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
    
    var displayedEvents: [Event] = EventController.shared.activeEvents
    var amViewingArchive: Bool = false
    
    var currentSortStyle: EventController.SortStyle = .soonToLate {
        didSet {
            EventController.shared.currentSortStyle = self.currentSortStyle
        }
    }
    var currentFilterStyle: EventController.FilterStyle = .none {
        didSet {
            EventController.shared.currentFilterStyle = self.currentFilterStyle
        }
    }
    var currentFilterTag: Tag = "" {
        didSet {
            EventController.shared.currentFilterTag = self.currentFilterTag
        }
    }
    var currentFilterDate: Date = Date() {
        didSet {
            EventController.shared.currentFilterDate = self.currentFilterDate
        }
    }
    
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
        
        cell.event = displayedEvents[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(named: .secondaryCellBackgroundColor)
        } else {
            cell.backgroundColor = UIColor(named: .cellBackgroundColor)
        }
        
        cell.parentViewController = self

        return cell
    }

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
            
            sortFilterVC.sortDelegate = SortPickerDelegate()
            sortFilterVC.filterDelegate = FilterPickerDelegate(delegate: sortFilterVC)
            sortFilterVC.tagDelegate = TagFilterPickerDelegate()
            
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
                EventController.shared.delete(event)
                self.displayedEvents.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                self.updateViews()
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
    
    // MARK: - Scene Appearance
    
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
                }
                if !amViewingArchive {
                    EventController.shared.archive(event)
                }
            }
        }
        
        tableView.reloadData()
        setModeLabelAppearance()
        setBarButtonAppearances()
    }
    
    private func setModeLabelAppearance() {
        var text = ""
        currentModeLabel.isHidden = false
        
        if amViewingArchive {
            if currentFilterStyle == .none {
                text = "Viewing Archive"
            } else {
                text = "Filtering Archive"
            }
        } else {
            if currentFilterStyle == .none {
                currentModeLabel.isHidden = true
            } else {
                text = "Filtering"
            }
        }
        
        text = text.uppercased()
        currentModeLabel.text = text
    }
    
    private func setBarButtonAppearances() {
        if EventController.shared.currentFilterStyle != .none {
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
}



// MARK: - Delegate Adherences

extension CountdownsTableViewController: AddEventViewControllerDelegate {
    func selectRow(for event: Event) {
        // get index of event in list
        guard let index = displayedEvents.firstIndex(of: event) else { return }
        // make indexPath from index
        let indexPath = IndexPath(row: index, section: 0)
        // select row from indexPath
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
    }
}
extension CountdownsTableViewController: SortFilterViewControllerDelegate {}
