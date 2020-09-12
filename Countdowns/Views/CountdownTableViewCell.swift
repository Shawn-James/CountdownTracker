//
//  CountdownTableViewCell.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


protocol EventViewModeling: AnyObject {
   var event: Event { get }
   var updateViewsFromEvent: ((Event) -> Void)? { get set }
}

class EventViewModel: EventViewModeling {
   private(set) var event: Event

   var updateViewsFromEvent: ((Event) -> Void)?

   private var countdownTimer: Timer

   init(_ event: Event) {
      self.event = event
   }

   private func updateTimer() {
      // if time remaining < 1 day, update in a minute
      if !amViewingArchive && event.timeInterval < 1 {
         parentViewController?.updateViews()
      } else if abs(event.timeInterval) < 3660 {
         countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: updateTimer(_:))
      } else if abs(event.timeInterval) < 86_460 {
         countdownTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: updateTimer(_:))
      }
   }
   
}


class CountdownTableViewCell: UITableViewCell {
   var viewModel: EventViewModeling? {
      didSet {
         guard let vm = viewModel else { return }

         vm.updateViewsFromEvent = { [weak self] event in
            self?.timeRemainingLabel.text = DateFormatter.formattedTimeRemaining(for: event)
         }

         // Populate subviews and set timer when event is set
         titleLabel.text = vm.event.name
         tagsLabel.text = vm.event.tagsText
      }
   }

   // MARK: - Outlets

   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var timeRemainingLabel: UILabel!
   @IBOutlet weak var tagsLabel: UILabel!

   // MARK: - Private Methods

   /// Update the 'time remaining' label based on the new timer and then update the timer.
   /// If the time is up, update the table view controller's views to show the alert and archive the event, removing this cell from view.

}
