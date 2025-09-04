//
//  SavingsGoalView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct SavingsGoalView: View {
    @StateObject private var viewModel = SavingsGoalViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(hex: "#1a1a1a")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    SavingsGoalHeaderView(viewModel: viewModel)
                    
                    // Overview Cards
                    SavingsOverviewView(viewModel: viewModel)
                    
                    // Filters and Search
                    SavingsFiltersView(viewModel: viewModel)
                    
                    // Goals List
                    SavingsGoalListView(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingAddGoal) {
            AddEditSavingsGoalView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showingEditGoal) {
            AddEditSavingsGoalView(viewModel: viewModel, isEditing: true)
        }
        .sheet(isPresented: $viewModel.showingAddContribution) {
            AddContributionView(viewModel: viewModel)
        }
    }
}

struct SavingsGoalHeaderView: View {
    @ObservedObject var viewModel: SavingsGoalViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Savings Goals")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.activeGoals.count) active goals")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { viewModel.showCompleted.toggle() }) {
                    Image(systemName: viewModel.showCompleted ? "eye.slash" : "eye")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#fbd600"))
                }
                
                Button(action: { viewModel.clearFilters() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#fbd600"))
                }
                
                Button(action: { viewModel.showingAddGoal = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color(hex: "#fbd600"))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

struct SavingsOverviewView: View {
    @ObservedObject var viewModel: SavingsGoalViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Main Progress Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: viewModel.overallProgress)
                    .stroke(
                        Color(hex: "#fbd600"),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: viewModel.overallProgress)
                
                VStack(spacing: 2) {
                    Text("\(Int(viewModel.overallProgress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Saved")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Summary Stats
            HStack(spacing: 16) {
                SavingsStatCard(
                    title: "Target",
                    value: viewModel.formatCurrency(viewModel.totalTargetAmount),
                    icon: "target",
                    color: .blue
                )
                
                SavingsStatCard(
                    title: "Saved",
                    value: viewModel.formatCurrency(viewModel.totalSavedAmount),
                    icon: "banknote.fill",
                    color: .green
                )
                
                SavingsStatCard(
                    title: "Remaining",
                    value: viewModel.formatCurrency(viewModel.totalTargetAmount - viewModel.totalSavedAmount),
                    icon: "minus.circle.fill",
                    color: Color(hex: "#fbd600")
                )
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(viewModel.completedGoals.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(viewModel.goalsOnTrack)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#fbd600"))
                    
                    Text("On Track")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if viewModel.overdueGoals > 0 {
                    VStack(spacing: 4) {
                        Text("\(viewModel.overdueGoals)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        Text("Overdue")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            // Motivational Message
            Text(viewModel.getMotivationalMessage())
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct SavingsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct SavingsFiltersView: View {
    @ObservedObject var viewModel: SavingsGoalViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search goals...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            
            // Filter Options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Category Filter
                    Menu {
                        Button("All Categories") {
                            viewModel.selectedCategory = nil
                        }
                        
                        ForEach(SavingsCategory.allCases) { category in
                            Button(category.rawValue) {
                                viewModel.selectedCategory = category
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedCategory?.rawValue ?? "All Categories")
                            Image(systemName: "chevron.down")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Priority Filter
                    Menu {
                        Button("All Priorities") {
                            viewModel.selectedPriority = nil
                        }
                        
                        ForEach(GoalPriority.allCases, id: \.self) { priority in
                            Button(priority.rawValue) {
                                viewModel.selectedPriority = priority
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedPriority?.rawValue ?? "All Priorities")
                            Image(systemName: "chevron.down")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Sort Options
                    Menu {
                        ForEach(GoalSortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                viewModel.sortOption = option
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Sort")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
}

struct SavingsGoalListView: View {
    @ObservedObject var viewModel: SavingsGoalViewModel
    
    var body: some View {
        if viewModel.filteredGoals.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.3))
                
                Text(viewModel.showCompleted ? "No completed goals" : "No active goals found")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(viewModel.showCompleted ? 
                     "Complete your first goal to see it here" : 
                     "Create your first savings goal to start your journey")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                if !viewModel.showCompleted {
                    Button("Create Goal") {
                        viewModel.showingAddGoal = true
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#fbd600"))
                    .cornerRadius(25)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 60)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredGoals) { goal in
                        SavingsGoalCard(goal: goal, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

struct SavingsGoalCard: View {
    let goal: SavingsGoal
    @ObservedObject var viewModel: SavingsGoalViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: goal.category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: goal.category.color))
                        .frame(width: 40, height: 40)
                        .background(Color(hex: goal.category.color).opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(goal.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: goal.priority.icon)
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: goal.priority.color))
                            
                            if goal.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                            }
                            
                            if goal.isOverdue && !goal.isCompleted {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if !goal.description.isEmpty {
                            Text(goal.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(2)
                        }
                        
                        HStack(spacing: 16) {
                            Text(goal.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            if !goal.isCompleted {
                                Text("\(goal.daysRemaining) days left")
                                    .font(.caption)
                                    .foregroundColor(goal.isOverdue ? .red : .white.opacity(0.5))
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.formatCurrency(goal.currentAmount))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("of \(viewModel.formatCurrency(goal.targetAmount))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(goal.statusText)
                        .font(.caption)
                        .foregroundColor(Color(hex: goal.statusColor))
                }
            }
            
            // Progress Section
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(viewModel.formatProgress(goal.progress))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ProgressView(value: goal.progress)
                    .progressViewStyle(LinearProgressViewStyle(
                        tint: viewModel.getGoalStatusColor(goal)
                    ))
                    .scaleEffect(y: 2)
            }
            
            // Next Milestone or Action Buttons
            if let nextMilestone = goal.nextMilestone {
                HStack(spacing: 8) {
                    Image(systemName: nextMilestone.icon)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#fbd600"))
                    
                    Text("Next: \(nextMilestone.name)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(viewModel.formatCurrency(nextMilestone.targetAmount - goal.currentAmount) + " to go")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#fbd600"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#fbd600").opacity(0.1))
                .cornerRadius(8)
            }
            
            // Action Buttons
            if !goal.isCompleted {
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.selectedGoal = goal
                        viewModel.showingAddContribution = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add $")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#fbd600"))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    if goal.remainingAmount > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Monthly needed:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(viewModel.formatCurrency(goal.monthlyTargetContribution))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .contextMenu {
            if !goal.isCompleted {
                Button(action: {
                    viewModel.selectedGoal = goal
                    viewModel.showingAddContribution = true
                }) {
                    Label("Add Contribution", systemImage: "plus.circle")
                }
            }
            
            Button(action: { viewModel.editGoal(goal) }) {
                Label("Edit", systemImage: "pencil")
            }
            
            if !goal.isCompleted {
                Button(action: { viewModel.toggleGoalCompletion(goal) }) {
                    Label("Mark Complete", systemImage: "checkmark.circle")
                }
            }
            
            Button(action: { viewModel.archiveGoal(goal) }) {
                Label("Archive", systemImage: "archivebox")
            }
            
            Button(action: { viewModel.deleteGoal(goal) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddEditSavingsGoalView: View {
    @ObservedObject var viewModel: SavingsGoalViewModel
    let isEditing: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(hex: "#1a1a1a")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Goal Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("e.g., Emergency Fund", text: $viewModel.goalName)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Goal Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Describe your goal...", text: $viewModel.goalDescription)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Target Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Amount")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "#fbd600"))
                                
                                TextField("0.00", text: $viewModel.goalTargetAmount)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Target Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Date")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DatePicker("", selection: $viewModel.goalTargetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .colorScheme(.dark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Category and Priority
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Category", selection: $viewModel.goalCategory) {
                                    ForEach(SavingsCategory.allCases) { category in
                                        HStack {
                                            Image(systemName: category.icon)
                                            Text(category.rawValue)
                                        }
                                        .tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Priority")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Priority", selection: $viewModel.goalPriority) {
                                    ForEach(GoalPriority.allCases, id: \.self) { priority in
                                        HStack {
                                            Image(systemName: priority.icon)
                                            Text(priority.rawValue)
                                        }
                                        .tag(priority)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Quick Milestones Button
                        Button(action: {
                            if let amount = Double(viewModel.goalTargetAmount) {
                                viewModel.addSuggestedMilestones(for: viewModel.goalCategory, targetAmount: amount)
                            }
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Add Suggested Milestones")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#fbd600"))
                            .cornerRadius(25)
                        }
                        .disabled(viewModel.goalTargetAmount.isEmpty)
                        
                        // Milestones Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Milestones")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { viewModel.showingAddMilestone = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "#fbd600"))
                                }
                            }
                            
                            if viewModel.goalMilestones.isEmpty {
                                Text("No milestones added yet")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(10)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.goalMilestones) { milestone in
                                        MilestoneRow(
                                            milestone: milestone,
                                            onDelete: { viewModel.removeMilestone(milestone) }
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Reminders Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reminders")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Enable Reminders")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $viewModel.enableReminders)
                                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#fbd600")))
                                }
                                
                                if viewModel.enableReminders {
                                    HStack {
                                        Text("Frequency")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Picker("Frequency", selection: $viewModel.reminderFrequency) {
                                            ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                                                Text(frequency.rawValue).tag(frequency)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .foregroundColor(Color(hex: "#fbd600"))
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Goal" : "Create Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.clearGoalForm()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fbd600"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        if isEditing {
                            viewModel.updateGoal()
                        } else {
                            viewModel.addGoal()
                        }
                        dismiss()
                    }
                    .foregroundColor(viewModel.canSaveGoal ? Color(hex: "#fbd600") : .gray)
                    .disabled(!viewModel.canSaveGoal)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddMilestone) {
            AddMilestoneView(viewModel: viewModel)
        }
    }
}

struct MilestoneRow: View {
    let milestone: SavingsMilestone
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: milestone.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#fbd600"))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                if !milestone.reward.isEmpty {
                    Text("Reward: \(milestone.reward)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            Text("$\(String(format: "%.0f", milestone.targetAmount))")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct AddMilestoneView: View {
    @ObservedObject var viewModel: SavingsGoalViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(hex: "#1a1a1a")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Milestone Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("e.g., First $1,000", text: $viewModel.milestoneName)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Amount")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "#fbd600"))
                            
                            TextField("0.00", text: $viewModel.milestoneAmount)
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reward (Optional)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Treat yourself to...", text: $viewModel.milestoneReward)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.clearMilestoneForm()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fbd600"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addMilestone()
                        dismiss()
                    }
                    .foregroundColor(viewModel.canSaveMilestone ? Color(hex: "#fbd600") : .gray)
                    .disabled(!viewModel.canSaveMilestone)
                }
            }
        }
    }
}

struct AddContributionView: View {
    @ObservedObject var viewModel: SavingsGoalViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(hex: "#1a1a1a")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if let goal = viewModel.selectedGoal {
                        // Goal Info
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: goal.category.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: goal.category.color))
                                    .frame(width: 48, height: 48)
                                    .background(Color(hex: goal.category.color).opacity(0.2))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("\(viewModel.formatCurrency(goal.currentAmount)) of \(viewModel.formatCurrency(goal.targetAmount))")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            
                            ProgressView(value: goal.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#fbd600")))
                                .scaleEffect(y: 2)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Contribution Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contribution Amount")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color(hex: "#fbd600"))
                            
                            TextField("0.00", text: $viewModel.contributionAmount)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Quick Amount Buttons
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Amounts")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach([10, 25, 50, 100, 250, 500], id: \.self) { amount in
                                Button(action: {
                                    viewModel.contributionAmount = String(amount)
                                }) {
                                    Text("$\(amount)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (Optional)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Add a note about this contribution...", text: $viewModel.contributionNote)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Contribution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.clearContributionForm()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fbd600"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addContribution()
                        dismiss()
                    }
                    .foregroundColor(viewModel.canSaveContribution ? Color(hex: "#fbd600") : .gray)
                    .disabled(!viewModel.canSaveContribution)
                }
            }
        }
    }
}

#Preview {
    SavingsGoalView()
}
