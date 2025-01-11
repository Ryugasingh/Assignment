//
//  DietPlanView.swift
//  Assignment
//
//  Created by Sambhav Singh on 11/01/25.
//

import SwiftUICore
import SwiftUI


struct DietPlanView: View {
    @StateObject private var viewModel = DietPlanViewModel()
    @State private var selectedMeals: Set<String> = []
    @State private var selectAllEnabled = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Everyday Diet Plan")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        // Grocery List Action
                    }) {
                        Image(systemName: "cart")
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                
                Text("Track Sambhav's every meal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Diet Streak Section
                            streakCard
                            
                            // Search Bar
                            searchBar
                            
                            // Meals Sections
                            ForEach(viewModel.diets) { diet in
                                mealSection(diet: diet)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            if viewModel.diets.isEmpty {
                viewModel.fetchDiets()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search Meals", text: .constant(""))
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Button(action: {
                // Filter action
            }) {
                Image(systemName: "line.horizontal.3.decrease")
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }
    
    private var streakCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Diet Streak")
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.blue)
                    Text("1 Streak")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
            }
            
            HStack(spacing: 20) {
                ForEach(["Morning", "Afternoon", "Evening", "Night"], id: \.self) { time in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(getStatusColor(for: time))
                                .frame(width: 70, height: 50)
                            
                            if let icon = getStatusIcon(for: time) {
                                Image(systemName: icon)
                                    .foregroundColor(.white)
                            }
                        }
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func getStatusColor(for time: String) -> Color {
        switch time {
        case "Morning": return .green
        case "Afternoon": return .red
        case "Evening": return .blue
        default: return .gray.opacity(0.3)
        }
    }
    
    private func getStatusIcon(for time: String) -> String? {
        switch time {
        case "Morning": return "checkmark"
        case "Afternoon": return "xmark"
        case "Evening": return nil
        default: return nil
        }
    }
    
    private func mealSection(diet: Diet) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(diet.daytime) Meals")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(diet.timings)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // Select All Button
                Button(action: {
                    toggleSelectAll(for: diet)
                }) {
                    HStack {
                        Image(systemName: isAllSelected(for: diet) ? "checkmark.square.fill" : "square")
                            .foregroundColor(.blue)
                        Text("Select All")
                            .foregroundColor(.blue)
                    }
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(diet.progressStatus.completed) / CGFloat(diet.progressStatus.total))
                        .stroke(Color.pink, lineWidth: 4)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(diet.progressStatus.completed) of \(diet.progressStatus.total)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            ForEach(diet.recipes) { recipe in
                mealCard(recipe: recipe, dietTime: diet.daytime)
            }
        }
    }
    
    private func mealCard(recipe: Recipe, dietTime: String) -> some View {
        let mealId = "\(dietTime)-\(recipe.id)"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Checkbox
                Button(action: {
                    toggleMealSelection(mealId)
                }) {
                    Image(systemName: selectedMeals.contains(mealId) ? "checkmark.square.fill" : "square")
                        .foregroundColor(.blue)
                }
                
                Text(recipe.timeSlot)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    // Favorite action
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text("\(recipe.duration) mins")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    // Customize Action
                }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Customize")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    // Feed Action
                }) {
                    HStack {
                        Image(systemName: recipe.isCompleted == 1 ? "checkmark" : "plus")
                        Text(recipe.isCompleted == 1 ? "Fed" : "Feed?")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(recipe.isCompleted == 1 ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    .foregroundColor(recipe.isCompleted == 1 ? .green : .blue)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                viewModel.fetchDiets()
            }
            .padding()
        }
    }
    
    // Helper functions for selection functionality
    private func toggleSelectAll(for diet: Diet) {
        let mealIds = diet.recipes.map { "\(diet.daytime)-\($0.id)" }
        
        if isAllSelected(for: diet) {
            selectedMeals.subtract(mealIds)
        } else {
            selectedMeals.formUnion(mealIds)
        }
    }
    
    private func isAllSelected(for diet: Diet) -> Bool {
        let mealIds = Set(diet.recipes.map { "\(diet.daytime)-\($0.id)" })
        return mealIds.isSubset(of: selectedMeals)
    }
    
    private func toggleMealSelection(_ mealId: String) {
        if selectedMeals.contains(mealId) {
            selectedMeals.remove(mealId)
        } else {
            selectedMeals.insert(mealId)
        }
    }
}

struct DietPlanView_Previews: PreviewProvider {
    static var previews: some View {
        DietPlanView()
    }
}
