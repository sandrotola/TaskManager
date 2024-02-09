//
//  MyTasksView.swift
//  TaskManager
//
//  Created by Sandro Tola on 07/02/24.
//

import SwiftUI
import RealmSwift

struct MyTasksView: View {
    @ObservedResults(Task.self) var tasks
    @State private var showingAddTaskModal = false
    @State private var showingEditTaskModal = false
    
    var body: some View {
        VStack {
            HorizontalCalendar(year: 2024, month: 1)
            MyTaskList(
                tasks: Array(tasks),
                showingAddTaskModal: $showingAddTaskModal
            )
            Spacer()
        }
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskView(showModal: $showingAddTaskModal)
        }
    }
}

struct HorizontalCalendar: View {
    let year: Int
    let month: Int
       
    var body: some View {
       VStack {
           HStack {
               Text(monthName(from: month))
                   .font(.title)
                   .bold()
                   .padding()
               Spacer()
           }
           ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 10) {
                   ForEach(generateDaysInMonth(for: month, year: year)) { day in
                       CalendarDay(dayNumber: day.day, dayName: day.name, isHighlighted: day.day == "1")
                   }
               }
               .padding()
           }
       }
    }

    func monthName(from month: Int) -> String {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "MMMM"
       let date = Calendar.current.date(from: DateComponents(year: year, month: month))!
       return dateFormatter.string(from: date)
    }
    
    func generateDaysInMonth(for month: Int, year: Int) -> [MyTasks.Data.Day] {
        var days = [MyTasks.Data.Day]()
        
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        for day in range {
            let dayDateComponents = DateComponents(year: year, month: month, day: day)
            let dayDate = calendar.date(from: dayDateComponents)!
            let dayName = dateFormatter.string(from: dayDate)
            days.append(MyTasks.Data.Day(day: "\(day)", name: dayName))
        }
        
        return days
    }
}

struct CalendarDay: View {
    let dayNumber: String
    let dayName: String
    var isHighlighted: Bool = false
    
    var body: some View {
        VStack {
            Text(dayNumber)
                .font(.headline)
                .foregroundColor(isHighlighted ? .white : .primary)
                .bold(isHighlighted)
            Text(dayName)
                .font(.caption)
                .foregroundColor(isHighlighted ? .white : .primary)
                .bold(isHighlighted)
        }
        .frame(width: 60, height: 80)
        .background(isHighlighted ? Color.pink : Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct MyTaskList: View {
    let tasks: [Task]
    @State private var activeTaskId: ObjectId?
    @Binding var showingAddTaskModal: Bool
    @State var showingEditTaskModal: Bool = false
    @State var selectedTask: Task = Task()

    var body: some View {
        VStack {
            HStack {
                Text("My Tasks")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
                Button(action: {
                    showingAddTaskModal = true
                    activeTaskId = nil
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.pink)
                }
                .padding()
            }

            if tasks.isEmpty {
                Text("Your work for the day is done.")
                    .font(.headline)
                    .bold()
                    .padding()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(tasks) { task in
                            TaskCard(
                                task: task,
                                activeTaskId: $activeTaskId,
                                onEdit: {
                                    selectedTask.id = task.id
                                    selectedTask.name = task.name
                                    selectedTask.type = task.type
                                    selectedTask.startTime = task.startTime
                                    selectedTask.endTime = task.endTime
                                    activeTaskId = nil
                                    showingEditTaskModal = true
                                },
                                onComplete: {
                                    activeTaskId = nil
                                    RealmManager.shared.deleteTask(task)
                                }
                            )
                            .onLongPressGesture {
                                activeTaskId = (activeTaskId == task.id) ? nil : task.id
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onTapGesture {
            activeTaskId = nil
        }
        .sheet(isPresented: $showingEditTaskModal) {
            EditTaskView(task: selectedTask, showModal: $showingEditTaskModal)
        }
    }
}

struct TaskCard: View {
    @State private var showOptions = false
    let task: Task
    @Binding var activeTaskId: ObjectId?
    @State private var isAnimating = false
    var onEdit: () -> Void
    var onComplete: () -> Void

    
    var body: some View {
        HStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.pink)
                .frame(width: 8)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.type.uppercased())
                    .font(.caption)
                    .foregroundColor(.pink)
                    .padding(.horizontal, 8)
                    .background(Color.pink.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text(task.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("\(task.startTime) - \(task.endTime)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding()
        .background(activeTaskId == task.id ? Color(red: 255/255, green: 207/255, blue: 207/255) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .padding(.horizontal)
        .onChange(of: activeTaskId) {
            if (activeTaskId == task.id) {
                isAnimating = true
            } else {
                isAnimating = false
            }
        }
        .rotationEffect(.degrees(isAnimating ? 1 : 0))
        .animation(isAnimating ? .easeInOut(duration: 0.08).repeatForever(autoreverses: true) : .default, value: isAnimating)

        if activeTaskId == task.id {
            HStack {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.blue)
                }
                .padding()
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.pink)
                }
                .padding()
            }
        }
    }
}

#Preview {
    MyTasksView()
}
