//
//  ExpenseViewModel.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import SwiftUI
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var selectedCategory: ExpenseCategory? = nil
    @Published var selectedTimePeriod: TimePeriod = .month
    @Published var searchText = ""
    @Published var showingAddExpense = false
    @Published var showingEditExpense = false
    @Published var selectedExpense: Expense? = nil
    @Published var sortOption: SortOption = .dateDescending
    
    // Add/Edit expense form
    @Published var expenseTitle = ""
    @Published var expenseAmount = ""
    @Published var expenseCategory: ExpenseCategory = .other
    @Published var expenseDate = Date()
    @Published var expenseDescription = ""
    @Published var expenseTags = ""
    @Published var isRecurring = false
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var filteredExpenses: [Expense] {
        var result = dataService.getExpenses(for: selectedTimePeriod)
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { expense in
                expense.title.localizedCaseInsensitiveContains(searchText) ||
                expense.description.localizedCaseInsensitiveContains(searchText) ||
                expense.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort
        switch sortOption {
        case .dateAscending:
            result = result.sorted { $0.date < $1.date }
        case .dateDescending:
            result = result.sorted { $0.date > $1.date }
        case .amountAscending:
            result = result.sorted { $0.amount < $1.amount }
        case .amountDescending:
            result = result.sorted { $0.amount > $1.amount }
        case .titleAscending:
            result = result.sorted { $0.title < $1.title }
        case .titleDescending:
            result = result.sorted { $0.title > $1.title }
        }
        
        return result
    }
    
    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var averageAmount: Double {
        guard !filteredExpenses.isEmpty else { return 0 }
        return totalAmount / Double(filteredExpenses.count)
    }
    
    var expensesByCategory: [(category: ExpenseCategory, amount: Double, count: Int)] {
        let expenses = filteredExpenses
        var categoryData: [ExpenseCategory: (amount: Double, count: Int)] = [:]
        
        for expense in expenses {
            let current = categoryData[expense.category] ?? (amount: 0, count: 0)
            categoryData[expense.category] = (
                amount: current.amount + expense.amount,
                count: current.count + 1
            )
        }
        
        return categoryData.map { (category, data) in
            (category: category, amount: data.amount, count: data.count)
        }.sorted { $0.amount > $1.amount }
    }
    
    var canSaveExpense: Bool {
        !expenseTitle.isEmpty && !expenseAmount.isEmpty && Double(expenseAmount) != nil
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$expenses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expenses in
                self?.expenses = expenses
            }
            .store(in: &cancellables)
    }
    
    func addExpense() {
        guard canSaveExpense,
              let amount = Double(expenseAmount) else { return }
        
        let tags = expenseTags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let expense = Expense(
            title: expenseTitle,
            amount: amount,
            category: expenseCategory,
            date: expenseDate,
            description: expenseDescription,
            tags: tags,
            isRecurring: isRecurring
        )
        
        dataService.addExpense(expense)
        clearForm()
        showingAddExpense = false
    }
    
    func updateExpense() {
        guard let _ = selectedExpense,
              canSaveExpense,
              let amount = Double(expenseAmount) else { return }
        
        let tags = expenseTags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let updatedExpense = Expense(
            title: expenseTitle,
            amount: amount,
            category: expenseCategory,
            date: expenseDate,
            description: expenseDescription,
            tags: tags,
            isRecurring: isRecurring
        )
        
        dataService.updateExpense(updatedExpense)
        clearForm()
        showingEditExpense = false
        selectedExpense = nil
    }
    
    func deleteExpense(_ expense: Expense) {
        dataService.deleteExpense(expense)
    }
    
    func editExpense(_ expense: Expense) {
        selectedExpense = expense
        expenseTitle = expense.title
        expenseAmount = String(expense.amount)
        expenseCategory = expense.category
        expenseDate = expense.date
        expenseDescription = expense.description
        expenseTags = expense.tags.joined(separator: ", ")
        isRecurring = expense.isRecurring
        showingEditExpense = true
    }
    
    func clearForm() {
        expenseTitle = ""
        expenseAmount = ""
        expenseCategory = .other
        expenseDate = Date()
        expenseDescription = ""
        expenseTags = ""
        isRecurring = false
    }
    
    func clearFilters() {
        selectedCategory = nil
        searchText = ""
        selectedTimePeriod = .month
        sortOption = .dateDescending
    }
}

enum SortOption: String, CaseIterable {
    case dateAscending = "Date (Oldest First)"
    case dateDescending = "Date (Newest First)"
    case amountAscending = "Amount (Low to High)"
    case amountDescending = "Amount (High to Low)"
    case titleAscending = "Title (A to Z)"
    case titleDescending = "Title (Z to A)"
}


