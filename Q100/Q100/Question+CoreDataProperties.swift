//
//  Question+CoreDataProperties.swift
//  Q100
//
//  Created by Daniel Meechan on 20/07/2017.
//  Copyright © 2017 Rogue Studios. All rights reserved.
//

import Foundation
import CoreData


extension Question {

  // Used the following websites:
  // Arrays:
  // https://stackoverflow.com/questions/40410169/invalid-redeclaration-on-coredata-classes
  // https://stackoverflow.com/questions/29825604/how-to-save-array-to-coredata
  // CoreData:
  // https://blog.bobthedeveloper.io/beginners-guide-to-core-data-in-swift-3-85292ef4edd
  // And maybe this too? It's from the same guy: https://github.com/bobthedev/Blog_Intro_to_CoreData
  
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var number: Int16
    @NSManaged public var question: String
    @NSManaged public var answer: [NSString]
    @NSManaged public var hint: [NSString]

}
