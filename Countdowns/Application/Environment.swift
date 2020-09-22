//
//  Environment.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-22.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit


protocol Environment {
   func countdownsDataSource(
      viewModel: CountdownsViewModeling,
      tableView: UITableView)
   -> UITableViewDataSource
   func sortDelegate(viewModel: SortFilterViewModeling) -> PickerDelegate
   func filterDelegate(viewModel: SortFilterViewModeling) -> PickerDelegate
   func tagDelegate(viewModel: SortFilterViewModeling) -> PickerDelegate
}


// MARK: - App Environment

class AppEnvironment: Environment {
   func countdownsDataSource(
      viewModel: CountdownsViewModeling,
      tableView: UITableView)
   -> UITableViewDataSource {
      CountdownsDataSource(viewModel: viewModel, tableView: tableView)
   }

   func sortDelegate(viewModel: SortFilterViewModeling) -> PickerDelegate {
      SortPickerDelegate(viewModel)
   }

   func filterDelegate(viewModel: SortFilterViewModeling) -> PickerDelegate {
      FilterPickerDelegate(viewModel)
   }

   func tagDelegate(viewModel: SortFilterViewModeling) -> PickerDelegate {
      TagFilterPickerDelegate(viewModel)
   }
}
