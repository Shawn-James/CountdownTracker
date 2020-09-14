//
//  CountdownsDataSource.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-13.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import CoreData


class CountdownsDataSource: UITableViewDiffableDataSource<Int, Event> {
   typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Event>
   
   /// Closure determines whether provided event should be deleted.
   /// If closure is nil, event will be deleted.
   var didConfirmDelete: ((Event) -> Bool)?

   var viewModel: CountdownsViewModeling

   init(viewModel: CountdownsViewModeling, tableView: UITableView) {
      self.viewModel = viewModel

      super.init(tableView: tableView) { tv, idx, event -> UITableViewCell? in
         let cell = tv.dequeueReusableCell(
            withIdentifier: .countdownCellReuseID,
            for: idx
            ) as? CountdownTableViewCell
         cell?.configure(with: viewModel.eventViewModel(event), indexPath: idx)
         return cell
      }
      self.viewModel.delegate = self
   }

   func updateSnapshot() {
      var snapshot = Snapshot()
      snapshot.appendSections([0])
      snapshot.appendItems(viewModel.displayedEvents)
      apply(snapshot)
   }

   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      true
   }

   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      switch editingStyle {
      case .delete:
         guard let event = itemIdentifier(for: indexPath) else {
            return NSLog("attempted to delete event at improper index path")
         }
         do {
            try viewModel.delete(event)
         } catch {
            NSLog("Error while attempting to delete event '\(event.name)' (\(event.uuid)): \(error)")
         }
      default:
         break
      }
   }
}

extension CountdownsDataSource: NSFetchedResultsControllerDelegate, FetchDelegate {
   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      updateSnapshot()
   }
}

