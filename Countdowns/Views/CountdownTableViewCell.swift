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

   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var timeRemainingLabel: UILabel!
   @IBOutlet private weak var tagsLabel: UILabel!
}
