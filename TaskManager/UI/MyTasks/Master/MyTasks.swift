//
//  MyTasks.swift
//  TaskManager
//
//  Created by Sandro Tola on 07/02/24.
//

import Foundation

struct MyTasks {
    
    struct Data {
        struct Day: Identifiable {
            let id = UUID()
            let day: String
            let name: String
            
            init(day: String, name: String) {
                self.day = day
                self.name = name
            }
        }
    }
}
