//
//  BudgetViewModel.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import SwiftUI
import Combine

class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var selectedBudget: Budget?
    @Published var showingAddBudget = false
    @Published var showingEditBudget = false
    @Published var showingBudgetDetail = false
    @Published var searchText = ""
    @Published var selectedPeriod: BudgetPeriod = .monthly
    @Published var sortOption: BudgetSortOption = .dateCreated
    
    // Add/Edit budget form
    @Published var budgetName = ""
    @Published var budgetAmount = ""
    @Published var budgetPeriod: BudgetPeriod = .monthly
    @Published var budgetStartDate = Date()
    @Published var budgetEndDate = Date()
    @Published var budgetCategories: [BudgetCategory] = []
    @Published var enableNotifications = true
    @Published var alertThreshold = 80.0
    
    // Category form
    @Published var showingAddCategory = false
    @Published var categoryName = ""
    @Published var categoryLimit = ""
    @Published var categoryExpenseType: ExpenseCategory = .other
    @Published var categoryAlertThreshold = 80.0
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var filteredBudgets: [Budget] {
        var result = budgets
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { budget in
                budget.name.localizedCaseInsensitiveContains(searchText) ||
                budget.categories.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by period
        if selectedPeriod != .custom {
            result = result.filter { $0.period == selectedPeriod }
        }
        
        // Sort
        switch sortOption {
        case .dateCreated:
            result = result.sorted { $0.createdDate > $1.createdDate }
        case .name:
            result = result.sorted { $0.name < $1.name }
        case .amount:
            result = result.sorted { $0.totalBudget > $1.totalBudget }
        case .progress:
            result = result.sorted { $0.budgetProgress > $1.budgetProgress }
        case .remaining:
            result = result.sorted { $0.remainingBudget > $1.remainingBudget }
        }
        
        return result
    }
    
    var activeBudgets: [Budget] {
        budgets.filter { $0.isActive && !$0.isExpired }
    }
    
    var totalBudgetAmount: Double {
        activeBudgets.reduce(0) { $0 + $1.totalBudget }
    }
    
    var totalSpentAmount: Double {
        activeBudgets.reduce(0) { $0 + $1.totalSpent }
    }
    
    var overallProgress: Double {
        guard totalBudgetAmount > 0 else { return 0 }
        return min(totalSpentAmount / totalBudgetAmount, 1.0)
    }
    
    var budgetsOverLimit: Int {
        activeBudgets.filter { $0.isOverBudget }.count
    }
    
    var categoriesNeedingAttention: [BudgetCategory] {
        activeBudgets.flatMap { $0.categories }
            .filter { $0.shouldAlert || $0.isOverBudget }
            .sorted { $0.spentPercentage > $1.spentPercentage }
    }
    
    var canSaveBudget: Bool {
        !budgetName.isEmpty && 
        !budgetAmount.isEmpty && 
        Double(budgetAmount) != nil &&
        !budgetCategories.isEmpty
    }
    
    var canSaveCategory: Bool {
        !categoryName.isEmpty && 
        !categoryLimit.isEmpty && 
        Double(categoryLimit) != nil
    }
    
    init() {
        setupBindings()
        updateBudgetEndDate()
    }
    
    private func setupBindings() {
        dataService.$budgets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] budgets in
                self?.budgets = budgets
            }
            .store(in: &cancellables)
        
        // Auto-update end date when period changes
        $budgetPeriod
            .sink { [weak self] _ in
                self?.updateBudgetEndDate()
            }
            .store(in: &cancellables)
    }
    
    private func updateBudgetEndDate() {
        budgetEndDate = budgetPeriod.endDate(from: budgetStartDate)
    }
    
    // MARK: - Budget Management
    
    func addBudget() {
        guard canSaveBudget,
              let amount = Double(budgetAmount) else { return }
        
        var budget = Budget(
            name: budgetName,
            totalBudget: amount,
            period: budgetPeriod,
            startDate: budgetStartDate
        )
        
        budget.categories = budgetCategories
        budget.notifications.enableAlerts = enableNotifications
        budget.notifications.alertThreshold = alertThreshold / 100.0
        
        dataService.addBudget(budget)
        clearBudgetForm()
        showingAddBudget = false
    }
    
    func updateBudget() {
        guard let budget = selectedBudget,
              canSaveBudget,
              let amount = Double(budgetAmount) else { return }
        
        var updatedBudget = budget
        updatedBudget.name = budgetName
        updatedBudget.totalBudget = amount
        updatedBudget.period = budgetPeriod
        updatedBudget.startDate = budgetStartDate
        updatedBudget.endDate = budgetEndDate
        updatedBudget.categories = budgetCategories
        updatedBudget.notifications.enableAlerts = enableNotifications
        updatedBudget.notifications.alertThreshold = alertThreshold / 100.0
        
        dataService.updateBudget(updatedBudget)
        clearBudgetForm()
        showingEditBudget = false
        selectedBudget = nil
    }
    
    func deleteBudget(_ budget: Budget) {
        dataService.deleteBudget(budget)
    }
    
    func editBudget(_ budget: Budget) {
        selectedBudget = budget
        budgetName = budget.name
        budgetAmount = String(budget.totalBudget)
        budgetPeriod = budget.period
        budgetStartDate = budget.startDate
        budgetEndDate = budget.endDate
        budgetCategories = budget.categories
        enableNotifications = budget.notifications.enableAlerts
        alertThreshold = budget.notifications.alertThreshold * 100
        showingEditBudget = true
    }
    
    func toggleBudgetStatus(_ budget: Budget) {
        var updatedBudget = budget
        updatedBudget.isActive.toggle()
        dataService.updateBudget(updatedBudget)
    }
    
    func clearBudgetForm() {
        budgetName = ""
        budgetAmount = ""
        budgetPeriod = .monthly
        budgetStartDate = Date()
        budgetCategories = []
        enableNotifications = true
        alertThreshold = 80.0
        updateBudgetEndDate()
    }
    
    // MARK: - Category Management
    
    func addCategoryToBudget() {
        guard canSaveCategory,
              let limit = Double(categoryLimit) else { return }
        
        let category = BudgetCategory(
            name: categoryName,
            limit: limit,
            expenseCategory: categoryExpenseType,
            alertThreshold: categoryAlertThreshold / 100.0
        )
        
        budgetCategories.append(category)
        clearCategoryForm()
        showingAddCategory = false
    }
    
    func removeCategoryFromBudget(_ category: BudgetCategory) {
        budgetCategories.removeAll { $0.id == category.id }
    }
    
    func clearCategoryForm() {
        categoryName = ""
        categoryLimit = ""
        categoryExpenseType = .other
        categoryAlertThreshold = 80.0
    }
    
    // MARK: - Utility Functions
    
    func clearFilters() {
        searchText = ""
        selectedPeriod = .monthly
        sortOption = .dateCreated
    }
    
    func getBudgetProgress(_ budget: Budget) -> Double {
        return budget.budgetProgress
    }
    
    func getBudgetStatusColor(_ budget: Budget) -> Color {
        if budget.isOverBudget {
            return .red
        } else if budget.budgetProgress >= 0.8 {
            return .orange
        } else if budget.budgetProgress >= 0.6 {
            return Color(hex: "#fbd600")
        } else {
            return .green
        }
    }
    
    func getCategoryStatusColor(_ category: BudgetCategory) -> Color {
        return Color(hex: category.statusColor)
    }
    
    func getRecommendations() -> [String] {
        var recommendations: [String] = []
        
        if overallProgress > 0.9 {
            recommendations.append("You're spending close to your budget limits. Consider reducing non-essential expenses.")
        }
        
        if budgetsOverLimit > 0 {
            recommendations.append("You have \(budgetsOverLimit) budget(s) over limit. Review your spending in these areas.")
        }
        
        let highSpendingCategories = categoriesNeedingAttention.prefix(3)
        if !highSpendingCategories.isEmpty {
            let categoryNames = highSpendingCategories.map { $0.name }.joined(separator: ", ")
            recommendations.append("Monitor spending in: \(categoryNames)")
        }
        
        if activeBudgets.isEmpty {
            recommendations.append("Create your first budget to start tracking your spending effectively.")
        }
        
        if recommendations.isEmpty {
            recommendations.append("Great job staying within your budgets! Keep up the good work.")
        }
        
        return recommendations
    }
}

enum BudgetSortOption: String, CaseIterable {
    case dateCreated = "Date Created"
    case name = "Name"
    case amount = "Budget Amount"
    case progress = "Progress"
    case remaining = "Remaining"
    
    var icon: String {
        switch self {
        case .dateCreated: return "calendar"
        case .name: return "textformat"
        case .amount: return "dollarsign.circle"
        case .progress: return "chart.bar"
        case .remaining: return "minus.circle"
        }
    }
}
