//
//  DataManager.swift
//  Q100
//
//  Created by Daniel Meechan on 28/07/2017.
//  Copyright © 2017 Rogue Studios. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataManager {

  // properties
  
  static let shared = DataManager(resetData: false)
  
  let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  var users:[User] = []
  var questionStats:[QuestionStat] = []
  var questions:[Question] = []
  
  // initialization
  
  init(resetData: Bool) {
    getData()
    
    if resetData {
      print("RESET DATA")
      // Wipe all user and question data
      clearAllStorage()
      saveData()
      
    }
    
    if users.count == 0 {
      print("USERS IS EMPTY - CREATING NEW USER")
      addUser()
      saveData()
      
    }
    
    // Check if the buildNum has been created or not...
    if let _:String = users[0].buildNum {
      // It exists so it's fine
      print("Build: ", users[0].buildNum ?? "0")
      
    } else {
      // It doesn't. Let's do this.
      users[0].buildNum = "2"
      
    }
    
      
    if isNewBuild() || questions.count != 100 {
      users[0].buildNum = getBuildNumber()
      print("RESET QUESTIONS")
      
      clearStorage(storageArray: questions)
      importQuestionData()
    }
    
    saveData()
    
    print("BUILD: \(users[0].buildNum ?? "0")")
    
    
    // Make sure there are equal number of questionStats to questions
    if questionStats.count != questions.count {
      print("UPDATING QUESTION STATS")
      var i = questionStats.count
      while i < questions.count {
        addQuestionStat()
        i += 1
      }
    }
    
    // users[0].questionNum = 9
    
    saveData()
    
    print("User count: \(users.count)")
    print("Listing users...")
    listUsers()
    
  }
  
  func getData() {
    do {
      users = try managedObjectContext.fetch(User.fetchRequest())
      questionStats = try managedObjectContext.fetch(QuestionStat.fetchRequest())
      questions = try managedObjectContext.fetch(Question.fetchRequest())
    } catch {
      print("Failed to fetch users")
    }
  }
  
  func saveData() {
    do {
      try self.managedObjectContext.save()
    } catch {
      print("Error, could not save: \(error.localizedDescription)")
    }
    getData()
  }
  
  func deleteData(object: NSManagedObject) {
    managedObjectContext.delete(object)
    saveData()
  }
  
  func clearStorage(storageArray: [Any]) {
    var i = 0
    while i < storageArray.count {
      deleteData(object: storageArray[i] as! NSManagedObject)
      i += 1
    }
    
    saveData()
    
    if let _:[User] = storageArray as? [User] {
      print("Clearing all users")
      if users.count > 0 {
        print("User 0 still exists... resetting values")
        users[0].hintsNum = 3
        users[0].questionNum = 0
        users[0].questionsSinceAd = 0
        users[0].startDate = Date() as NSDate
        
        saveData()
        
      }
    }
  }
  
  func clearAllStorage() {
    clearStorage(storageArray: users)
    clearStorage(storageArray: questions)
    clearStorage(storageArray: questionStats)
    saveData()
  }
  
  func listQuestions() {
    for qu in questions {
      print("Question: \(String(describing: questions.index(of: qu))): ")
      print("  num: ", qu.number)
      print("  question: ", qu.question)
      for ans in qu.answer {
        print("  answer: ", ans)
      }
      for hin in qu.hint {
        print("  hint: ", hin)
      }
      
    }
  }
  
  func addQuestion(question: String, answers: [String], hints: [String]) {
    let qu = Question(context: managedObjectContext)
    
    qu.number = Int16(questions.count)
    qu.question = question
    
    for answer in answers {
      qu.answer.append(answer as NSString)
    }
    
    for hint in hints {
      qu.hint.append(hint as NSString)
    }
    
    questions.append(qu)
    saveData()
    
  }
  
  func listQuestionStats() {
    for qStat in questionStats {
      print("QStat: \(String(describing: questionStats.index(of: qStat))): ")
      print("  num: ", qStat.number)
      print("  completed: ", qStat.completed)
      print("  badGuesses: ", qStat.incorrectGuesses)
      print("  hintsUsed: ", qStat.hintsUsed)
      print("  timeTaken: ", qStat.timeTaken)
    }
  }
  
  func addQuestionStat(number: Int, completed: Bool, incorrectGuesses: Int, hintsUsed: Int, timeTaken: Int) {
    let qStat = QuestionStat(context: managedObjectContext)
    
    qStat.number = Int16(number)
    qStat.completed = completed
    qStat.incorrectGuesses = Int16(incorrectGuesses)
    qStat.hintsUsed = Int16(hintsUsed)
    qStat.timeTaken = Int32(timeTaken)
    
    questionStats.append(qStat)
    saveData()
    
  }
  
  func addQuestionStat() {
    addQuestionStat(number: questionStats.count, completed: false, incorrectGuesses: 0, hintsUsed: 0, timeTaken: 0)
  }
  
  func listUsers() {
    for user in users {
      print("User \(String(describing: users.index(of: user))): ")
      print("  num: ", user.questionNum)
      print("  date: ", user.startDate!)
      print("  hintsNum: ", user.hintsNum)
      print("  sinceAd: ", user.questionsSinceAd)
      print("  build: ", user.buildNum ?? "0")
      
      
    }
  }
  
  func addUser(questionNum: Int, startDate: Date, hintsNum: Int, questionsSinceAd: Int, buildNum: String) {
    let user = User(context: managedObjectContext)
    
    user.questionNum = Int16(questionNum)
    user.startDate = startDate as NSDate
    user.hintsNum = Int16(hintsNum)
    user.questionsSinceAd = Int16(questionsSinceAd)
    user.buildNum = buildNum
    
    // Add the created user to the users array
    
    users.append(user)
    saveData()
    
  }
  
  func addUser() {
    addUser(questionNum: 0, startDate: Date(), hintsNum: 10, questionsSinceAd: 0, buildNum: getBuildNumber())
    // self.hintsUnlockable = true
    
  }
  
  func listAllData() {
    print(" ---> START <--- ")
    print(" -> List users <- ")
    listUsers()
    print(" -> List questions <- ")
    listQuestions()
    print(" -> List questionStats <- ")
    listQuestionStats()
    print(" ---> END <--- ")
    
  }
  
  func isNewBuild() -> Bool {
    let current = Int(getBuildNumber())
    let previous = Int(users[0].buildNum!)
    
    if current! > previous! {
      // It's a new build
      
    } else {
      return false
      
    }
    
    return true
    
    
  }
  
  func getBuildNumber() -> String {
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      return build
    } else {
      return ""
    }
    
  }
  
  func importQuestionData() {
    if questions.count == 0 {
      addQuestion(question: "What gets wetter the more it dries?", answers: ["towel", "cloth", "flannel"], hints: ["Drying can be done in multiple ways.", "Some things are designed for drying."])
      addQuestion(question: "You see me in the water but I never get wet. What am I?", answers: ["reflection"], hints: ["I often look familiar.", "You can see me but you can't touch me."])
      addQuestion(question: "Which word does not belong in the following list: Stop, cop, mop, shop or crop?", answers: ["or"], hints: ["Read it very carefully.", "Think outside the box."])
      addQuestion(question: "What has feet and legs but nothing else?", answers: ["stockings", "tights"], hints: ["You can wear them.", "Some people put a type of these out at Christmas."])
      addQuestion(question: "What has holes but holds water?", answers: ["sponge"], hints: ["Think of materials.", "Often found near sinks."])
      addQuestion(question: "What has no beginning, end or middle?", answers: ["donut", "doughnut"], hints: ["They have many flavours and toppings.", "Think of a food and its shape."])
      addQuestion(question: " What has only two words but thousands of letters?", answers: ["post office"], hints: ["There are many kinds of letters.", "All letters pass through it."])
      addQuestion(question: "What has to be broken before it can be used?", answers: ["egg"], hints: ["Think white and yellow.", "Cracking."])
      addQuestion(question: "What is half of 2+2?", answers: ["3", "three"], hints: ["Read slowly.", "Take your time."])
      addQuestion(question: "What is harder to catch the faster you run?", answers: ["breath"], hints: ["The word catch can be used in many ways."])
      addQuestion(question: "What is in the middle of nowhere?", answers: ["h"], hints: ["Think literally", "Read carefully..."])
      addQuestion(question: "What is in front of a woman and in back of a cow?", answers: ["w"], hints: ["Think back.", "Literally."])
      addQuestion(question: "Inkypinkydinky. How do you spell that in four letters?", answers: ["that"], hints: ["Read it slowly.", "Pause after each sentence."])
      addQuestion(question: "What English word retains the same pronunciation, even after you take away four of its five letters?", answers: ["queue"], hints: ["What you do while you wait.", "Lines."])
      addQuestion(question: "What has four fingers and a thumb, but is not living?", answers: ["glove"], hints: ["Something hollow.", "Something you can wear."])
      addQuestion(question: "I have keys but no locks. I have a space but no room. You can enter, but can’t go outside. What am I?", answers: ["keyboard", "laptop", "computer"], hints: ["You've used it recently.", "Take a guess and you'll see."])
      addQuestion(question: "I can only live where there is light, but I die if the light shines on me. What am I?", answers: ["shadow"], hints: ["Think figuratively.", "Everyone has one in the light."])
      addQuestion(question: "What flies when it’s born, lies when it’s alive, and runs when it’s dead?", answers: ["snowflake", "snow flake"], hints: ["There are many different forms of 'running'.", "A unique answer."])
      addQuestion(question: "What comes once in a minute, twice in a moment, but never in a thousand years?", answers: ["m"], hints: ["Look closely.", "Think literally."])
      addQuestion(question: "Give me food, and I will live. Give me water, and I will die. What Am I?", answers: ["fire", "flame"], hints: ["I am visible and can be felt.", "You can't touch it."])
      addQuestion(question: "Which word in the dictionary is spelled incorrectly?", answers: ["incorrectly"], hints: ["There is only one.", "You can see it right now."])
      addQuestion(question: " I’m tall when I’m young and I’m short when I’m old. What am I?", answers: ["candle"], hints: ["My use is to burn.", "I hang around on cakes."])
      addQuestion(question: "What has hands but cannot clap?", answers: ["clock"], hints: ["One hand is shorter.", "It's always pointing."])
      addQuestion(question: "What is at the end of a rainbow?", answers: ["w"], hints: ["It's not gold.", "Think literally..."])
      addQuestion(question: "What starts with the letter T is filled with T and ends in T?", answers: ["teapot"], hints: ["There are many types of T", "It's very British."])
      addQuestion(question: "How many months have 28 days?", answers: ["all", "12", "twelve"], hints: ["Not exact.", "It's inclusive."])
      addQuestion(question: "What can run but cannot walk?", answers: ["water", "liquid"], hints: ["You've had this one before.", "It is a state."])
      addQuestion(question: "Beth’s mother has three daughters. One is called Lara, the other one is Sara. What is the name of the third daughter?", answers: ["beth"], hints: ["Read it carefully.", "Whose mother?"])
      addQuestion(question: " If there are 3 apples and you take away 2, how many do you have?", answers: ["2", "two"], hints: ["Where are they?", "Who has them?"])
      addQuestion(question: "What never asks questions but is often answered?", answers: ["doorbell", "phone", "call", "door"], hints: ["Answering questions isn't the only way of answering.", "Who's at the..."])
      addQuestion(question: "What five letter word becomes shorter when you add two letters to it?", answers: ["short"], hints: ["Think literally.", "You can see the word."])
      addQuestion(question: "What kind of coat can only be put on when wet?", answers: ["paint"], hints: ["There are many types of coat.", "You can't wear this type of coat."])
      addQuestion(question: "What runs, but never walks, often murmurs – never talks, has a bed but never sleeps, has a mouth but never eats?", answers: ["river", "stream"], hints: ["There's one in London.", "There are many different forms of running."])
      addQuestion(question: "What gets sharper the more that you use it?", answers: ["brain", "mind"], hints: ["You're using it right now.", "You need it to be alive."])
      addQuestion(question: "If I have it, I don’t share it.  If I share it, I don’t have it.  What is it?", answers: ["secret"], hints: ["It's something abstract.", "Some people love them, some people hate them.", "Mysterious people may have a lot of them."])
      addQuestion(question: "What can you catch but not throw?", answers: ["cold", "disease", "flu"], hints: ["Something no one wants to catch.", "It can have a big effect on your mood.", "It can affect your health."])
      addQuestion(question: "They come out at night without being called, and are lost in the day without being stolen.  What are they?", answers: ["stars"], hints: ["They don't come out in big cities.", "They're incredibly big but look incredibly small."])
      addQuestion(question: "Mike is a butcher. He is 5’10” tall. What does he weigh?", answers: ["meat", "food", "animal"], hints: ["What does he do?", "How much does his meat cost?", "What does his job involve?"])
      addQuestion(question: "What goes up and down but still remains in the same place?", answers: ["stairs", "staircase", "escalator"], hints: ["Most people use them every day.", "You don't want to fall around them."])
      addQuestion(question: "If you throw a red stone into the blue sea what will it become?", answers: ["wet"], hints: ["Think logically.", "Think about the water.", "Water is..."])
      addQuestion(question: "What has a head and a tail but no body?", answers: ["coin"], hints: ["Can be flipped.", "Some people use them to make decisions."])
      addQuestion(question: "Poor people have it. Rich people need it. If you eat it you die. What is it?", answers: ["nothing"], hints: ["Close your eyes and you can see it.", "Even when all else is gone, it remains.", "What's the opposite of everything?"])
      addQuestion(question: "What goes down but never comes up?", answers: ["rain", "raindrop", "rainfall"], hints: ["It comes down in some places more than others.", "Britain is known to get a lot of it."])
      addQuestion(question: "What goes up when rain comes down?", answers: ["umbrella", "brolly"], hints: ["What do you do when it starts raining?.", "They come in various designs."])
      addQuestion(question: "What travels around the world but stays in one corner?", answers: ["stamp"], hints: ["It's very small.", "You can decide where it goes around the world.", "They often come in packs."])
      addQuestion(question: "What is so delicate that saying its name breaks it?", answers: ["silence", "quiet"], hints: ["Don't think about it literally.", "You can't hear it.", "Sssh."])
      addQuestion(question: "What kind of tree can you carry in your hand?", answers: ["palm"], hints: ["You have two of these on you at all times."])
      addQuestion(question: "What is always coming but never arrives?", answers: ["tomorrow"], hints: ["Think about time..."])
      addQuestion(question: "What goes through towns and over hills but never moves?", answers: ["road", "path"], hints: ["Vehicles use them.", "Cities have a lot of these."])
      addQuestion(question: "What has a neck but no head?", answers: ["bottle"], hints: ["It's not living.", "They're hollow when empty."])
      addQuestion(question: "What loses its head in the morning but gets it back at night?", answers: ["pillow"], hints: ["Unless you're a night owl...", "The head is not attached to it."])
      addQuestion(question: "What is something that you will never see again?", answers: ["yesterday"], hints: ["Think once again about time"])
      addQuestion(question: "What is the center of gravity?", answers: ["v"], hints: ["Read carefully :)"])
      addQuestion(question: "What kind of room has no windows or doors?", answers: ["mushroom"], hints: ["You can't really be inside this type of room"])
      addQuestion(question: "Many have heard me, but nobody has seen me, and I will not speak back until spoken to. What am I?", answers: ["echo"], hints: ["They are not heard everywhere.", "They are not living.", "They can only say what you say."])
      addQuestion(question: "What belongs to you but others use it more than you do?", answers: ["name"], hints: ["Everyone has one.", "Everyone allows others to use theirs.", "You rarely use you own."])
      addQuestion(question: "What runs forever but never moves at all, has neither lungs nor throat, but still has a mighty roaring call?", answers: ["waterfall"], hints: ["You have probably seen one.", "They are not clean.", "They are very cold.", "You don't want to fall down one."])
      addQuestion(question: "A word I know, six letters it contains, remove one letter and twelve remain. What am I?", answers: ["dozens"], hints: ["Think about bakers.", "It is not a typical number but has the value of one.", "It is six letters long."])
      addQuestion(question: "What do you throw out when you want to use it, but take in when you don't want to use it?", answers: ["anchor"], hints: ["They are big.", "They are heavy.", "Sailors use them."])
      addQuestion(question: "What does nobody want, yet nobody wants to lose?", answers: ["work", "job"], hints: ["It varies for different people.", "It can be enjoyed but some people hate them.", "It keeps people alive."])
      addQuestion(question: "What flies around all day but never goes anywhere?", answers: ["flag"], hints: ["There are different types.", "Every country has one.", "They rely on wind."])
      addQuestion(question: "What flies without wings?", answers: ["time"], hints: ["Sometimes it appears to not be flying at all and staying still.", "There is a well-known phrase to do with this.", "It flies faster if you are enjoying yourself."])
      addQuestion(question: "What gets bigger the more you take from it?", answers: ["hole"], hints: ["It must be empty to exist.", "You do not want to fall in a deep one.", "You might need a shovel."])
      addQuestion(question: "What goes around and around the wood but never goes into the wood?", answers: ["bark"], hints: ["All trees have it.", "It is hard and rough.", "Dogs are known to do this."])
      addQuestion(question: "What gets whiter the dirtier it gets?", answers: ["chalkboard", "blackboard"], hints: ["They are not used much today.", "They were used in schools.", "Think about chalk."])
      addQuestion(question: "What goes in and around the house but never touches it?", answers: ["sun"], hints: ["It's hot.", "We see it everyday.", "You will never be able to touch it."])
      addQuestion(question: "What runs around a garden without moving?", answers: ["fence", "wall"], hints: ["It can get knocked over or broken.", "There are many forms of running...", "Some are taller than others.", "It is there for privacy."])
      addQuestion(question: "He has married many women, but has never been married. Who is he?", answers: ["priest", "vicar"], hints: ["He is close to someone but has never met them."])
      addQuestion(question: "What fastens two people yet touches only one?", answers: ["wedding ring", "ring"], hints: ["It is not alive.", "It is expensive.", "It is worn."])
      addQuestion(question: "The Bay of Bengal is in which state?", answers: ["liquid"], hints: ["Geography will not help you.", "The key word is Bay.", "There are many types of state."])
      addQuestion(question: "What has six faces but cannot wear makeup. It also has twenty one eyes but cannot see. What is it?", answers: ["dice", "die"], hints: ["They are rolled.", "They are very small.", "Some games need them."])
      addQuestion(question: "What can you hear but not touch or see?", answers: ["voice"], hints: ["Different people have different ones.", "Sometimes you can lose it", "If you have a cold, it can change yours."])
      addQuestion(question: "What has one eye but cannot see?", answers: ["needle"], hints: ["They are sharp.", "The size of the eye can vary.", "They are very small."])
      addQuestion(question: "What can you never eat for breakfast?", answers: ["dinner", "lunch"], hints: ["It's not a specific food.", "It's a fact, not an opinion.", "Think about meals."])
      addQuestion(question: "I am as light as a feather, yet the even strongest person in the world could not hold me for more than 22 minutes. What am I?", answers: ["breath"], hints: ["Some people can hold it longer than others.", "Some smell nice but not all.", "You can only see it when it is really cold."])
      addQuestion(question: "The more of it you take, the more of it you leave behind. What is it?", answers: ["footprint", "footstep", "step"], hints: ["They cannot be held.", "Some are larger than others.", "They are easily seen when it is snowing."])
      addQuestion(question: "Who makes it has no need of it. Who buys it has no use for it. Who uses it can neither see nor feel it. What is it?", answers: ["coffin"], hints: ["When in use, they always carry something inside.", "They are kept underground.", "The size changes depending on the user."])
      addQuestion(question: "What has a heart but no other organs?", answers: ["deck", "card", "deck of cards"], hints: ["It is 2D.", "The heart is always red.", "It is not living."])
      addQuestion(question: "I go in hard. I come out soft. You blow me hard. What am I?", answers: ["gum", "chewing gum"], hints: ["Not everyone can blow it.", "It comes in different flavours.", "Sometimes it changes something about your tongue."])
      addQuestion(question: "What 4-letter word can be written forwards or backwards, and can still be read from left to right?", answers: ["noon"], hints: ["Time of day.", "A meal is typically eaten at this time."])
      addQuestion(question: "Take off my skin, I won't cry, but you will. What am I?", answers: ["onion"], hints: ["It is not alive.", "You'll cry but you won't be sad."])
      addQuestion(question: "Mountains will crumble and temples will fall, and nobody can survive its endless call. What is it?", answers: ["time"], hints: ["It appears to move fast and slow at times but is always moving at the same pace."])
      addQuestion(question: "I am a ship that can be made to ride the greatest waves. I am not built by tool, but built by hearts and minds. What am I?", answers: ["friendship"], hints: ["It can only be had with certain people.", "There must be at least two people for it to exist.", "It should be treasured.", "Often it can be easily broken"])
      addQuestion(question: "When I take five and add six, I get eleven, but when I take six and add seven, I get one. What am I?", answers: ["clock"], hints: ["It is not alive.", "What goes around and around in a circle?"])
      addQuestion(question: "I have the same name as a porcelain face, yet I carry great loads from place to place. What am I?", answers: ["dolly"], hints: ["I'm often used to move boxes and big stuff around.", "I have wheels", "I have the same name as a sheep."])
      addQuestion(question: "You will always find me in the past. I can be created in the present, but the future can never taint me. What am I? ", answers: ["history"], hints: ["It is researched sometimes.", "Whoever wins the war writes this."])
      addQuestion(question: "What is easy to get into, but hard to get out of?", answers: ["trouble"], hints: ["If you get into this badly, you could be arrested."])
      addQuestion(question: "What has four wheels and flies?", answers: ["garbage truck", "rubbish truck", "rubbish lorry"], hints: ["Think about each word carefully.", "It comes to you once a week.", "Some people work in and around it.", "It is not surprisiong that it smells really bad."])
      addQuestion(question: "Which side of a cat has the most fur?", answers: ["outside"], hints: ["This is the same for every cat in the world.", "You do not need to inspect a cat to know this.", "Even if you do not have a cat, you should know this."])
      addQuestion(question: "I start with the letter E, I end with the letter E. I contain only one letter, yet I am not the letter E. What am I?", answers: ["envelope"], hints: ["Read the riddle carefully.", "There are many forms of letter."])
      addQuestion(question: "What type of house weighs the least?", answers: ["lighthouse"], hints: ["A play on words.", "Not literally."])
      addQuestion(question: "I walk with you almost every day, yet you never notice me. You step on me, but never say sorry. What am I?", answers: ["shoes"], hints: ["They get dirty.", "They can't feel pain", "They come in pairs.", "They vary in size."])
      addQuestion(question: "What falls often but never gets hurt?", answers: ["rain", "snow"], hints: ["It is cold when it falls.", "Sometimes lots of it falls but other times you barely notice it falling at all."])
      addQuestion(question: "What doesn't get any wetter, no matter how much rain falls on it?", answers: ["water", "lake", "sea", "river", "ocean"], hints: ["Something that already contains lots of water."])
      addQuestion(question: "I am lighter than air but a million people could not lift me up. What am I?", answers: ["bubble"], hints: ["It is very delicate.", "They can be really small but sometimes huge."])
      addQuestion(question: "I can be cracked, I can be made, I can be told, I can be played. What am I?", answers: ["joke"], hints: ["It cannot be held.", "The receiver is not always as happy as the giver.", "It's typically heard."])
      addQuestion(question: "I am always in front and never behind. What am I?", answers: ["future"], hints: ["Think about time.", "It is not an object."])
      addQuestion(question: "I pass before the sun, yet make no shadow. What am I?", answers: ["wind"], hints: ["It can be strong at times.", "You cannot see it but you can see what it affects."])
      addQuestion(question: "I am found in the sea and on land but I do not walk or swim. I'm never far from home. What am I?", answers: ["snail"], hints: ["It's home is wherever they are.", "Some people eat them."])
      addQuestion(question: "What is black when you buy it, red when you use it, and grey when you throw it away?", answers: ["charcoal", "coal"], hints: ["No hints here for the final question :)"])
      
    }
  }
  
}
