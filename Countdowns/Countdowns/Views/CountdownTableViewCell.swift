//
//  CountdownTableViewCell.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class CountdownTableViewCell: UITableViewCell {
    var parentViewController: CountdownsTableViewController?
    
    var timeRemainingTimer: Timer?
    
    var event: Event? {
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Private Methods
    
    private func updateTimeText() {
        guard let event = event else { return }
        timeRemainingLabel.text = DateFormatter.formattedTimeRemaining(for: event)
    }
    
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
