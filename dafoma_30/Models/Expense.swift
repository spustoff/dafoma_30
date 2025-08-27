//
//  Expense.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation

struct Expense: Identifiable, Codable {
    let id = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var description: String
    var tags: [String]
    var isRecurring: Bool
    
    init(title: String, amount: Double, category: ExpenseCategory, date: Date = Date(), description: String = "", tags: [String] = [], isRecurring: Bool = false) {
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.description = description
        self.tags = tags
        self.isRecurring = isRecurring
    }
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food & Dining"
    case transportation = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case bills = "Bills & Utilities"
    case healthcare = "Healthcare"
    case education = "Education"
    case travel = "Travel"
    case lifestyle = "Lifestyle"
    case investment = "Investment"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .bills: return "doc.text.fill"
        case .healthcare: return "cross.fill"
        case .education: return "book.fill"
        case .travel: return "airplane"
        case .lifestyle: return "heart.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "#FF6B6B"
        case .transportation: return "#4ECDC4"
        case .shopping: return "#45B7D1"
        case .entertainment: return "#96CEB4"
        case .bills: return "#FFEAA7"
        case .healthcare: return "#DDA0DD"
        case .education: return "#98D8C8"
        case .travel: return "#F7DC6F"
        case .lifestyle: return "#BB8FCE"
        case .investment: return "#85C1E9"
        case .other: return "#D5DBDB"
        }
    }
}

struct ExpenseSummary: Codable {
    var totalExpenses: Double
    var monthlyExpenses: Double
    var weeklyExpenses: Double
    var dailyExpenses: Double
    var categoryBreakdown: [ExpenseCategory: Double]
    var lastUpdated: Date
    
    init() {
        self.totalExpenses = 0
        self.monthlyExpenses = 0
        self.weeklyExpenses = 0
        self.dailyExpenses = 0
        self.categoryBreakdown = [:]
        self.lastUpdated = Date()
    }
}
