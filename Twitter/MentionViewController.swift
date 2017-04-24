//
//  MentionViewController.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/22/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit

class MentionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet] = []
    var replyIndex: Int?
    var detailsViewIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMentions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMentions() {
        var parameters = [String: AnyObject]()
        parameters["count"] = 20 as AnyObject
        
        TwitterClient.sharedInstance?.mentions(parameters: parameters ,success: { (tweets: [Tweet]?) in
            print("\(tweets?.count ?? 0) Number of MENTION TWEETS retrieved for user")
            
            self.tweets += tweets!
            self.tableView.reloadData()
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }

}

extension MentionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
   
}
