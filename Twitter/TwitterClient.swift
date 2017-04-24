//
//  TwitterClient.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/14/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "BZsXmIiJjFGte8mJKB8Hw3kmt"
let twitterConsumerSecret = "AdWza1LOX02eTh57lImFeuA4wfigKzoCut4m0fwVi85MeW94n6"
let twitterBaseURL = "https://api.twitter.com"

class TwitterClient: BDBOAuth1SessionManager {

    static let sharedInstance = TwitterClient(baseURL: NSURL(string: twitterBaseURL) as URL!, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    /*
    func homeTimeLine(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("inside the tweets methods")
            let dictionaries = response as! [NSDictionary]
            
            let tweets = Tweet.tweetsFromArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }*/
    
    func homeTimeLine(parameters: [String: AnyObject]? ,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        get("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionariesArray = response as! [[String: AnyObject]]
            let tweets = Tweet.tweetsWithArray(dictionaryArray: dictionariesArray)
            success(tweets)
            
            print(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error?) in
            
            failure(error!)
            
        })
    }
    
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let userDictionary = response as! [String : AnyObject]
            
            let user = User(dictionary: userDictionary )
            
            success(user)
            
            print("name: \(user.name)")
            print("screen name: \(user.screenname)")
            print("profileUrl: \(user.profileUrl)")
            print("tagline: \(user.tagline)")
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance?.deauthorize()
        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "/oauth/request_token", method: "GET", callbackURL: NSURL(string: "mytwitterDemo://oauth") as URL!, scope: nil, success: {
            (requestToken: BDBOAuth1Credential?) -> Void in
            print("I got a token \(requestToken?.token)")
            
            let reqToken = requestToken!.token ?? "default"
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(reqToken)")
            UIApplication.shared.openURL(url as! URL)
            
        }) { (error: Error?) -> Void in
            print("error \(error?.localizedDescription)")
            self.loginFailure?(error!)
        }
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) -> Void in
            print("I got the access Token")
            
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
            
            self.loginSuccess?()
            
        }, failure: { (error: Error?) -> Void in
            print("error \(error?.localizedDescription)")
            self.loginFailure!(error!)
        })
    }
    
    func handleOpenUrl(url: URL, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accesToken: BDBOAuth1Credential?) in
            print("Inside handleOpenUrl with success as parameter")
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                success()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
                failure(error)
            })
            
            
        }, failure: { (error: Error?) in
            
            print("Error fetching Access Token")
            self.loginFailure?(error!)
            
        })
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)

    }
    
    
    func postNewTweet(tweetMsg: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let parameters = ["status": tweetMsg]
        
        print("tweetMsg \(parameters)")
        
        post("1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task:  URLSessionDataTask, response: Any?) in
            print("Added the new tweet")
            success(Tweet.init(dictionary: response as! [String: AnyObject]))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error adding tweet \(error) \n\n")
            failure(error)
        })
    }
    
    
    func reTweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let retweetUrlWithId = "1.1/statuses/retweet/" + tweet.id! + ".json"
        post(retweetUrlWithId, parameters: nil, progress: nil, success: { (task:  URLSessionDataTask, response: Any?) in
            print("retweeted successfully\n")
            print("\n\n")
            success(Tweet.init(dictionary: response as! [String: AnyObject]))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("\nError posting tweet1:: \(error) \n\n")
            failure(error)
        })
    }
    
    
    func favoriteTweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let parameters = ["id": tweet.id]
        post("1.1/favorites/create.json", parameters: parameters, progress: nil, success: { (task:  URLSessionDataTask, response: Any?) in
            print("tweet favorited successfully")
            success(Tweet.init(dictionary: response as! [String: AnyObject]))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("\nError favoriting tweet1:: \(error) \n\n")
            failure(error)
        })
    }
    
    func replyToTweet(replyMsg: String, tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let replyMsg = "@" + tweet.userName! + " " + replyMsg
        let parsedMsg = replyMsg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = "1.1/statuses/update.json?status=\(parsedMsg!)&" + "in_reply_to_status_id" + "=" + tweet.id!
        print(url)
        post(url, parameters: nil, progress: nil, success: { (task:  URLSessionDataTask, response: Any?) in
            print("reply posted successfully")
            success(Tweet.init(dictionary: response as! [String: AnyObject]))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("\nError favoriting tweet1:: \(error) \n\n")
            failure(error)
        })
    }
    
    func mentions(parameters: [String: AnyObject]? ,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        get("1.1/statuses/mentions_timeline.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionariesArray = response as! [[String: AnyObject]]
            let tweets = Tweet.mentionTweetsWithArray(dictionaryArray: dictionariesArray)
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error?) in
            
            failure(error!)
            
        })
    }
    
    
    func userTimeline(parameters: [String: AnyObject]? ,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        get("1.1/statuses/user_timeline.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionariesArray = response as! [[String: AnyObject]]
            let tweets = Tweet.mentionTweetsWithArray(dictionaryArray: dictionariesArray)
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error?) in
            
            failure(error!)
            
        })
    }
    
}
