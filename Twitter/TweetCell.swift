//
//  TweetCell.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/15/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    
    @objc optional func TweetCell (tweetCell: TweetCell, didClickUserImage tweet: Tweet)
}


class TweetCell: UITableViewCell {
    
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tweettextLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var retweetedByLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var index: Int?
    
    internal let tapRecognizer1: UITapGestureRecognizer = UITapGestureRecognizer()
    
    var tweet: Tweet! {
        didSet {
        
            if tweet.userImageUrl != nil {
                posterImageView.setImageWith(tweet.userImageUrl!)
            }
            
            if tweet.retweetUserName == nil {
                retweetedByLabel.isHidden = true
                retweetedByLabel.bounds.size.height = 0
            } else {
                retweetedByLabel.text = tweet.retweetUserScreenName! + " Retweeted"
            }
        
            if tweet.userScreenName != nil {
                screennameLabel.text = "@" + tweet.userName!
            } else {
                screennameLabel.text = "@" + "Namrata"
            }
            
            if tweet.userName != nil {
                nameLabel.text = tweet.userScreenName!
            } else {
                nameLabel.text = "namrata_mb"
            }
            
            retweetButton.setImage(UIImage(named: "retweetSmall@1x"), for: UIControlState.normal)
            replyButton.setImage(UIImage(named: "replySmall@1x"), for: UIControlState.normal)
            favouriteButton.setImage(UIImage(named: "starSmall@1x"), for: UIControlState.normal)
            
            timeLabel.text = getTimeLabel(timeStamp: tweet.timeStamp!)
            tweettextLabel.text = tweet.text
            
        }
    }
    
    
    private func getTimeLabel(timeStamp: Date) -> String {
        let timeElaspsedInSeconds = Int(fabs((tweet.timeStamp?.timeIntervalSinceNow)!))
        let secondsIn23Hours = 23 * 60 * 60
        
        if timeElaspsedInSeconds < 3600 {
            let minutes = Int(timeElaspsedInSeconds/60)
            return "• \(minutes)m"
        }
        else if timeElaspsedInSeconds < secondsIn23Hours {
            let hours = Int(timeElaspsedInSeconds/60/60)
            return "• \(hours)h"
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            let dateString = formatter.string(from: (tweet?.timeStamp)!)
            return "• \(dateString)h"
        }
    }
    
    
    @IBAction func onReplyButtonClicked(_ sender: Any) {
        
        print("Reply button clicked")   
        
    }
    
    
    @IBAction func onRetweetButtonClicked(_ sender: Any) {
        
        print("Retweeting clicked")
        
    }
    
    
    
    @IBAction func onFavouriteButtonClicked(_ sender: Any) {
        
        print("Favourite button clicked")
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
