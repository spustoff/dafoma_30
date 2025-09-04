//
//  SavingsGoalViewModel.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import SwiftUI
import Combine

class SavingsGoalViewModel: ObservableObject {
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var selectedGoal: SavingsGoal?
    @Published var showingAddGoal = false
    @Published var showingEditGoal = false
    @Published var showingGoalDetail = false
    @Published var showingAddContribution = false
    @Published var searchText = ""
    @Published var selectedCategory: SavingsCategory?
    @Published var selectedPriority: GoalPriority?
    @Published var sortOption: GoalSortOption = .dateCreated
    @Published var showCompleted = false
    
    // Add/Edit goal form
    @Published var goalName = ""
    @Published var goalDescription = ""
    @Published var goalTargetAmount = ""
    @Published var goalTargetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @Published var goalCategory: SavingsCategory = .other
    @Published var goalPriority: GoalPriority = .medium
    @Published var goalMilestones: [SavingsMilestone] = []
    @Published var enableReminders = true
    @Published var reminderFrequency: ReminderFrequency = .weekly
    
    // Add contribution form
    @Published var contributionAmount = ""
    @Published var contributionNote = ""
    @Published var contributionMethod: ContributionMethod = .manual
    
    // Milestone form
    @Published var showingAddMilestone = false
    @Published var milestoneName = ""
    @Published var milestoneAmount = ""
    @Published var milestoneReward = ""
    @Published var milestoneIcon = "flag.fill"
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var filteredGoals: [SavingsGoal] {
        var result = showCompleted ? savingsGoals : savingsGoals.filter { !$0.isCompleted && !$0.isArchived }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { goal in
                goal.name.localizedCaseInsensitiveContains(searchText) ||
                goal.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by priority
        if let priority = selectedPriority {
            result = result.filter { $0.priority == priority }
        }
        
        // Sort
        switch sortOption {
        case .dateCreated:
            result = result.sorted { $0.createdDate > $1.createdDate }
        case .name:
            result = result.sorted { $0.name < $1.name }
        case .targetAmount:
            result = result.sorted { $0.targetAmount > $1.targetAmount }
        case .progress:
            result = result.sorted { $0.progress > $1.progress }
        case .targetDate:
            result = result.sorted { $0.targetDate < $1.targetDate }
        case .priority:
            result = result.sorted { $0.priority.rawValue < $1.priority.rawValue }
        }
        
        return result
    }
    
    var activeGoals: [SavingsGoal] {
        savingsGoals.filter { !$0.isCompleted && !$0.isArchived }
    }
    
    var completedGoals: [SavingsGoal] {
        savingsGoals.filter { $0.isCompleted }
    }
    
    var totalTargetAmount: Double {
        activeGoals.reduce(0) { $0 + $1.targetAmount }
    }
    
    var totalSavedAmount: Double {
        activeGoals.reduce(0) { $0 + $1.currentAmount }
    }
    
    var overallProgress: Double {
        guard totalTargetAmount > 0 else { return 0 }
        return min(totalSavedAmount / totalTargetAmount, 1.0)
    }
    
    var goalsOnTrack: Int {
        activeGoals.filter { !$0.isOverdue }.count
    }
    
    var overdueGoals: Int {
        activeGoals.filter { $0.isOverdue }.count
    }
    
    var upcomingMilestones: [SavingsMilestone] {
        activeGoals.compactMap { $0.nextMilestone }.sorted { $0.targetAmount < $1.targetAmount }
    }
    
    var recentContributions: [SavingsContribution] {
        let allContributions = activeGoals.flatMap { $0.contributions }
        return Array(allContributions.sorted { $0.date > $1.date }.prefix(10))
    }
    
    var canSaveGoal: Bool {
        !goalName.isEmpty && 
        !goalTargetAmount.isEmpty && 
        Double(goalTargetAmount) != nil &&
        Double(goalTargetAmount) ?? 0 > 0
    }
    
    var canSaveContribution: Bool {
        !contributionAmount.isEmpty && 
        Double(contributionAmount) != nil &&
        Double(contributionAmount) ?? 0 > 0
    }
    
    var canSaveMilestone: Bool {
        !milestoneName.isEmpty && 
        !milestoneAmount.isEmpty && 
        Double(milestoneAmount) != nil &&
        Double(milestoneAmount) ?? 0 > 0
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$savingsGoals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] goals in
                self?.savingsGoals = goals
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Goal Management
    
    func addGoal() {
        guard canSaveGoal,
              let amount = Double(goalTargetAmount) else { return }
        
        var goal = SavingsGoal(
            name: goalName,
            description: goalDescription,
            targetAmount: amount,
            targetDate: goalTargetDate,
            category: goalCategory,
            priority: goalPriority
        )
        
        goal.milestones = goalMilestones
        goal.reminderSettings.enableReminders = enableReminders
        goal.reminderSettings.reminderFrequency = reminderFrequency
        
        dataService.addSavingsGoal(goal)
        clearGoalForm()
        showingAddGoal = false
    }
    
    func updateGoal() {
        guard let goal = selectedGoal,
              canSaveGoal,
              let amount = Double(goalTargetAmount) else { return }
        
        var updatedGoal = goal
        updatedGoal.name = goalName
        updatedGoal.description = goalDescription
        updatedGoal.targetAmount = amount
        updatedGoal.targetDate = goalTargetDate
        updatedGoal.category = goalCategory
        updatedGoal.priority = goalPriority
        updatedGoal.milestones = goalMilestones
        updatedGoal.reminderSettings.enableReminders = enableReminders
        updatedGoal.reminderSettings.reminderFrequency = reminderFrequency
        
        dataService.updateSavingsGoal(updatedGoal)
        clearGoalForm()
        showingEditGoal = false
        selectedGoal = nil
    }
    
    func deleteGoal(_ goal: SavingsGoal) {
        dataService.deleteSavingsGoal(goal)
    }
    
    func editGoal(_ goal: SavingsGoal) {
        selectedGoal = goal
        goalName = goal.name
        goalDescription = goal.description
        goalTargetAmount = String(goal.targetAmount)
        goalTargetDate = goal.targetDate
        goalCategory = goal.category
        goalPriority = goal.priority
        goalMilestones = goal.milestones
        enableReminders = goal.reminderSettings.enableReminders
        reminderFrequency = goal.reminderSettings.reminderFrequency
        showingEditGoal = true
    }
    
    func toggleGoalCompletion(_ goal: SavingsGoal) {
        var updatedGoal = goal
        updatedGoal.isCompleted.toggle()
        updatedGoal.completedDate = updatedGoal.isCompleted ? Date() : nil
        dataService.updateSavingsGoal(updatedGoal)
    }
    
    func archiveGoal(_ goal: SavingsGoal) {
        var updatedGoal = goal
        updatedGoal.isArchived = true
        dataService.updateSavingsGoal(updatedGoal)
    }
    
    func clearGoalForm() {
        goalName = ""
        goalDescription = ""
        goalTargetAmount = ""
        goalTargetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        goalCategory = .other
        goalPriority = .medium
        goalMilestones = []
        enableReminders = true
        reminderFrequency = .weekly
    }
    
    // MARK: - Contribution Management
    
    func addContribution() {
        guard let goal = selectedGoal,
              canSaveContribution,
              let amount = Double(contributionAmount) else { return }
        
        dataService.addContributionToGoal(goal.id, amount: amount, note: contributionNote)
        clearContributionForm()
        showingAddContribution = false
    }
    
    func clearContributionForm() {
        contributionAmount = ""
        contributionNote = ""
        contributionMethod = .manual
    }
    
    // MARK: - Milestone Management
    
    func addMilestone() {
        guard canSaveMilestone,
              let amount = Double(milestoneAmount) else { return }
        
        let milestone = SavingsMilestone(
            name: milestoneName,
            targetAmount: amount,
            reward: milestoneReward,
            icon: milestoneIcon
        )
        
        goalMilestones.append(milestone)
        goalMilestones.sort { $0.targetAmount < $1.targetAmount }
        
        clearMilestoneForm()
        showingAddMilestone = false
    }
    
    func removeMilestone(_ milestone: SavingsMilestone) {
        goalMilestones.removeAll { $0.id == milestone.id }
    }
    
    func clearMilestoneForm() {
        milestoneName = ""
        milestoneAmount = ""
        milestoneReward = ""
        milestoneIcon = "flag.fill"
    }
    
    // MARK: - Quick Actions
    
    func createQuickGoal(for category: SavingsCategory, amount: Double) {
        let goal = SavingsGoal(
            name: category.rawValue,
            description: "Quick goal for \(category.rawValue.lowercased())",
            targetAmount: amount,
            targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
            category: category
        )
        
        dataService.addSavingsGoal(goal)
    }
    
    func addSuggestedMilestones(for category: SavingsCategory, targetAmount: Double) {
        goalMilestones.removeAll()
        
        let suggestions = category.suggestedMilestones
        let milestoneValues = suggestions.enumerated().map { index, name in
            let percentage = Double(index + 1) / Double(suggestions.count)
            return (name, targetAmount * percentage)
        }
        
        for (name, amount) in milestoneValues {
            let milestone = SavingsMilestone(
                name: name,
                targetAmount: amount,
                icon: "flag.fill"
            )
            goalMilestones.append(milestone)
        }
    }
    
    // MARK: - Utility Functions
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedPriority = nil
        sortOption = .dateCreated
        showCompleted = false
    }
    
