//
//  AboutViewController.swift
//  Q100
//
//  Created by Daniel Meechan on 27/07/2017.
//  Copyright © 2017 Rogue Studios. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

  @IBOutlet weak var versionNumLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      setupUI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  func setupUI() {
    let version = getVersion()
    if version != "" {
      versionNumLabel.text = "v\(version)"
    } else {
      versionNumLabel.text = ""
    }
    
    
  }
  
  
  func getVersion() -> String {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      return version
    } else {
      return ""
    }
  }
    
    func clickBug() {
      let email = "hello@roguestudios.co"
      if let bugReportURL = URL(string: "mailto:\(email)?subject=I%20found%20a%20bug%20on%20100%20iOS!%20-%20v\(getVersion())") {
        UIApplication.shared.open(bugReportURL, options: [:], completionHandler: nil)
      }
    
    }
    
    func clickFeedback() {
        let email = "hello@roguestudios.co"
        if let feedbackURL = URL(string: "mailto:\(email)?subject=I%20have%20feedback%20for%20100%20iOS!%20-%20v\(getVersion())") {
            UIApplication.shared.open(feedbackURL, options: [:], completionHandler: nil)
        }
    }
    
    func clickWebsite() {
        let website = "https://roguestudios.co"
        if let websiteURL = URL(string: website) {
            UIApplication.shared.open(websiteURL, options: [:], completionHandler: nil)
        }
    }
    
    func clickTwitter() {
        let twitter = "https://twitter.com/RogueStudiosCo"
        if let twitterURL = URL(string: twitter) {
            UIApplication.shared.open(twitterURL, options: [:], completionHandler: nil)
        }

    }
    
    
    @IBAction func clickBugButton(_ sender: Any) {
        clickBug()
    }
    
    @IBAction func clickBugText(_ sender: Any) {
        clickBug()
    }

    @IBAction func clickFeedbackButton(_ sender: Any) {
        clickFeedback()
    }
    @IBAction func clickFeedbackText(_ sender: Any) {
        clickFeedback()
    }

    @IBAction func clickWebsiteButton(_ sender: Any) {
        clickWebsite()
    }
    @IBAction func clickWebsiteText(_ sender: Any) {
        clickWebsite()
    }
  
    @IBAction func clickTwitterButton(_ sender: Any) {
        clickTwitter()
    }
    
    @IBAction func clickTwitterText(_ sender: Any) {
        clickTwitter()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  // Report a bug, send feedback, our website, follow us on twitter

}
