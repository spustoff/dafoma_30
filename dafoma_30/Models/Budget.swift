//
//  Budget.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation

struct Budget: Identifiable, Codable {
    var id = UUID()
    var name: String
    var totalBudget: Double
    var period: BudgetPeriod
    var categories: [BudgetCategory]
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var notifications: BudgetNotifications
    var createdDate: Date
    
    var totalAllocated: Double {
        categories.reduce(0) { $0 + $1.limit }
    }
    
    var totalSpent: Double {
        categories.reduce(0) { $0 + $1.spent }
    }
    
    var remainingBudget: Double {
        max(totalBudget - totalSpent, 0)
    }
    
    var budgetProgress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(totalSpent / totalBudget, 1.0)
    }
    
    var isOverBudget: Bool {
        totalSpent > totalBudget
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: endDate)
        return calendar.dateComponents([.day], from: today, to: end).day ?? 0
    }
    
    var isExpired: Bool {
        Date() > endDate
    }
    
    init(name: String, totalBudget: Double, period: BudgetPeriod, startDate: Date = Date()) {
        self.name = name
        self.totalBudget = totalBudget
        self.period = period
        self.categories = []
        self.startDate = startDate
        self.endDate = period.endDate(from: startDate)
        self.isActive = true
        self.notifications = BudgetNotifications()
        self.createdDate = Date()
    }
}

struct BudgetCategory: Identifiable, Codable {
    var id = UUID()
    var name: String
    var limit: Double
    var spent: Double
    var expenseCategory: ExpenseCategory
    var color: String
    var icon: String
    var alertThreshold: Double // Percentage (0.0 - 1.0)
    var isEnabled: Bool
    
    var remainingAmount: Double {
        max(limit - spent, 0)
    }
    
    var spentPercentage: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }
    
    var isOverBudget: Bool {
        spent > limit
    }
    
    var shouldAlert: Bool {
        spentPercentage >= alertThreshold
    }
    
    var statusColor: String {
        if isOverBudget { return "#FF4444" }
        if spentPercentage >= alertThreshold { return "#FF8800" }
        if spentPercentage >= 0.7 { return "#FFDD00" }
        return "#00AA00"
    }
    
    init(name: String, limit: Double, expenseCategory: ExpenseCategory, alertThreshold: Double = 0.8) {
        self.name = name
        self.limit = limit
        self.spent = 0
        self.expenseCategory = expenseCategory
        self.color = expenseCategory.color
        self.icon = expenseCategory.icon
        self.alertThreshold = alertThreshold
        self.isEnabled = true
    }
}

enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .weekly: return "calendar"
        case .biweekly: return "calendar.badge.clock"
        case .monthly: return "calendar.circle"
        case .quarterly: return "calendar.circle.fill"
        case .yearly: return "calendar.badge.exclamationmark"
        case .custom: return "calendar.badge.plus"
        }
    }
    
    func endDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: startDate) ?? startDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: startDate) ?? startDate
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        case .custom:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        }
    }
}

struct BudgetNotifications: Codable {
    var enableAlerts: Bool
    var alertThreshold: Double // Percentage
    var dailyReminders: Bool
    var weeklyReports: Bool
    var overBudgetAlerts: Bool
    
    init() {
        self.enableAlerts = true
        self.alertThreshold = 0.8
        self.dailyReminders = false
        self.weeklyReports = true
        self.overBudgetAlerts = true
    }
}

struct BudgetSummary: Codable {
    var totalBudgets: Int
    var activeBudgets: Int
    var totalBudgetAmount: Double
    var totalSpent: Double
    var averageSpendingRate: Double
    var categoriesOverBudget: Int
    var lastUpdated: Date
    
    var overallProgress: Double {
        guard totalBudgetAmount > 0 else { return 0 }
        return min(totalSpent / totalBudgetAmount, 1.0)
    }
    
    var isOnTrack: Bool {
        overallProgress <= 0.8
    }
    
    init() {
        self.totalBudgets = 0
        self.activeBudgets = 0
        self.totalBudgetAmount = 0
        self.totalSpent = 0
        self.averageSpendingRate = 0
        self.categoriesOverBudget = 0
        self.lastUpdated = Date()
    }
}

enum TimePeriod: String, CaseIterable, Codable {
    case day = "Today"
    case week = "This Week"
    case month = "This Month"
    case quarter = "This Quarter"
    case year = "This Year"
    case all = "All Time"
    
    var icon: String {
        switch self {
        case .day: return "sun.max.fill"
        case .week: return "calendar"
        case .month: return "calendar.circle"
        case .quarter: return "calendar.circle.fill"
        case .year: return "calendar.badge.exclamationmark"
        case .all: return "infinity"
        }
    }
}
