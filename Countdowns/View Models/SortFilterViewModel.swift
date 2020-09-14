//
//  SortFilterViewModel.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-13.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


class SortFilterViewModel: SortFilterViewModeling {
   var tags: [Tag] { (try? controller.fetchTags(.all)) ?? [] }

   var currentSort: EventSortDescriptor {
      get { controller.currentSortStyle }
      set {
         controller.currentSortStyle = newValue
         didChange?()
      }
   }
   var currentFilter: EventFilterDescriptor {
      get { controller.currentFilter }
      set {
         controller.currentFilter = newValue
         didChange?()
      }
   }

   var didChange: (() -> Void)?
   var didFinish: (() -> Void)?

   private let controller: EventController

   init(_ controller: EventController) {
      self.controller = controller
   }
}
