//
//  CountdownTableViewCell.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class CountdownTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var parentViewController: CountdownsTableViewController?
    
    var timeRemainingTimer: Timer?
    
    var event: Event? {
        // Populate subviews and set timer when event is set
        didSet {
            guard let event = event else { return }
            
            titleLabel.text = event.name
            tagsLabel.text = event.tagsText
            if let data = event.imageData, let image = UIImage(data: data) {
                eventImage.image = image
            } else {
                eventImage.image = nil
            }
            
            updateTimeText()
            updateTimer()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    
    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Private Methods
    
    /// Update the text of the 'time remaining' label from the event data and the current time.
    private func updateTimeText() {
        guard let event = event else { return }
        timeRemainingLabel.text = DateFormatter.formattedTimeRemaining(for: event)
    }
    
    /// Update the 'time remaining' label based on the new timer and then update the timer.
    /// If the time is up, update the table view controller's views to show the alert and archive the event, removing this cell from view.
    private func updateTimer(_ timer: Timer = Timer()) {
        guard let event = event else { return }
        
        updateTimeText()
        // if time remaining < 1 day, update in a minute
        if event.timeInterval < 1 {
            parentViewController?.updateViews()
        } else if event.timeInterval < 3660 {
            timeRemainingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: updateTimer(_:))
        } else if event.timeInterval < 86_400 {
            timeRemainingTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: updateTimer(_:))
        }
    }
}
