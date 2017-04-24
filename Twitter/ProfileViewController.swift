//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/22/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit
import AFNetworking
import CoreImage

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userBackgroundImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenname: UILabel!
    @IBOutlet weak var TweetCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    //var user: User!
    
    var loadingMoreView:InfiniteScrollActivityView?
    var tweets: [Tweet] = []
    var isMoreDataLoading = false
    var currentOffset = 0
    
    
    
    var user: User! {
        didSet {
            userBackgroundImageView.setImageWith(user.profileBackgroundImageUrl!)
            userImageView.setImageWith(user.profileUrl!)
            userScreenname.text = user.screenname! as String
            userName.text = "@" + (user.name! as String)
            followersCountLabel.text = String(user.followerCount!)
            followingCountLabel.text = String(user.followingCount!)
            TweetCountLabel.text = String(user.tweetCount!)
        }
    }
 
    
    var context = CIContext(options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("inside")
        
        if user == nil {
            user = User.currentUser
        }
        getTweetsForUser(user: user)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        user = User.currentUser
        getTweetsForUser(user: user)
        currentOffset = 0
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTweetsForUser(user: User) {
        var parameters = [String: AnyObject]()
        parameters["count"] = 20 as AnyObject
        parameters["user_id"] = user.id as AnyObject
        
        TwitterClient.sharedInstance?.userTimeline(parameters: parameters ,success: { (tweets: [Tweet]?) in
            print("\(tweets?.count ?? 0) Number of tweets retrieved for user profile")
            
            self.tweets += tweets!
            self.tableView.reloadData()
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
        
    }
    
    
    func loadTweets() {
        var parameters = [String: AnyObject]()
        parameters["count"] = 20 as AnyObject
        parameters["offset"] = currentOffset as AnyObject
        
        TwitterClient.sharedInstance?.homeTimeLine(parameters: parameters ,success: { (tweets: [Tweet]?) in
            print("Tweet count \(tweets?.count ?? 0) ")
            
            self.tweets += tweets!
            self.tableView.reloadData()
            //self.refreshControl.endRefreshing()
            self.loadingMoreView!.stopAnimating()
            self.isMoreDataLoading = false
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
}


// MARK: - Navigation
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("1111111 count")
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("1111111 cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
}


extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // PULL DOWN -----------------
        if offset < 0 {
            print("1111111")
            UIView.animate(withDuration: 0.1, animations: {
                self.userBackgroundImageView.transform = CGAffineTransform(scaleX: 1.3, y: 2)
                self.userBackgroundImageView.alpha = 0.2
            })
        }
            // Scroll up
        else {
            print("2222222")
            UIView.animate(withDuration: 0.1, animations: {
                self.userBackgroundImageView.transform = CGAffineTransform.identity
                self.userBackgroundImageView.alpha = 1
            })
            
            
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if (!isMoreDataLoading) {
                if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                    isMoreDataLoading = true
                    
                    let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                    loadingMoreView?.frame = frame
                    loadingMoreView!.startAnimating()
                    currentOffset = currentOffset + 20
                    loadTweets()
                }
            }
            
        }
    }
    
    
    
}

