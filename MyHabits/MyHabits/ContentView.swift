//
//  ContentView.swift
//  MyHabits
//
//  Created by Chrishane Amarasekara on 27/5/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var habits: [String] = []
    @State private var newHabit = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("My Habits")) {
                    ForEach(habits, id: \.self) { habit in
                        Text(habit)
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
        habits.append(newHabit)
        saveHabits()
        newHabit = ""
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        saveHabits()
    }
    
    func loadHabits() {
        if let savedHabits = UserDefaults.standard.stringArray(forKey: "SavedHabits") {
            habits = savedHabits
        }
    }
    
    func saveHabits() {
        UserDefaults.standard.set(habits, forKey: "SavedHabits")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
