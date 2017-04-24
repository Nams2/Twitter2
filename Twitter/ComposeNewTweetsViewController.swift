//
//  ComposeNewTweetsViewController.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/15/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol ComposeNewTweetsViewControllerDelegate {
    @objc optional func composeNewTweetsViewController (composeNewTweetsViewController: ComposeNewTweetsViewController, didPostTweet tweet: Tweet)
}

class ComposeNewTweetsViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet weak var tweetText: UITextField!
    
    weak var delegate: ComposeNewTweetsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tweetText.delegate = self
        tweetText.becomeFirstResponder()
        // Do any additional setup after loading the view.
        let user = User.currentUser
        
        posterImageView.setImageWith((user?.profileUrl)!)
        
        if user?.profileUrl != nil {
            posterImageView.setImageWith((user?.profileUrl)!)
        } else {
            print("profile image is nil")
        }
        
        screennameLabel.text = user?.name as String?
        usernameLabel.text = user?.name! as String?
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onTweetButton(_ sender: Any) {
        print("Tweet button is clicked \(tweetText.text)")
        
        view.endEditing(true)
        if tweetText.text!.characters.count > 0 {
            TwitterClient.sharedInstance?.postNewTweet(tweetMsg: tweetText.text!, success: { (response: Tweet) in
                print("tweeting success")
                print(response.stringifyTweet())
                self.delegate?.composeNewTweetsViewController!(composeNewTweetsViewController: self, didPostTweet: response)
                self.tweetText.text = nil
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error: Error) in
                print("Error  \(error)")
            })
        }
    }
    
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onClick(_ sender: Any) {
        view.endEditing(true)
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
