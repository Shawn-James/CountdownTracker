//
//  CountdownTableViewCell.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class CountdownTableViewCell: UITableViewCell {
    var event: Event? {
        didSet {
            guard let event = event else { return }
            
            titleLabel.text = event.name
            timeRemainingLabel.text = DateFormatter.formattedTimeRemaining(for: event)
            if let data = event.imageData, let image = UIImage(data: data) {
                eventImage.image = image
            }
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    
    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