    func getGoalProgress(_ goal: SavingsGoal) -> Double {
        return goal.progress
    }
    
    func getGoalStatusColor(_ goal: SavingsGoal) -> Color {
        return Color(hex: goal.statusColor)
    }
    
    func getPriorityColor(_ priority: GoalPriority) -> Color {
        return Color(hex: priority.color)
    }
    
    func getCategoryColor(_ category: SavingsCategory) -> Color {
        return Color(hex: category.color)
    }
    
    func formatCurrency(_ amount: Double) -> String {
        return String(format: "$%.0f", amount)
    }
    
    func formatProgress(_ progress: Double) -> String {
        return String(format: "%.1f%%", progress * 100)
    }
    
    func getMotivationalMessage() -> String {
        let completedCount = completedGoals.count
        let activeCount = activeGoals.count
        
        if completedCount == 0 && activeCount == 0 {
            return "Start your savings journey by creating your first goal!"
        } else if completedCount == 0 {
            return "You're on your way! Keep working toward your \(activeCount) goal\(activeCount == 1 ? "" : "s")."
        } else if activeCount == 0 {
            return "Congratulations on completing \(completedCount) goal\(completedCount == 1 ? "" : "s")! Ready for new challenges?"
        } else {
            return "Amazing progress! \(completedCount) completed, \(activeCount) in progress. You're building great habits!"
        }
    }
    
