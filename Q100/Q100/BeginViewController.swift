//
//  BeginViewController.swift
//  Q100
//
//  Created by Daniel Meechan on 22/07/2017.
//  Copyright © 2017 Rogue Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAnalytics

// let sharedData =

class BeginViewController: UIViewController {
  
  @IBOutlet weak var beginButton: UIButton!
  
  
  @IBAction func beginClicked(_ sender: Any) {
    beginButton.setTitle("LOADING", for: .normal)
    // DataManager.logEvent(eventName: "clickBegin")
    
    performSegue(withIdentifier: "switchToQuestionView", sender: self)
    
  }
  
  @IBAction func aboutClicked(_ sender: Any) {
    // DataManager.logEvent(eventName: "clickAbout")
    
    performSegue(withIdentifier: "switchToAboutView", sender: self)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Load from CoreData
    DataManager.shared.getData()
    
    // Check that user[0] exists first
    if DataManager.shared.users.count > 0 {
      if DataManager.shared.users[0].questionNum > 0 {
        beginButton.setTitle("CONTINUE", for: .normal)
      }
      
    }
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
