//
//  CountdownsTableViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


class CountdownsTableViewController: UITableViewController {
   typealias DataSource = UITableViewDiffableDataSource<Int, Event>

   lazy var viewModel: CountdownsViewModeling = CountdownsViewModel { [weak self] in
      self?.alertForCountdownEnd(for: $0)
   }
   lazy var dataSource = CountdownsDataSource(viewModel: viewModel, tableView: tableView)

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
            let idx = tableView.indexPathForSelectedRow,
            let event = dataSource.itemIdentifier(for: idx)
            else { return }

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
            do {
               try self.viewModel.delete(event)
               self.tableView.deleteRows(at: [indexPath], with: .left)
               self.updateViews()
            } catch {
               self.presentAlert(for: error)
            }
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

      // mode label
      var text = ""
      currentModeLabel.isHidden = false

      switch (viewModel.isFiltering, viewModel.isViewingArchive) {
      case (true, true):
         text = "Filtering Archive"
      case (true, false):
         text = "Filtering"
      case (false, true):
         text = "Viewing Archive"
      case (false, false):
         currentModeLabel.isHidden = true
      }
      currentModeLabel.text = text.uppercased()

      // sort/archive buttons
      sortButton.tintColor = viewModel.isFiltering ? .systemRed : .systemBlue
      sortButton.image = UIImage(systemName: viewModel.isFiltering ? .sortImageActive : .sortImageInactive)
      archiveButton.tintColor = viewModel.isViewingArchive ? .systemRed : .systemBlue
      archiveButton.image = UIImage(systemName: viewModel.isViewingArchive ? .archiveImageActive : .archiveImageInactive)
   }


   private func selectRow(for event: Event) {
      guard let index = viewModel.displayedEvents.firstIndex(of: event) else { return }
      let indexPath = IndexPath(row: index, section: 0)
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
   }
}
