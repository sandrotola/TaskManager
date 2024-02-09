//
//  RealmManager.swift
//  TaskManager
//
//  Created by Sandro Tola on 07/02/24.
//

import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()

    private var realm: Realm

    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Realm can't be initialized: \(error.localizedDescription)")
        }
    }

    func addTask(_ task: Task) {
        do {
            try realm.write {
                realm.add(task)
            }
        } catch let error {
            print("Error adding task: \(error.localizedDescription)")
        }
    }

    func deleteTask(_ task: Task) {
        do {
            // Fetch the same task from the current Realm instance
            if let taskToDelete = realm.object(ofType: Task.self, forPrimaryKey: task.id) {
                try realm.write {
                    realm.delete(taskToDelete)
                }
            } else {
                print("Task not found or already deleted")
            }
        } catch {
            print("Error deleting task: \(error.localizedDescription)")
        }
    }

    func updateTask(_ task: Task, with newTask: Task) {
        do {
            if let taskToUpdate = realm.object(ofType: Task.self, forPrimaryKey: task.id) {
                try realm.write {
                    taskToUpdate.name = newTask.name
                    taskToUpdate.type = newTask.type
                    taskToUpdate.startTime = newTask.startTime
                    taskToUpdate.endTime = newTask.endTime
                }
            } else {
                print("No Task with id \(task.id) found")
            }
        } catch {
            print("Error updating task: \(error.localizedDescription)")
        }
    }
}