    func getRecommendations() -> [String] {
        var recommendations: [String] = []
        
        if activeGoals.isEmpty {
            recommendations.append("Start with an emergency fund goal - aim for 3-6 months of expenses.")
            recommendations.append("Set a small, achievable goal first to build momentum.")
        } else {
            let highPriorityGoals = activeGoals.filter { $0.priority == .high || $0.priority == .critical }
            if !highPriorityGoals.isEmpty {
                recommendations.append("Focus on your high-priority goals first for maximum impact.")
            }
            
            let lowProgressGoals = activeGoals.filter { $0.progress < 0.1 }
            if lowProgressGoals.count > 2 {
                recommendations.append("Consider consolidating some goals to maintain focus.")
            }
            
            if overdueGoals > 0 {
                recommendations.append("Review your overdue goals and adjust target dates if needed.")
            }
            
            let totalMonthlyNeeded = activeGoals.reduce(0) { $0 + $1.monthlyTargetContribution }
            if totalMonthlyNeeded > 0 {
                recommendations.append("You need about $\(Int(totalMonthlyNeeded))/month to reach all goals on time.")
            }
        }
        
        if recommendations.isEmpty {
            recommendations.append("Great job managing your savings goals! Consider adding stretch goals.")
        }
        
        return recommendations
    }
}

enum GoalSortOption: String, CaseIterable {
    case dateCreated = "Date Created"
    case name = "Name"
    case targetAmount = "Target Amount"
    case progress = "Progress"
    case targetDate = "Target Date"
    case priority = "Priority"
    
    var icon: String {
        switch self {
        case .dateCreated: return "calendar"
        case .name: return "textformat"
        case .targetAmount: return "dollarsign.circle"
        case .progress: return "chart.bar"
        case .targetDate: return "calendar.badge.clock"
        case .priority: return "exclamationmark.circle"
        }
    }
}
