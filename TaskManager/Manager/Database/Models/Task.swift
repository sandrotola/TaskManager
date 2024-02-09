//
//  Task.swift
//  TaskManager
//
//  Created by Sandro Tola on 07/02/24.
//

import RealmSwift
import Foundation

class Task: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
   @Persisted var name: String = ""
   @Persisted var type: String = ""
   @Persisted var startTime: String = ""
   @Persisted var endTime: String = ""
}
