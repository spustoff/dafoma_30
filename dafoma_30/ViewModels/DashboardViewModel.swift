//
//  DashboardViewModel.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var selectedTimePeriod: TimePeriod = .month
    @Published var isZenModeActive = false
    @Published var showingExpenseDetail = false
    @Published var showingInvestmentDetail = false
    @Published var showingAddExpense = false
    @Published var showingAddInvestment = false
    
    @AppStorage("userFinancialTheme") var userFinancialTheme = "neon"
    @AppStorage("userMonthlyBudget") var userMonthlyBudget = 0.0
    @AppStorage("userName") var userName = ""
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var currentTheme: FinancialTheme {
        FinancialTheme(rawValue: userFinancialTheme) ?? .neon
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName.isEmpty ? "User" : userName
        
        switch hour {
        case 0..<12:
            return "Good Morning, \(name)"
        case 12..<17:
            return "Good Afternoon, \(name)"
        default:
            return "Good Evening, \(name)"
        }
    }
    
    var totalExpenses: Double {
        dataService.getExpenses(for: selectedTimePeriod).reduce(0) { $0 + $1.amount }
    }
    
    var totalInvestmentValue: Double {
        dataService.portfolio.totalValue
    }
    
    var totalInvestmentGainLoss: Double {
        dataService.portfolio.totalGainLoss
    }
    
    var investmentGainLossPercentage: Double {
        dataService.portfolio.totalGainLossPercentage
    }
    
    var budgetProgress: Double {
        guard userMonthlyBudget > 0 else { return 0 }
        let monthlyExpenses = dataService.getExpenses(for: .month).reduce(0) { $0 + $1.amount }
        return min(monthlyExpenses / userMonthlyBudget, 1.0)
    }
    
    var budgetRemaining: Double {
        let monthlyExpenses = dataService.getExpenses(for: .month).reduce(0) { $0 + $1.amount }
        return max(userMonthlyBudget - monthlyExpenses, 0)
    }
    
    var isOverBudget: Bool {
        budgetProgress >= 1.0
    }
    
    var recentExpenses: [Expense] {
        Array(dataService.expenses.sorted { $0.date > $1.date }.prefix(5))
    }
    
    var topInvestments: [Investment] {
        Array(dataService.investments.sorted { $0.totalValue > $1.totalValue }.prefix(3))
    }
    
    var expensesByCategory: [(category: ExpenseCategory, amount: Double, percentage: Double)] {
        let expenses = dataService.getExpenses(for: selectedTimePeriod)
        let total = expenses.reduce(0) { $0 + $1.amount }
        
        guard total > 0 else { return [] }
        
        var categoryTotals: [ExpenseCategory: Double] = [:]
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        
        return categoryTotals.map { (category, amount) in
            (category: category, amount: amount, percentage: (amount / total) * 100)
        }.sorted { $0.amount > $1.amount }
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$expenses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        dataService.$investments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func toggleZenMode() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isZenModeActive.toggle()
        }
    }
    
    func refreshData() {
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.objectWillChange.send()
        }
    }
    
    func getFinancialInsight() -> String {
        let monthlyExpenses = dataService.getExpenses(for: .month).reduce(0) { $0 + $1.amount }
        let previousMonthExpenses = getPreviousMonthExpenses()
        
        if monthlyExpenses > previousMonthExpenses {
            let increase = ((monthlyExpenses - previousMonthExpenses) / previousMonthExpenses) * 100
            return "Your spending increased by \(String(format: "%.1f", increase))% this month"
        } else if monthlyExpenses < previousMonthExpenses {
            let decrease = ((previousMonthExpenses - monthlyExpenses) / previousMonthExpenses) * 100
            return "Great job! You saved \(String(format: "%.1f", decrease))% compared to last month"
        } else {
            return "Your spending is consistent with last month"
        }
    }
    
    private func getPreviousMonthExpenses() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: now) ?? now
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        return dataService.expenses
            .filter { $0.date >= twoMonthsAgo && $0.date < oneMonthAgo }
            .reduce(0) { $0 + $1.amount }
    }
}


