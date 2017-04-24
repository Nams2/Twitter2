//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/14/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
        
    var tweets: [Tweet] = []
    
    var loadingMoreView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var currentOffset = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        currentOffset = 0
        loadTweets()
        
        refreshControl.addTarget(self, action: #selector(TweetsViewController.loadTweets), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    
    
    func loadTweets() {
        var parameters = [String: AnyObject]()
        parameters["count"] = 20 as AnyObject
        parameters["offset"] = currentOffset as AnyObject
        
        TwitterClient.sharedInstance?.homeTimeLine(parameters: parameters ,success: { (tweets: [Tweet]?) in
            print("Tweet count \(tweets?.count ?? 0) ")
            
            self.tweets += tweets!
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.loadingMoreView!.stopAnimating()
            self.isMoreDataLoading = false
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "newTweetsSegue" {
            let uiNavigationController = segue.destination as! UINavigationController
            let composeNewTweetsViewController = uiNavigationController.topViewController as! ComposeNewTweetsViewController
            composeNewTweetsViewController.delegate = self
        } else if segue.identifier == "detailSegue" {
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPath(for: cell)
            let tweet = tweets[indexPath!.row]
                        
            let detailViewController = segue.destination as! TweetDetailViewController
            detailViewController.tweet = tweet
        }
        
    }
    

}


extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("counts is \(tweets.count)")
        return tweets.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
        
    }
}

extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("inside the scrollView method")

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


extension TweetsViewController: ComposeNewTweetsViewControllerDelegate {
    
    func composeNewTweetsViewController (composeNewTweetsViewController: ComposeNewTweetsViewController, didPostTweet tweet: Tweet) {
        tweets.insert(tweet, at: 0)
        tableView.reloadData()
    }
    
}








