//
//  SubjectName.swift
//  Exams
//
//  Created by Marin Todorov on 5/10/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import RealmSwift

class SubjectName: Object {

  convenience init(_ name: String) {
    self.init()
    self.name = name
  }

  dynamic var name = ""

}
