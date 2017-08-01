//
//  QuestionViewController.swift
//  Q100
//
//  Created by Daniel Meechan on 18/07/2017.
//  Copyright © 2017 Rogue Studios. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class QuestionViewController: UIViewController, UITextFieldDelegate, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {
  
  var transitionTime = 1.5
  var timer:Timer = Timer()
  
  var interstitialAd: GADInterstitial!
  
  let testingAds = false
  //let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  // MARK: Run Q100
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // NOTE: REMEMBER TO saveData() AFTER EDITING A STORED OBJECT!
    
    // DATA:
    //loadInitialData(testingData: false, resetData: false)
    
    // users[0].questionsSinceAd = 3
    // users[0].questionNum = 98
    // saveData()
    
    
    // USER INTERFACE:
    createBannerAd()
    self.answerField.delegate = self
    
    updateUI()
    
    fireTimer()
    print("Timer status: \(timer.isValid)")
    
    createRewardVideoAd()
    createInterstitialAd()
    
    DataManager.logEvent(eventName: "loadQuestionView")
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(false)
    if Int(DataManager.shared.users[0].questionNum) == DataManager.shared.questions.count {
      userHasWon()
    }
    
  }
  
  func switchToWinnerView() {
    performSegue(withIdentifier: "switchToWinnerView", sender: self)
  }
  
  func runTimer() {
    
    if Int(DataManager.shared.users[0].questionNum) == DataManager.shared.questions.count {
      // User has won, so don't try to increment timer...
      
    } else {
      DataManager.shared.questionStats[Int(DataManager.shared.users[0].questionNum)].timeTaken += 1
      let totalSecs = DataManager.shared.questionStats[Int(DataManager.shared.users[0].questionNum)].timeTaken
      
      let mins = floor(Double(totalSecs / 60))
      let secs = totalSecs % 60
      
      timerLabel.text = String(format: "%02d", Int(mins)) + ":" + String(format: "%02d", Int(secs))
      
    }
    
    
    
  }
  
  func submitGuess() {
    // Use lower-case format for guess
    let guess: String = (answerField.text?.lowercased())!
    
    // Loop through all allowed answers to see if one is correct
    
    var qNum = Int(DataManager.shared.users[0].questionNum)
    
    let correct: Bool = isGuessCorrect(guess: guess, answers: DataManager.shared.questions[qNum].answer as [String])
    
    if correct == true {
      // Guess is correct
      
      DataManager.shared.questionStats[qNum].completed = true
      DataManager.shared.users[0].questionNum += 1
      DataManager.shared.users[0].questionsSinceAd += 1
      
      qNum = Int(DataManager.shared.users[0].questionNum)
      
      setUIMode(mode: 1)
      submitButton.setTitle("Correct!", for: .normal)
      
      if qNum == 11 || qNum == 91 {
        remindToRateApp()
      }
      
      if qNum == DataManager.shared.questions.count {
        // User has completed final question so now has completed the game!
        
        if timer.isValid {
          timer.invalidate()
        }
        
        // After x seconds display winnerView
        Timer.scheduledTimer(timeInterval: transitionTime, target:self, selector: #selector(QuestionViewController.userHasWon), userInfo: nil, repeats: false)
        
        // Put them back down to qNum = 99 so after pressing ok, they're brought back to the final question
        //users[0].questionNum -= 1
        
        
      } else {
        // After x seconds, update UI for next question
        Timer.scheduledTimer(timeInterval: transitionTime, target:self, selector: #selector(QuestionViewController.updateUI), userInfo: nil, repeats: false)
        
      }
      
      // See how many questions since ad, and display video ad if needed
      if DataManager.shared.users[0].questionsSinceAd > 4 {
        if qNum == 10 || qNum == 90 {
          // Don't show ad because it'll be asking for a rating soon
          
          
        } else {
          // Display video ad
          loadInterstitialAd(1)
          
        }
        
        DataManager.shared.users[0].questionsSinceAd = 0
        
        
      }
      
      
    } else {
      // Guess is wrong
      
      DataManager.shared.questionStats[qNum].incorrectGuesses = DataManager.shared.questionStats[qNum].incorrectGuesses + 1
      
      setUIMode(mode: 2)
      submitButton.setTitle("Try again :)", for: .normal)
      
      // The change it back after x seconds
      Timer.scheduledTimer(timeInterval: transitionTime, target:self, selector: #selector (QuestionViewController.updateUI), userInfo: nil, repeats: false)
      
      //updateUI()
      
    }
    
    DataManager.shared.saveData()
    
  }
  
  func remindToRateApp() {
    
    hideKeyboard()
    timer.invalidate()
    // Hide timer until it resumes
    timerLabel.text = "           "
    
    // Create alert
    let alert = UIAlertController(title: "Enjoying the riddles?", message: "", preferredStyle: UIAlertControllerStyle.alert)
    
    // Create choices
    
    alert.addAction(UIAlertAction(title: "Yes!", style: UIAlertActionStyle.cancel, handler: { (action) in
      alert.dismiss(animated: true, completion: nil)
      
      print("USER: Enjoying the riddles: YES")
      // Create alert
      let alert2 = UIAlertController(title: "How about a rating on the App Store, then?", message: "", preferredStyle: UIAlertControllerStyle.alert)
      
      // Create choices
      
      alert2.addAction(UIAlertAction(title: "Ok, sure :)", style: UIAlertActionStyle.cancel, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
        print("USER: RATE ON APP STORE: YES")
        
        let address = "https://itunes.apple.com/app/id1262813325"
        if let appStoreURL = URL(string: address) {
          UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
        
        self.fireTimer()
        
      }))
      
      alert2.addAction(UIAlertAction(title: "No, thanks", style: UIAlertActionStyle.default, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
        print("USER: RATE ON APP STORE: NO")
        self.fireTimer()
        
      }))
      
      self.present(alert2, animated: true, completion: nil)
      
      
    }))
    
    alert.addAction(UIAlertAction(title: "Not really", style: UIAlertActionStyle.default, handler: { (action) in
      alert.dismiss(animated: true, completion: nil)
      
      print("USER: Enjoying the riddles: NO")
      // Create alert
      let alert2 = UIAlertController(title: "Would you mind giving us some feedback?", message: "We'd love to know how to do better!", preferredStyle: UIAlertControllerStyle.alert)
      
      // Create choices
      
      alert2.addAction(UIAlertAction(title: "Ok, sure", style: UIAlertActionStyle.cancel, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
        print("USER: FEEDBACK: YES")
        // Open up email dialogue for feedback
        let email = "hello@roguestudios.co"
        if let feedbackURL = URL(string: "mailto:\(email)?subject=I%20have%20feedback%20for%20100%20on%20iOS!") {
          UIApplication.shared.open(feedbackURL, options: [:], completionHandler: nil)
        }
        self.fireTimer()
        
      }))
      
      alert2.addAction(UIAlertAction(title: "Maybe later", style: UIAlertActionStyle.default, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
        print("USER: FEEDBACK: NO")
        self.fireTimer()
        
      }))
      
      self.present(alert2, animated: true, completion: nil)
      
      
      
    }))
    
    self.present(alert, animated: true, completion: nil)
    
    
  }
  
  func isGuessCorrect(guess: String, answers: [String]) -> Bool {
    
    var i = 0
    var correct: Bool = false
    
    while correct == false && i < answers.count {
      if guess == answers[i].lowercased() {
        // See if it's a 1-1 match
        correct = true
        
      } else if guess.contains(answers[i]) && answers[i].characters.count != 1 {
        // Make sure that it doesn't check if answer contains guess if answer is one letter, like 'h'
        correct = true
        
      } else if answers[i].characters.count != 1 {
        let pluralAnswer = answers[i].appending("s")
        // Opportunity here for recursion??
        
        if guess.contains(pluralAnswer) {
          correct = true
          
        }
        
      }
      
      i += 1
      
    }
    
    return correct
    
  }
  
  func userHasWon() {
    // Check that there isn't a bug which has meant there are not 100 questions to complete...
    // If so, display error message then proceed as normal...
    if DataManager.shared.users[0].questionNum != 100 {
      print("ERROR: User should now be on question number 100, but is on: ", DataManager.shared.users[0].questionNum)
      createAlert(title: "Warning: it doesn't look like you've completed all 100 questions", message: ("You currently should be on question " + String(DataManager.shared.users[0].questionNum) + ". If you think this is a bug, please email us at hello@roguestudios.co :)"), acceptanceText: "Ok, will do!")
      // TODO: Open up an email dialogue when users clicks ok
      
    }
    
    DataManager.shared.saveData()
    switchToWinnerView()
    
    
  }
  
  func useHint() {
    // Check if user has some hints left
    if DataManager.shared.users[0].hintsNum > 0 {
      let qNum = Int(DataManager.shared.users[0].questionNum)
      
      if Int(DataManager.shared.questionStats[qNum].hintsUsed) < DataManager.shared.questions[qNum].hint.count {
        // The question still has some hints left
        
        DataManager.shared.users[0].hintsNum -= 1
        DataManager.shared.questionStats[qNum].hintsUsed += 1
        
        updateUI()
        
      } else {
        // Question has no more hints left
        
        createAlert(title: "Oops, this question has no more hints left!", message: "", acceptanceText: "Ok, I'll keep trying!")
        
      }
      
    } else {
      
      // Create alert
      let alert = UIAlertController(title: "Oops, you've run out of hints!", message: "Would you like to watch an ad to unlock more now?", preferredStyle: UIAlertControllerStyle.alert)
      
      // Create choices
      
      alert.addAction(UIAlertAction(title: "Maybe later", style: UIAlertActionStyle.default, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
        // Don't watch ad
        
      }))
      
      alert.addAction(UIAlertAction(title: "Absolutely!", style: UIAlertActionStyle.cancel, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
        // Watch ad
        self.loadRewardVideoAd(1)
        
      }))
      
      self.present(alert, animated: true, completion: nil)
      
    }
    
    DataManager.shared.saveData()
    
  }
  
  func importTestQuestions() {
    if DataManager.shared.questions.count == 0 {
      DataManager.shared.addQuestion(question: "What is an apple?", answers: ["Fruit", "A fruit"], hints: ["Life", "Life 2"])
      DataManager.shared.addQuestion(question: "What is 'banana'?", answers: ["Banana"], hints: ["Frtui or vegetable?"])
      DataManager.shared.addQuestion(question: "What is a carror?", answers: ["Vegetable"], hints: ["Vegetable?", "Yes", "Absolutely."])
    }
    
  }
  
  // MARK: Google AdMob
  
  
  func getAdID (testingAds: Bool, bannerOrPostOrHint: Int) -> String {
    
    var bannerAdId: String = ""       // Banner ad
    var postQuestionAdId: String = "" // Reward video ad
    var hintRewardAdId: String = ""   // Interstitial ad
    
    if testingAds {
      // Using test ads
      bannerAdId = "ca-app-pub-3940256099942544/6300978111" // Banner ad
      postQuestionAdId = "ca-app-pub-3940256099942544/1033173712" // interstitial ad
      hintRewardAdId = "ca-app-pub-3940256099942544/1712485313" // reward video ad
      //
      
    } else {
      // Using production ads
      bannerAdId = "ca-app-pub-4605466962808569/1312347754" // Banner ad
      postQuestionAdId = "ca-app-pub-4605466962808569/2789080952" // interstitial ad
      hintRewardAdId = "ca-app-pub-4605466962808569/4265814157" // reward video ad
      
    }
    
    switch(bannerOrPostOrHint) {
    case 0:
      return bannerAdId
      
    case 1:
      return postQuestionAdId
      
    case 2:
      return hintRewardAdId
      
    default:
      print("Invalid getAdId() input: ", bannerOrPostOrHint)
      return "Invalid input!"
      
    }
    
  }
  
  func createRewardVideoAd() {
    // Start loading the ad early as possible
    // Need to set this so can get notified if user does the reward stuff
    
    GADRewardBasedVideoAd.sharedInstance().delegate = self
    
    let request = GADRequest()
    setTestDevice(request: request)
    
    GADRewardBasedVideoAd.sharedInstance().load(request,
                                                withAdUnitID: getAdID(testingAds: false, bannerOrPostOrHint: 2))
    
    print("Reward ad created")
    
  }
  
  func loadRewardVideoAd(_ attemptNum: Int) {
    if GADRewardBasedVideoAd.sharedInstance().isReady == true {
      // Just play the ad (after a 1 second delay!)
      
      if attemptNum < 2 {
        Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector (QuestionViewController.loadRewardVideoAd(_:)), userInfo: (attemptNum + 1), repeats: false)
        
      } else {
        timer.invalidate()
        print("Loaded ad. Paused timer. Current status: \(timer.isValid)")
        GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        
      }
      
      
    } else if attemptNum < 3 {
      // Can't play ad; display error and try again
      // createAlert(title: "Ad not loaded yet. Trying again in 1 second...", message: "Attempt: \(attemptNum)", acceptanceText: "Ok!")
      
      // Increment attemptNum by 1 so it wll only retry 3 times max
      Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector (QuestionViewController.loadRewardVideoAd(_:)), userInfo: (attemptNum + 1), repeats: false)
      
      print("Reward ad wasn't ready; retrying")
      
    } else {
      createAlert(title: "Unable to load ad :(", message: "Please check your internet connection", acceptanceText: "Ok!")
      print("Tried 3 times & still can't load reward ad; giving up")
      
    }
    
  }
  
  func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    // Reward video ad was closed; need to create the next one
    print("Reward based video ad is closed.")
    
    print("Reward ad closed. Firing timer.")
    fireTimer()
    print("Current timer status: \(timer.isValid)")
    createRewardVideoAd()
    
  }
  
  func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
    // Reward user for watching video ad
    DataManager.shared.users[0].hintsNum += 2
    DataManager.shared.saveData()
    updateUI()
    
    print("Reward ad complete. Firing timer.")
    fireTimer()
    print("Current timer status: \(timer.isValid)")
    
    // Now create another ad, ready for next time
    createRewardVideoAd()
  }
  
  func createInterstitialAd() {
    
    interstitialAd = GADInterstitial(adUnitID: getAdID(testingAds: false, bannerOrPostOrHint: 1))
    interstitialAd.delegate = self
    
    let request = GADRequest()
    setTestDevice(request: request)
    interstitialAd.load(request)
    
  }
  
  func loadInterstitialAd(_ attemptNum: Int) {
    if interstitialAd.isReady {
      
      if attemptNum < 2 {
        Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector (QuestionViewController.loadInterstitialAd(_:)), userInfo: (attemptNum + 1), repeats: false)
        
      } else {
        interstitialAd.present(fromRootViewController: self)
        
      }
      
      timer.invalidate()
      
    } else if attemptNum < 3 {
      // Can't play ad; display error and try again
      // createAlert(title: "Ad not loaded yet. Trying again in 1 second...", message: "Attempt: \(attemptNum)", acceptanceText: "Ok!")
      
      Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector (QuestionViewController.loadInterstitialAd(_:)), userInfo: (attemptNum + 1), repeats: false)
      
      print("Interstitial ad wasn't ready; retrying")
      
    } else {
      // createAlert(title: "Unable to load ad :(", message: "Please check your internet connection", acceptanceText: "Ok!")
      print("Tried 3 times & still can't load interstitial ad; giving up")
      print("User doesn't have an internet connection")
      
    }
    
  }
  
  func interstitialDidDismissScreen(_ ad: GADInterstitial) {
    // User has seen and closed ad
    
    // users[0].hintsNum += 5
    fireTimer()
    
    DataManager.shared.saveData()
    updateUI()
    
    // Create another interstitial ad, ready for next time
    createInterstitialAd()
    
    print("User received interstitial ad")
  }
  
  
  func setTestDevice(request: GADRequest) {
    
    if testingAds {
      request.testDevices = [ kGADSimulatorID,  // All simulators
        "a97f268c2e35184ca641fac156d63884" ];   // Device ID - iPhone 5S White
    }
    
    
  }
  
  func createBannerAd() {
    print("Initializing banner ad")
    // bannerView.delegate = self
    //bannerAdView = GADBannerView(adSize: kGADAdSizeBanner)
    
    bannerAdView.adUnitID = getAdID(testingAds: false, bannerOrPostOrHint: 0)
    bannerAdView.rootViewController = self
    
    loadBannerAd()
    // setTestDevice()
    
  }
  
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    // Only show add if an ad has actually been loaded
    print("Ad loaded")
    self.view.addSubview(bannerView)
    
    // Fade in the ad
    bannerView.alpha = 0
    UIView.animate(withDuration: 1, animations: {
      bannerView.alpha = 1
    })
    
  }
  
  func loadBannerAd() {
    let request = GADRequest()
    setTestDevice(request: request)
    bannerAdView.load(request)
  }
  
  // MARK: User interface
  
  func updateUI() {
    var qNum = Int(DataManager.shared.users[0].questionNum)
    
    if qNum == DataManager.shared.questions.count {
      // User has completed final question so now has completed the game!
      print("User has completed the game!")
      
      if timer.isValid {
        timer.invalidate()
      }
      
      userHasWon()
      submitButton.alpha = 0
      hintButton.alpha = 0
      
      // Emulate it being the final question in the game
      // So bring them down to question 99
      qNum -= 1
      
    }
    
    // Update question num count to current question num
    questionNumLabel.text = "\(qNum + 1) / 100"
    
    // Update question text
    questionLabel.text = DataManager.shared.questions[qNum].question
    
    // Clear answer field
    answerField.text = ""
    
    hideKeyboard()
    
    // Hide keyboard: done
    
    // Update hint button's hint counter text
    hintButton.setTitle("Hints: \(DataManager.shared.users[0].hintsNum)", for: .normal)
    
    // Update submit button
    submitButton.setTitle("SUBMIT", for: .normal)
    
    // Clear hint txt and then append hints on the end if user has used any
    hintLabel.text = ""
    
    if DataManager.shared.questionStats[qNum].hintsUsed > 0 {
      var i = 0
      
      // let hintsUsed = Int(questionStats[qNum].hintsUsed)
      // print("Hints used: ", hintsUsed)
      
      while i < Int(DataManager.shared.questionStats[qNum].hintsUsed) {
        // let hint = questions[qNum].hint[i] as String
        // print("Hint: ", hint)
        
        hintLabel.text?.append(DataManager.shared.questions[qNum].hint[i] as String)
        //hintLabel.text?.append("\n")
        hintLabel.text?.append(" ")
        i += 1
        
      }
      
    }
    
    setUIMode(mode: 0)
    
  }
  
  // Start Editing The Text Field
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.becomeFirstResponder()
    //moveTextField(textField, moveDistance: -100, up: true)
  }
  
  // Finish Editing The Text Field
  func textFieldDidEndEditing(_ textField: UITextField) {
    hideKeyboard()
    //moveTextField(textField, moveDistance: -100, up: false)
  }
  
  // Hide the keyboard when the return key pressed
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    submitGuess()
    self.view.endEditing(true)
    textField.resignFirstResponder()
    return false
  }
  
  func hideKeyboard() {
    self.view.endEditing(true)
    answerField.resignFirstResponder()
  }
  
  func fireTimer() {
    if timer.isValid {
      timer.invalidate()
    }
    
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(QuestionViewController.runTimer), userInfo: nil, repeats: true)
  }
  
  // Move the text field in a pretty animation!
  func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
    let moveDuration = 0.3
    let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
    
    UIView.beginAnimations("animateTextField", context: nil)
    UIView.setAnimationBeginsFromCurrentState(true)
    UIView.setAnimationDuration(moveDuration)
    self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
    UIView.commitAnimations()
  }
  
  
  func setUIMode(mode: Int) {
    // 0 = default
    // 1 = correct
    // 2 = incorrect
    
    if mode == 0 {
      
      // Answer field: midnight blue
      answerField.backgroundColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.0)
      
      // Background colour: wet asphalt
      self.view.backgroundColor = UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.0)
      
      
    } else if mode == 1 {
      
      // Answer field: silver
      answerField.backgroundColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0)
      
      // Background colour: clouds
      self.view.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0)
      
    } else if mode == 2 {
      
      // Tall poppy
      answerField.backgroundColor = UIColor(red:0.75, green:0.22, blue:0.17, alpha:1.0)
      
      // Old brick
      self.view.backgroundColor = UIColor(red:0.59, green:0.16, blue:0.11, alpha:1.0)
      
    }
    
  }
  
  // MARK: Alerts
  
  func createAlert(title: String, message: String, acceptanceText: String) {
    // Create alert
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    alert.addAction(UIAlertAction(title: acceptanceText, style: UIAlertActionStyle.default, handler: { (action) in
      alert.dismiss(animated: true, completion: nil)
      
    }))
    
    self.present(alert, animated: true, completion: nil)
    
  }
  
  func createChoiceAlert(title: String, message: String, choiceYes: String, choiceNo: String) -> Bool {
    // Create alert
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    var result = true
    
    // Create choices
    
    alert.addAction(UIAlertAction(title: choiceNo, style: UIAlertActionStyle.default, handler: { (action) in
      alert.dismiss(animated: true, completion: nil)
      result = false
      print("Result is false!!!")
      
    }))
    
    alert.addAction(UIAlertAction(title: choiceYes, style: UIAlertActionStyle.cancel, handler: { (action) in
      alert.dismiss(animated: true, completion: nil)
      result = true
      print("Result is true!!!")
      
    }))
    
    self.present(alert, animated: true, completion: nil)
    
    print("CHOICE RESULT IS: ", result)
    
    return result
    
  }
  
  // MARK: - Extra functions and variables
  
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBOutlet weak var questionNumLabel: UILabel!
  @IBOutlet weak var timerLabel: UILabel!
  
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var hintButton: UIButton!
  @IBOutlet weak var answerField: UITextField!
  
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var hintLabel: UILabel!
  
  @IBOutlet weak var bannerAdView: GADBannerView!
  
  @IBAction func backBtnClicked(_ sender: Any) {
    // Save data!
    DataManager.shared.saveData()
    
    // Stop timer
    if timer.isValid {
      timer.invalidate()
    }
    // DataManager.logEvent(eventName: "clickBack")
    
  }
  

  
  
  @IBAction func hintBtnClicked(_ sender: Any) {
    hideKeyboard()
    useHint()
    DataManager.shared.saveData()
    DataManager.logEvent(eventName: "clickHint")
    
  }
  
  @IBAction func submitBtnClicked(_ sender: Any) {
    hideKeyboard()
    
    submitGuess()
    DataManager.shared.saveData()
    DataManager.logEvent(eventName: "clickSubmit")
    print("User questions left: \(DataManager.shared.users[0].questionsSinceAd)")
    
  }
  
  
}
