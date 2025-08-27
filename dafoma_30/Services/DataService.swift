//
//  DataService.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var expenses: [Expense] = []
    @Published var investments: [Investment] = []
    @Published var portfolio: Portfolio = Portfolio()
    @Published var expenseSummary: ExpenseSummary = ExpenseSummary()
    
    private let expensesKey = "NeonFiscal_Expenses"
    private let investmentsKey = "NeonFiscal_Investments"
    private let portfolioKey = "NeonFiscal_Portfolio"
    private let summaryKey = "NeonFiscal_Summary"
    
    private init() {
        loadData()
        updateSummary()
        updatePortfolio()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        loadExpenses()
        loadInvestments()
        loadPortfolio()
        loadSummary()
    }
    
    private func saveData() {
        saveExpenses()
        saveInvestments()
        savePortfolio()
        saveSummary()
    }
    
    // MARK: - Expenses Management
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        updateSummary()
        saveExpenses()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            updateSummary()
            saveExpenses()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        updateSummary()
        saveExpenses()
    }
    
    func getExpenses(for period: TimePeriod) -> [Expense] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .today:
            return expenses.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return expenses.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return expenses.filter { $0.date >= yearAgo }
        case .all:
            return expenses
        }
    }
    
    // MARK: - Investments Management
    
    func addInvestment(_ investment: Investment) {
        investments.append(investment)
        updatePortfolio()
        saveInvestments()
    }
    
    func updateInvestment(_ investment: Investment) {
        if let index = investments.firstIndex(where: { $0.id == investment.id }) {
            investments[index] = investment
            updatePortfolio()
            saveInvestments()
        }
    }
    
    func deleteInvestment(_ investment: Investment) {
        investments.removeAll { $0.id == investment.id }
        updatePortfolio()
        saveInvestments()
    }
    
    func updateInvestmentPrice(_ investmentId: UUID, newPrice: Double) {
        if let index = investments.firstIndex(where: { $0.id == investmentId }) {
            investments[index].currentPrice = newPrice
            updatePortfolio()
            saveInvestments()
        }
    }
    
    // MARK: - Summary Calculations
    
    private func updateSummary() {
        let calendar = Calendar.current
        let now = Date()
        
        expenseSummary.totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        
        // Monthly expenses
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        expenseSummary.monthlyExpenses = expenses
            .filter { $0.date >= monthAgo }
            .reduce(0) { $0 + $1.amount }
        
        // Weekly expenses
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        expenseSummary.weeklyExpenses = expenses
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.amount }
        
        // Daily expenses
        expenseSummary.dailyExpenses = expenses
            .filter { calendar.isDate($0.date, inSameDayAs: now) }
            .reduce(0) { $0 + $1.amount }
        
        // Category breakdown
        var categoryBreakdown: [ExpenseCategory: Double] = [:]
        for expense in expenses {
            categoryBreakdown[expense.category, default: 0] += expense.amount
        }
        expenseSummary.categoryBreakdown = categoryBreakdown
        expenseSummary.lastUpdated = Date()
        
        saveSummary()
    }
    
    private func updatePortfolio() {
        portfolio.investments = investments
        portfolio.lastUpdated = Date()
        savePortfolio()
    }
    
    // MARK: - Sample Data
    
    func loadSampleData() {
        // Sample expenses
        let sampleExpenses = [
            Expense(title: "Coffee", amount: 4.50, category: .food, date: Date(), description: "Morning coffee", tags: ["daily", "caffeine"]),
            Expense(title: "Uber Ride", amount: 12.30, category: .transportation, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), description: "Ride to work"),
            Expense(title: "Grocery Shopping", amount: 85.20, category: .food, date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), description: "Weekly groceries", tags: ["weekly", "essentials"]),
            Expense(title: "Netflix Subscription", amount: 15.99, category: .entertainment, date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), description: "Monthly subscription", isRecurring: true),
            Expense(title: "Gym Membership", amount: 49.99, category: .lifestyle, date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), description: "Monthly gym fee", isRecurring: true)
        ]
        
        // Sample investments
        let sampleInvestments = [
            Investment(symbol: "AAPL", name: "Apple Inc.", shares: 10, purchasePrice: 150.00, currentPrice: 175.50, purchaseDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(), type: .stocks),
            Investment(symbol: "TSLA", name: "Tesla Inc.", shares: 5, purchasePrice: 200.00, currentPrice: 185.25, purchaseDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(), type: .stocks),
            Investment(symbol: "BTC", name: "Bitcoin", shares: 0.5, purchasePrice: 45000.00, currentPrice: 52000.00, purchaseDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(), type: .crypto),
            Investment(symbol: "SPY", name: "SPDR S&P 500 ETF", shares: 20, purchasePrice: 400.00, currentPrice: 425.75, purchaseDate: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(), type: .etf)
        ]
        
        expenses = sampleExpenses
        investments = sampleInvestments
        
        updateSummary()
        updatePortfolio()
        saveData()
    }
    
    // MARK: - Private Storage Methods
    
    private func saveExpenses() {
        if let data = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(data, forKey: expensesKey)
        }
    }
    
    private func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: expensesKey),
           let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decodedExpenses
        }
    }
    
    private func saveInvestments() {
        if let data = try? JSONEncoder().encode(investments) {
            UserDefaults.standard.set(data, forKey: investmentsKey)
        }
    }
    
    private func loadInvestments() {
        if let data = UserDefaults.standard.data(forKey: investmentsKey),
           let decodedInvestments = try? JSONDecoder().decode([Investment].self, from: data) {
            investments = decodedInvestments
        }
    }
    
    private func savePortfolio() {
        if let data = try? JSONEncoder().encode(portfolio) {
            UserDefaults.standard.set(data, forKey: portfolioKey)
        }
    }
    
    private func loadPortfolio() {
        if let data = UserDefaults.standard.data(forKey: portfolioKey),
           let decodedPortfolio = try? JSONDecoder().decode(Portfolio.self, from: data) {
            portfolio = decodedPortfolio
        }
    }
    
    private func saveSummary() {
        if let data = try? JSONEncoder().encode(expenseSummary) {
            UserDefaults.standard.set(data, forKey: summaryKey)
        }
    }
    
    private func loadSummary() {
        if let data = UserDefaults.standard.data(forKey: summaryKey),
           let decodedSummary = try? JSONDecoder().decode(ExpenseSummary.self, from: data) {
            expenseSummary = decodedSummary
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
    case year = "This Year"
    case all = "All Time"
}
