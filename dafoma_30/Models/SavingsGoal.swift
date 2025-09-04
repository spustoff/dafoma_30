//
//  SavingsGoal.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation

struct SavingsGoal: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date
    var category: SavingsCategory
    var priority: GoalPriority
    var isCompleted: Bool
    var isArchived: Bool
    var createdDate: Date
    var completedDate: Date?
    var milestones: [SavingsMilestone]
    var contributions: [SavingsContribution]
    var reminderSettings: GoalReminderSettings
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }
    
    var isOverdue: Bool {
        Date() > targetDate && !isCompleted
    }
    
    var monthlyTargetContribution: Double {
        guard daysRemaining > 0 else { return remainingAmount }
        let monthsRemaining = max(Double(daysRemaining) / 30.44, 1) // Average days per month
        return remainingAmount / monthsRemaining
    }
    
    var weeklyTargetContribution: Double {
        monthlyTargetContribution / 4.33 // Average weeks per month
    }
    
    var statusText: String {
        if isCompleted { return "Completed" }
        if isOverdue { return "Overdue" }
        if daysRemaining <= 30 { return "Due Soon" }
        return "On Track"
    }
    
    var statusColor: String {
        if isCompleted { return "#00AA00" }
        if isOverdue { return "#FF4444" }
        if daysRemaining <= 30 { return "#FF8800" }
        if progress >= 0.8 { return "#88CC00" }
        return "#4A90E2"
    }
    
    var nextMilestone: SavingsMilestone? {
        milestones
            .filter { !$0.isCompleted }
            .sorted { $0.targetAmount < $1.targetAmount }
            .first
    }
    
    var completedMilestones: [SavingsMilestone] {
        milestones.filter { $0.isCompleted }
    }
    
    var totalContributions: Double {
        contributions.reduce(0) { $0 + $1.amount }
    }
    
    init(name: String, description: String = "", targetAmount: Double, targetDate: Date, category: SavingsCategory, priority: GoalPriority = .medium) {
        self.name = name
        self.description = description
        self.targetAmount = targetAmount
        self.currentAmount = 0
        self.targetDate = targetDate
        self.category = category
        self.priority = priority
        self.isCompleted = false
        self.isArchived = false
        self.createdDate = Date()
        self.milestones = []
        self.contributions = []
        self.reminderSettings = GoalReminderSettings()
    }
    
    mutating func addContribution(_ amount: Double, note: String = "") {
        let contribution = SavingsContribution(amount: amount, note: note)
        contributions.append(contribution)
        currentAmount += amount
        
        // Check if goal is completed
        if currentAmount >= targetAmount && !isCompleted {
            isCompleted = true
            completedDate = Date()
        }
        
        // Update milestone completion
        updateMilestoneCompletion()
    }
    
    mutating func updateMilestoneCompletion() {
        for index in milestones.indices {
            if !milestones[index].isCompleted && currentAmount >= milestones[index].targetAmount {
                milestones[index].isCompleted = true
                milestones[index].completedDate = Date()
            }
        }
    }
    
    mutating func addMilestone(_ milestone: SavingsMilestone) {
        milestones.append(milestone)
        milestones.sort { $0.targetAmount < $1.targetAmount }
        updateMilestoneCompletion()
    }
}

struct SavingsMilestone: Identifiable, Codable {
    let id = UUID()
    var name: String
    var targetAmount: Double
    var isCompleted: Bool
    var completedDate: Date?
    var reward: String
    var icon: String
    
    init(name: String, targetAmount: Double, reward: String = "", icon: String = "flag.fill") {
        self.name = name
        self.targetAmount = targetAmount
        self.isCompleted = false
        self.reward = reward
        self.icon = icon
    }
}

struct SavingsContribution: Identifiable, Codable {
    let id = UUID()
    var amount: Double
    var date: Date
    var note: String
    var method: ContributionMethod
    
    init(amount: Double, note: String = "", method: ContributionMethod = .manual) {
        self.amount = amount
        self.date = Date()
        self.note = note
        self.method = method
    }
}

