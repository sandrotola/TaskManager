//
//  AddNewTask.swift
//  TaskManager
//
//  Created by Sandro Tola on 07/02/24.
//

import SwiftUI
import RealmSwift

struct AddTaskView: View {
    @State private var taskName: String = ""
    @State private var taskType: String = ""
    @State private var startTime: Date = Calendar.current.startOfDay(for: Date())
    @State private var endTime: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60 * 60)
    
    @Binding var showModal: Bool

    var body: some View {
        NavigationView {
            Form {
                TextField("Task Name", text: $taskName)
                TextField("Task Type", text: $taskType)
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $endTime, in: startTime..., displayedComponents: .hourAndMinute)

                Button("Save Task") {
                    saveTask()
                }
            }
            .navigationBarTitle("Add New Task", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") { showModal = false })
        }
    }
    
    private func saveTask() {
        // Format date to get hours and minutes
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Prepare task to save
        let newTask = Task()
        newTask.name = taskName
        newTask.type = taskType
        newTask.startTime = formatter.string(from: startTime)
        newTask.endTime = formatter.string(from: endTime)

        // Call our Realm Manager to save the task in the local Database
        RealmManager.shared.addTask(newTask)

        // Close the modal
        showModal = false
    }
}
