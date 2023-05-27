//
//  ContentView.swift
//  MyHabits
//
//  Created by Chrishane Amarasekara on 27/5/2023.
//

import SwiftUI

struct Habit: Identifiable, Codable {
    var id = UUID()
    let name: String
    var streak: Int
    var lastUpdated: Date?
    
    mutating func incrementStreak() {
        let currentDate = Date()
        
        if let lastUpdated = lastUpdated, Calendar.current.isDate(lastUpdated, inSameDayAs: currentDate) {
            // Already updated today
            return
        }
        
        streak += 1
        lastUpdated = currentDate
    }
}

struct ContentView: View {
    @State private var habits: [Habit] = []
    @State private var newHabit = ""
    @State private var alertType: AlertType?
    
    enum AlertType: Identifiable {
        case increment
        case alreadyIncremented
        
        var id: Int {
            hashValue
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("My Habits")) {
                    ForEach(habits) { habit in
                        HStack {
                            Text(habit.name)
                            Spacer()
                            Text("Streak: \(habit.streak)")
                            Button(action: {
                                incrementStreak(for: habit)
                            }) {
                                Text("Increment")
                                    .foregroundColor(.blue)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .disabled(!canIncrementStreak(for: habit))
                        }
                    }
                }
                
                Section(header: Text("Add New Habit")) {
                    HStack {
                        TextField("Enter habit", text: $newHabit)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: addHabit) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("MyHabits")
            .toolbar {
                EditButton()
            }
            .alert(item: $alertType) { alertType in
                switch alertType {
                case .increment:
                    return Alert(
                        title: Text("Good job today!"),
                        message: Text("Check back in tomorrow."),
                        dismissButton: .default(Text("OK"))
                    )
                case .alreadyIncremented:
                    return Alert(
                        title: Text("Streak Already Updated"),
                        message: Text("You can only increment the streak once per day."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .onAppear(perform: loadHabits)
    }
    
    func addHabit() {
        guard !newHabit.isEmpty else { return }
        let habit = Habit(name: newHabit, streak: 0, lastUpdated: nil)
        habits.append(habit)
        saveHabits()
        newHabit = ""
    }
    
    func incrementStreak(for habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            if canIncrementStreak(for: habit) {
                habits[index].incrementStreak()
                saveHabits()
                alertType = .increment
            } else {
                alertType = .alreadyIncremented
            }
        }
    }
    
    func canIncrementStreak(for habit: Habit) -> Bool {
        if let lastUpdated = habit.lastUpdated, Calendar.current.isDateInToday(lastUpdated) {
            return false
        }
        return true
    }
    
    func loadHabits() {
        if let savedHabitsData = UserDefaults.standard.data(forKey: "SavedHabits"),
           let savedHabits = try? JSONDecoder().decode([Habit].self, from: savedHabitsData) {
            habits = savedHabits
        }
    }
    
    func saveHabits() {
        if let encodedData = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encodedData, forKey: "SavedHabits")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
