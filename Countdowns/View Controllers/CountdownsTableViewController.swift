//
//  CountdownsTableViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

protocol CountdownsViewModeling {
   var displayedEvents: [Event] { get }
   var isViewingArchive: Bool { get set }
   var currentSort: EventSort { get }
   var currentFilter: EventFilter { get }

   func sortFilterViewModel() -> SortFilterViewModeling

   func eventViewModel(
      _ event: Event,
      countdownDidEnd: @escaping (Event) -> Void)
      -> EventViewModeling
   func addViewModel(
      didCreateEvent: @escaping (Event) -> Void)
      -> AddEventViewModeling
   func detailViewModel(for event: Event) -> EventDetailViewModeling
   func editViewModel(for event: Event) -> EditEventViewModeling

   func delete(_ event: Event)
}

class CountdownsTableViewController: UITableViewController {
   var viewModel: CountdownsViewModeling!

   @IBOutlet weak var sortButton: UIBarButtonItem!
   @IBOutlet weak var archiveButton: UIBarButtonItem!
   @IBOutlet weak var currentModeLabel: UILabel!

   // MARK: - View Lifecycle

   override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
   }

   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      updateViews()
   }

   // MARK: - Table view data source

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      viewModel.displayedEvents.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(
         withIdentifier: .countdownCellReuseID,
         for: indexPath)
         as? CountdownTableViewCell else {
            preconditionFailure("Could not dequeue countdown cell")
      }
      let event = viewModel.displayedEvents[indexPath.row]

      cell.viewModel = viewModel.eventViewModel(
         event,
         countdownDidEnd: { [weak self] in
            self?.alertForCountdownEnd(for: $0)
      })

      if indexPath.row % 2 == 0 {
         cell.backgroundColor = UIColor(named: .secondaryCellBackgroundColor)
      } else {
         cell.backgroundColor = UIColor(named: .cellBackgroundColor)
      }

      return cell
   }

   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
         let event: Event = viewModel.displayedEvents[indexPath.row]
         confirmDeletion(for: event, at: indexPath)
      }
   }

   // MARK: - Navigation

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      switch segue.identifier {
      case String.addEventSegue:
         guard let addEventVC = segue.destination as? AddEditEventViewController
            else { return }

         addEventVC.viewModel = .a(viewModel.addViewModel(
            didCreateEvent: { [weak self] in self?.selectRow(for: $0) }))
      case String.editEventSegue:
         guard
            let editEventVC = segue.destination as? AddEditEventViewController,
            let idx = tableView.indexPathForSelectedRow
            else { return }
         let event = viewModel.displayedEvents[idx.row]
         editEventVC.viewModel = .b(viewModel.editViewModel(for: event))
      case String.eventDetailSegue:
         guard
            let eventDetailVC = segue.destination as? EventDetailViewController,
            let idx = tableView.indexPathForSelectedRow
            else { return }
         let event = viewModel.displayedEvents[idx.row]
         eventDetailVC.viewModel = viewModel.detailViewModel(for: event)
      case String.sortFilterSegue:
         guard let sortFilterVC = segue.destination as? SortFilterViewController
            else { return }
         sortFilterVC.viewModel = viewModel.sortFilterViewModel()
      default: break
      }
   }

   // MARK: - Private Methods

   @IBAction func archiveButtonTapped(_ sender: UIBarButtonItem) {
      viewModel.isViewingArchive.toggle()
      updateViews()
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
            self.viewModel.delete(event)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.updateViews()
      }))

      present(alert, animated: true, completion: nil)
   }

   private func alertAndArchiveFinishedCountdowns() {
      for event in viewModel.displayedEvents {
         if event.dateTimeHasPassed {
            if !event.didNotifyDone {
               alertForCountdownEnd(for: event)
            }
         }
      }
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

   // MARK: - UI Update

   /// Updates all cells (showing alerts for and removing events that have passed), reloads all table data, and colors the filter button as needed if the table is currently being filtered.
   func updateViews() {
      if let indexPath = tableView.indexPathForSelectedRow {
         tableView.deselectRow(at: indexPath, animated: true)
      }
      alertAndArchiveFinishedCountdowns()
      tableView.reloadData()
      setModeLabelAppearance()
      setBarButtonAppearances()
   }

   private func setModeLabelAppearance() {
      var text = ""
      currentModeLabel.isHidden = false

      if viewModel.isViewingArchive {
         if case .none = viewModel.currentFilter {
            text = "Viewing Archive"
         } else {
            text = "Filtering Archive"
         }
      } else {
         if case .none = viewModel.currentFilter {
            currentModeLabel.isHidden = true
         } else {
            text = "Filtering"
         }
      }

      currentModeLabel.text = text.uppercased()
   }

   private func setBarButtonAppearances() {
      if case .none = viewModel.currentFilter {
         sortButton.tintColor = .systemBlue
         sortButton.image = UIImage(systemName: .sortImageInactive)
      } else {
         sortButton.tintColor = .systemRed
         sortButton.image = UIImage(systemName: .sortImageActive)
      }

      if viewModel.isViewingArchive {
         archiveButton.tintColor = .systemRed
         archiveButton.image = UIImage(systemName: .archiveImageActive)
      } else {
         archiveButton.tintColor = .systemBlue
         archiveButton.image = UIImage(systemName: .archiveImageInactive)
      }
   }

   private func selectRow(for event: Event) {
      guard let index = viewModel.displayedEvents.firstIndex(of: event) else { return }
      let indexPath = IndexPath(row: index, section: 0)
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
   }
}
