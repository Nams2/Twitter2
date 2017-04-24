//
//  MenuViewController.swift
//  Twitter
//
//  Created by Namrata Mehta on 4/22/17.
//  Copyright © 2017 Namrata Mehta. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!
    
    private var profileViewController: UIViewController!
    private var homeTimeLineViewController: UIViewController!
    private var mentionsViewController: UIViewController!
    private var accountViewController: UIViewController!
    let menuLabels = ["Profile", "TimeLine", "Mentions", "Accounts"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController")
        homeTimeLineViewController = storyBoard.instantiateViewController(withIdentifier:
            "HomeTimeLineViewController")
        mentionsViewController = storyBoard.instantiateViewController(withIdentifier: "MentionsViewController")
        
        viewControllers.append(profileViewController)
        viewControllers.append(homeTimeLineViewController)
        viewControllers.append(mentionsViewController)
        viewControllers.append(mentionsViewController)
        hamburgerViewController.contentViewController = viewControllers[1]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


extension MenuViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        cell.menuLabel.text = menuLabels[indexPath.row]
        print("setting row at indexpath \(indexPath.row)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
}