enum SavingsCategory: String, CaseIterable, Codable, Identifiable {
    case emergency = "Emergency Fund"
    case vacation = "Vacation"
    case house = "House Down Payment"
    case car = "Car Purchase"
    case education = "Education"
    case retirement = "Retirement"
    case wedding = "Wedding"
    case gadget = "Electronics"
    case health = "Health & Medical"
    case business = "Business Investment"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .emergency: return "shield.fill"
        case .vacation: return "airplane"
        case .house: return "house.fill"
        case .car: return "car.fill"
        case .education: return "book.fill"
        case .retirement: return "person.fill"
        case .wedding: return "heart.fill"
        case .gadget: return "laptopcomputer"
        case .health: return "cross.fill"
        case .business: return "building.2.fill"
        case .other: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .emergency: return "#FF4444"
        case .vacation: return "#4A90E2"
        case .house: return "#8CC152"
        case .car: return "#FF8800"
        case .education: return "#9B59B6"
        case .retirement: return "#34495E"
        case .wedding: return "#E91E63"
        case .gadget: return "#00BCD4"
        case .health: return "#FF5722"
        case .business: return "#607D8B"
        case .other: return "#95A5A6"
        }
    }
    
    var suggestedMilestones: [String] {
        switch self {
        case .emergency:
            return ["1 Month Expenses", "3 Months Expenses", "6 Months Expenses"]
        case .vacation:
            return ["25% Saved", "50% Saved", "75% Saved", "Trip Booked!"]
        case .house:
            return ["10% Down Payment", "15% Down Payment", "20% Down Payment"]
        case .car:
            return ["25% Saved", "50% Saved", "Full Amount"]
        case .education:
            return ["First Semester", "One Year", "Full Degree"]
        case .retirement:
            return ["First $1,000", "First $10,000", "First $100,000"]
        case .wedding:
            return ["Venue Deposit", "50% Saved", "Wedding Ready!"]
        case .gadget:
            return ["50% Saved", "Ready to Buy!"]
        case .health:
            return ["Deductible Covered", "Full Amount"]
        case .business:
            return ["Initial Investment", "Growth Fund", "Expansion Ready"]
        case .other:
            return ["25% Complete", "50% Complete", "75% Complete", "Goal Achieved!"]
        }
    }
}

enum GoalPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .low: return "#95A5A6"
        case .medium: return "#3498DB"
        case .high: return "#F39C12"
        case .critical: return "#E74C3C"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "minus.circle"
        case .medium: return "equal.circle"
        case .high: return "plus.circle"
        case .critical: return "exclamationmark.circle"
        }
    }
}

enum ContributionMethod: String, CaseIterable, Codable {
    case manual = "Manual"
    case automatic = "Automatic"
    case roundUp = "Round Up"
    case bonus = "Bonus/Gift"
    
    var icon: String {
        switch self {
        case .manual: return "hand.point.up.left.fill"
        case .automatic: return "arrow.clockwise"
        case .roundUp: return "arrow.up.circle"
        case .bonus: return "gift.fill"
        }
    }
}

struct GoalReminderSettings: Codable {
    var enableReminders: Bool
    var reminderFrequency: ReminderFrequency
    var contributionReminders: Bool
    var milestoneAlerts: Bool
    var progressUpdates: Bool
    
    init() {
        self.enableReminders = true
        self.reminderFrequency = .weekly
        self.contributionReminders = true
        self.milestoneAlerts = true
        self.progressUpdates = true
    }
}

enum ReminderFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case never = "Never"
    
    var icon: String {
        switch self {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar"
        case .monthly: return "calendar.circle"
        case .never: return "bell.slash"
        }
    }
}

struct SavingsSummary: Codable {
    var totalGoals: Int
    var activeGoals: Int
    var completedGoals: Int
    var totalTargetAmount: Double
    var totalSavedAmount: Double
    var averageProgress: Double
    var goalsOnTrack: Int
    var overdueGoals: Int
    var lastUpdated: Date
    
    var overallProgress: Double {
        guard totalTargetAmount > 0 else { return 0 }
        return min(totalSavedAmount / totalTargetAmount, 1.0)
    }
    
    var completionRate: Double {
        guard totalGoals > 0 else { return 0 }
        return Double(completedGoals) / Double(totalGoals)
    }
    
    init() {
        self.totalGoals = 0
        self.activeGoals = 0
        self.completedGoals = 0
        self.totalTargetAmount = 0
        self.totalSavedAmount = 0
        self.averageProgress = 0
        self.goalsOnTrack = 0
        self.overdueGoals = 0
        self.lastUpdated = Date()
    }
}
