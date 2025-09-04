//
//  DataService.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import SwiftUI
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var expenses: [Expense] = []
    @Published var investments: [Investment] = []
    @Published var budgets: [Budget] = []
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var billReminders: [BillReminder] = []
    @Published var financialHealthScore: FinancialHealthScore = FinancialHealthScore()
    
    var portfolio: Portfolio {
        Portfolio(investments: investments)
    }
    
    private let userDefaults = UserDefaults.standard
    private let expensesKey = "SavedExpenses"
    private let investmentsKey = "SavedInvestments"
    private let budgetsKey = "SavedBudgets"
    private let savingsGoalsKey = "SavedSavingsGoals"
    private let billRemindersKey = "SavedBillReminders"
    private let financialHealthKey = "SavedFinancialHealth"
    
    private init() {
        loadData()
        updateFinancialHealthScore()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        loadExpenses()
        loadInvestments()
        loadBudgets()
        loadSavingsGoals()
        loadBillReminders()
        loadFinancialHealth()
    }
    
    private func loadExpenses() {
        if let data = userDefaults.data(forKey: expensesKey),
           let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decodedExpenses
        }
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            userDefaults.set(encoded, forKey: expensesKey)
        }
    }
    
    private func loadInvestments() {
        if let data = userDefaults.data(forKey: investmentsKey),
           let decodedInvestments = try? JSONDecoder().decode([Investment].self, from: data) {
            investments = decodedInvestments
        }
    }
    
    private func saveInvestments() {
        if let encoded = try? JSONEncoder().encode(investments) {
            userDefaults.set(encoded, forKey: investmentsKey)
        }
    }
    
    private func loadBudgets() {
        if let data = userDefaults.data(forKey: budgetsKey),
           let decodedBudgets = try? JSONDecoder().decode([Budget].self, from: data) {
            budgets = decodedBudgets
        }
    }
    
    private func saveBudgets() {
        if let encoded = try? JSONEncoder().encode(budgets) {
            userDefaults.set(encoded, forKey: budgetsKey)
        }
    }
    
    private func loadSavingsGoals() {
        if let data = userDefaults.data(forKey: savingsGoalsKey),
           let decodedGoals = try? JSONDecoder().decode([SavingsGoal].self, from: data) {
            savingsGoals = decodedGoals
        }
    }
    
    private func saveSavingsGoals() {
        if let encoded = try? JSONEncoder().encode(savingsGoals) {
            userDefaults.set(encoded, forKey: savingsGoalsKey)
        }
    }
    
    private func loadBillReminders() {
        if let data = userDefaults.data(forKey: billRemindersKey),
           let decodedBills = try? JSONDecoder().decode([BillReminder].self, from: data) {
            billReminders = decodedBills
        }
    }
    
    private func saveBillReminders() {
        if let encoded = try? JSONEncoder().encode(billReminders) {
            userDefaults.set(encoded, forKey: billRemindersKey)
        }
    }
    
    private func loadFinancialHealth() {
        if let data = userDefaults.data(forKey: financialHealthKey),
           let decodedHealth = try? JSONDecoder().decode(FinancialHealthScore.self, from: data) {
            financialHealthScore = decodedHealth
        }
    }
    
    private func saveFinancialHealth() {
        if let encoded = try? JSONEncoder().encode(financialHealthScore) {
            userDefaults.set(encoded, forKey: financialHealthKey)
        }
    }
    
    // MARK: - Expense Management
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
        updateBudgetSpending()
        updateFinancialHealthScore()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpenses()
            updateBudgetSpending()
            updateFinancialHealthScore()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
        updateBudgetSpending()
        updateFinancialHealthScore()
    }
    
    func getExpenses(for period: TimePeriod) -> [Expense] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .day:
            return expenses.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return expenses.filter { $0.date >= weekStart }
        case .month:
            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return expenses.filter { $0.date >= monthStart }
        case .quarter:
            let quarterStart = calendar.dateInterval(of: .quarter, for: now)?.start ?? now
            return expenses.filter { $0.date >= quarterStart }
        case .year:
            let yearStart = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return expenses.filter { $0.date >= yearStart }
        case .all:
            return expenses
        }
    }
    
    // MARK: - Investment Management
    
    func addInvestment(_ investment: Investment) {
        investments.append(investment)
        saveInvestments()
        updateFinancialHealthScore()
    }
    
    func updateInvestment(_ investment: Investment) {
        if let index = investments.firstIndex(where: { $0.id == investment.id }) {
            investments[index] = investment
            saveInvestments()
            updateFinancialHealthScore()
        }
    }
    
    func deleteInvestment(_ investment: Investment) {
        investments.removeAll { $0.id == investment.id }
        saveInvestments()
        updateFinancialHealthScore()
    }
    
    // MARK: - Budget Management
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveBudgets()
        updateBudgetSpending()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    func getActiveBudgets() -> [Budget] {
        return budgets.filter { $0.isActive && !$0.isExpired }
    }
    
    private func updateBudgetSpending() {
        for budgetIndex in budgets.indices {
            guard budgets[budgetIndex].isActive else { continue }
            
            let budgetExpenses = getExpensesForBudgetPeriod(budgets[budgetIndex])
            
            for categoryIndex in budgets[budgetIndex].categories.indices {
                let category = budgets[budgetIndex].categories[categoryIndex].expenseCategory
                let spent = budgetExpenses
                    .filter { $0.category == category }
                    .reduce(0) { $0 + $1.amount }
                
                budgets[budgetIndex].categories[categoryIndex].spent = spent
            }
        }
        saveBudgets()
    }
    
    private func getExpensesForBudgetPeriod(_ budget: Budget) -> [Expense] {
        return expenses.filter { expense in
            expense.date >= budget.startDate && expense.date <= budget.endDate
        }
    }
    
    // MARK: - Savings Goals Management
    
    func addSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.append(goal)
        saveSavingsGoals()
        updateFinancialHealthScore()
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) {
        if let index = savingsGoals.firstIndex(where: { $0.id == goal.id }) {
            savingsGoals[index] = goal
            saveSavingsGoals()
            updateFinancialHealthScore()
        }
    }
    
    func deleteSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.removeAll { $0.id == goal.id }
        saveSavingsGoals()
        updateFinancialHealthScore()
    }
    
    func addContributionToGoal(_ goalId: UUID, amount: Double, note: String = "") {
        if let index = savingsGoals.firstIndex(where: { $0.id == goalId }) {
            savingsGoals[index].addContribution(amount, note: note)
            saveSavingsGoals()
            updateFinancialHealthScore()
        }
    }
    
    func getActiveSavingsGoals() -> [SavingsGoal] {
        return savingsGoals.filter { !$0.isCompleted && !$0.isArchived }
    }
    
    func getCompletedSavingsGoals() -> [SavingsGoal] {
        return savingsGoals.filter { $0.isCompleted }
    }
    
    // MARK: - Bill Reminders Management
    
    func addBillReminder(_ bill: BillReminder) {
        billReminders.append(bill)
        saveBillReminders()
    }
    
    func updateBillReminder(_ bill: BillReminder) {
        if let index = billReminders.firstIndex(where: { $0.id == bill.id }) {
            billReminders[index] = bill
            saveBillReminders()
        }
    }
    
    func deleteBillReminder(_ bill: BillReminder) {
        billReminders.removeAll { $0.id == bill.id }
        saveBillReminders()
    }
    
    func getUpcomingBills() -> [BillReminder] {
        return billReminders
            .filter { $0.isEnabled && !$0.isPaid }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }
    
    func getOverdueBills() -> [BillReminder] {
        return billReminders.filter { $0.isEnabled && $0.isOverdue }
    }
    
    // MARK: - Financial Health Calculation
    
    func updateFinancialHealthScore() {
        let monthlyExpenses = getExpenses(for: .month).reduce(0) { $0 + $1.amount }
        let monthlyIncome = 5000.0 // This would come from user input in a real app
        let _ = portfolio.totalValue // Used for future financial health calculations
        let totalDebt = 0.0 // This would be tracked separately in a real app
        
        // Calculate savings ratio (simplified)
        let monthlySavings = max(monthlyIncome - monthlyExpenses, 0)
        let savingsRatio = monthlyIncome > 0 ? monthlySavings / monthlyIncome : 0
        
        // Calculate debt-to-income ratio
        let debtToIncomeRatio = monthlyIncome > 0 ? totalDebt / monthlyIncome : 0
        
        // Calculate expense variability (simplified)
        let recentExpenses = getExpenses(for: .quarter)
        let monthlyExpenseAmounts = Dictionary(grouping: recentExpenses) { expense in
            Calendar.current.dateInterval(of: .month, for: expense.date)?.start ?? expense.date
        }.mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        let expenseValues = Array(monthlyExpenseAmounts.values)
        let averageMonthlyExpense = expenseValues.isEmpty ? 0 : expenseValues.reduce(0, +) / Double(expenseValues.count)
        let expenseVariability = expenseValues.isEmpty ? 0 : 
            sqrt(expenseValues.map { pow($0 - averageMonthlyExpense, 2) }.reduce(0, +) / Double(expenseValues.count)) / averageMonthlyExpense
        
        // Calculate investment diversification
        let investmentTypes = Set(investments.map { $0.type })
        let investmentDiversification = min(Double(investmentTypes.count) / 5.0, 1.0) // Max 5 types for full diversification
        
        // Calculate emergency fund months
        let totalSavings = savingsGoals.filter { $0.category == .emergency }.reduce(0) { $0 + $1.currentAmount }
        let emergencyFundMonths = monthlyExpenses > 0 ? totalSavings / monthlyExpenses : 0
        
        // Calculate overall score
        let savingsScore = min(savingsRatio / 0.2, 1.0) * 25 // 25 points max
        let debtScore = max(1 - (debtToIncomeRatio / 0.3), 0) * 20 // 20 points max
        let expenseScore = max(1 - expenseVariability, 0) * 15 // 15 points max
        let investmentScore = investmentDiversification * 20 // 20 points max
        let emergencyScore = min(emergencyFundMonths / 6.0, 1.0) * 20 // 20 points max
        
        let overallScore = Int(savingsScore + debtScore + expenseScore + investmentScore + emergencyScore)
        
        financialHealthScore = FinancialHealthScore()
        financialHealthScore.overallScore = overallScore
        financialHealthScore.savingsRatio = savingsRatio
        financialHealthScore.debtToIncomeRatio = debtToIncomeRatio
        financialHealthScore.expenseVariability = expenseVariability
        financialHealthScore.investmentDiversification = investmentDiversification
        financialHealthScore.emergencyFundMonths = emergencyFundMonths
        financialHealthScore.lastCalculated = Date()
        
        saveFinancialHealth()
    }
}
