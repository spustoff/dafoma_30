//
//  BillReminder.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation

struct BillReminder: Identifiable, Codable {
    let id = UUID()
    var title: String
    var amount: Double
    var dueDate: Date
    var frequency: BillFrequency
    var category: ExpenseCategory
    var notes: String
    var isPaid: Bool
    var reminderDays: Int // Days before due date to remind
    var lastPaidDate: Date?
    var isEnabled: Bool
    
    var nextDueDate: Date {
        if isPaid, let lastPaid = lastPaidDate {
            return frequency.nextDate(from: lastPaid)
        }
        return dueDate
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: nextDueDate)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }
    
    var isOverdue: Bool {
        daysUntilDue < 0
    }
    
    var isDueToday: Bool {
        daysUntilDue == 0
    }
    
    var isDueSoon: Bool {
        daysUntilDue > 0 && daysUntilDue <= reminderDays
    }
    
    var statusColor: String {
        if isOverdue { return "#FF4444" }
        if isDueToday { return "#FF8800" }
        if isDueSoon { return "#FFDD00" }
        return "#00AA00"
    }
    
    var statusText: String {
        if isOverdue { return "Overdue" }
        if isDueToday { return "Due Today" }
        if isDueSoon { return "Due Soon" }
        return "On Track"
    }
    
    init(title: String, amount: Double, dueDate: Date, frequency: BillFrequency, category: ExpenseCategory = .bills, notes: String = "", reminderDays: Int = 3) {
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.frequency = frequency
        self.category = category
        self.notes = notes
        self.isPaid = false
        self.reminderDays = reminderDays
        self.isEnabled = true
    }
}

enum BillFrequency: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiannual = "Semi-annual"
    case annual = "Annual"
    case oneTime = "One-time"
    
    var icon: String {
        switch self {
        case .weekly: return "calendar"
        case .biweekly: return "calendar.badge.clock"
        case .monthly: return "calendar.circle"
        case .quarterly: return "calendar.circle.fill"
        case .semiannual: return "calendar.badge.plus"
        case .annual: return "calendar.badge.exclamationmark"
        case .oneTime: return "calendar.badge.minus"
        }
    }
    
    func nextDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .semiannual:
            return calendar.date(byAdding: .month, value: 6, to: date) ?? date
        case .annual:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        case .oneTime:
            return date
        }
    }
}

struct FinancialHealthScore: Codable {
    var overallScore: Int // 0-100
    var savingsRatio: Double
    var debtToIncomeRatio: Double
    var expenseVariability: Double
    var investmentDiversification: Double
    var emergencyFundMonths: Double
    var lastCalculated: Date
    
    var scoreCategory: HealthCategory {
        switch overallScore {
        case 90...100: return .excellent
        case 75..<90: return .good
        case 60..<75: return .fair
        case 40..<60: return .poor
        case 0..<40: return .critical
        default: return .poor
        }
    }
    
    var recommendations: [String] {
        var recs: [String] = []
        
        if savingsRatio < 0.2 {
            recs.append("Try to save at least 20% of your income")
        }
        
        if debtToIncomeRatio > 0.3 {
            recs.append("Consider reducing debt to improve financial health")
        }
        
        if emergencyFundMonths < 3 {
            recs.append("Build an emergency fund covering 3-6 months of expenses")
        }
        
        if investmentDiversification < 0.3 {
            recs.append("Diversify your investment portfolio across different asset types")
        }
        
        if expenseVariability > 0.4 {
            recs.append("Work on creating a more consistent spending pattern")
        }
        
        if recs.isEmpty {
            recs.append("Great job! Keep maintaining your excellent financial habits")
        }
        
        return recs
    }
    
    init() {
        self.overallScore = 0
        self.savingsRatio = 0
        self.debtToIncomeRatio = 0
        self.expenseVariability = 0
        self.investmentDiversification = 0
        self.emergencyFundMonths = 0
        self.lastCalculated = Date()
    }
}

enum HealthCategory: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .excellent: return "#00AA00"
        case .good: return "#88CC00"
        case .fair: return "#FFDD00"
        case .poor: return "#FF8800"
        case .critical: return "#FF4444"
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "heart.fill"
        case .good: return "heart"
        case .fair: return "heart.slash"
        case .poor: return "exclamationmark.triangle"
        case .critical: return "xmark.octagon.fill"
        }
    }
}

