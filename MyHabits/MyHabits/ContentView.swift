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
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("My Habits")) {
                    ForEach(habits) { habit in
                        HStack {
                            Text(habit.name)
                            Spacer()
                            Text("🔥 \(habit.streak)")
                            Button(action: {
                                incrementStreak(for: habit)
                            }) {
                                Text("Complete")
                                    .foregroundColor(.blue)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .disabled(!canIncrementStreak(for: habit))
                        }
                    }
                    .onDelete(perform: deleteHabit)
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
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        saveHabits()
    }
    
    func incrementStreak(for habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].incrementStreak()
            saveHabits()
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


