//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/16/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit

@objc protocol TweetDetailViewControllerDelegate {
    @objc optional func tweetDetailViewController(tweetDetailViewController: TweetDetailViewController, tweetUpadted tweet: Tweet)
}

class TweetDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var favCountsLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetedByLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    weak var delegate: TweetDetailViewControllerDelegate?

    
    var tweet: Tweet! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tweet != nil {
            populateDetails()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateDetails() {
        posterImageView.setImageWith(tweet.userImageUrl!)
        
        if tweet?.retweetUserName == nil {
            tweetedByLabel.isHidden = true
        }
        else {
            tweetedByLabel.isHidden = false
            tweetedByLabel.text = (tweet?.retweetUserName)! + " Retweeted"
        }
        
        usernameLabel.text = tweet.userName
        screennameLabel.text = tweet.userScreenName
        
        textLabel.text = tweet.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        timeLabel.text = formatter.string(from: (tweet?.timeStamp)!)
        
        retweetCountLabel.text = String(describing: tweet.retweetCount)
        favCountsLabel.text = String(describing: tweet.favouritesCount)
        
        retweetButton.setImage(UIImage(named: "retweetSmall@1x"), for: UIControlState.normal)
        replyButton.setImage(UIImage(named: "replySmall@1x"), for: UIControlState.normal)
        favouriteButton.setImage(UIImage(named: "starSmall@1x"), for: UIControlState.normal)
        
    }
    
    
    @IBAction func onReplyButton(_ sender: Any) {
        
        print("reply clicked")
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Reply",
                                            message: "Replying....",
                                            preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter your comments"
        })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertActionStyle.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        
                                        let replyText = enteredText
                                        TwitterClient.sharedInstance?.replyToTweet(replyMsg: replyText!, tweet: (self?.tweet)!, success: { (responseTweet: Tweet) in
                                            print("Reply sent")
                                            
                                            self?.delegate?.tweetDetailViewController!(tweetDetailViewController: self!, tweetUpadted: responseTweet)
                                        }, failure: { (error: Error) in
                                            print("Error in replying in Detail VC \(error.localizedDescription)")
                                        })
                                    }
        })
        
        alertController?.addAction(action)
        present(alertController!,animated: true,completion: nil)
        
    }
    

    @IBAction func onRetweetButton(_ sender: Any) {
        print("Retweeting clicked")
        if !(tweet.didUserRetweet!) {
            TwitterClient.sharedInstance?.reTweet(tweet: tweet, success: { (responseTweet: Tweet) in
                responseTweet.didUserRetweet = true
                responseTweet.retweetCount += 1
                self.tweet = responseTweet
                self.populateDetails()
                self.delegate?.tweetDetailViewController!(tweetDetailViewController: self, tweetUpadted: self.tweet)
            }, failure: { (error: Error) in
                print("retweting error on detail vc \(error.localizedDescription)")
            })
        }
    }
    
    
    @IBAction func onFavouriteButton(_ sender: Any) {
        print("Favourite clicked")
        if !(tweet.didUserFavorite!) {
            TwitterClient.sharedInstance?.favoriteTweet(tweet: tweet, success: { (responseTweet: Tweet) in
                responseTweet.didUserFavorite = true;
                responseTweet.favouritesCount += 1
                self.tweet = responseTweet
                self.populateDetails()
                self.delegate?.tweetDetailViewController!(tweetDetailViewController: self, tweetUpadted: self.tweet)
            }, failure: { (error: Error) in
                print("Error favourite in Detail VC \(error.localizedDescription)")
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
