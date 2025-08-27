//
//  ExpenseListView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct ExpenseListView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(hex: "#1a1a1a")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    ExpenseHeaderView(viewModel: viewModel)
                    
                    // Filters and Search
                    ExpenseFiltersView(viewModel: viewModel)
                    
                    // Summary Stats
                    SummaryView(viewModel: viewModel)
                    
                    // Expense List
                    ExpenseList(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingAddExpense) {
            AddEditExpenseView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showingEditExpense) {
            AddEditExpenseView(viewModel: viewModel, isEditing: true)
        }
    }
}

struct ExpenseHeaderView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Expenses")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.filteredExpenses.count) transactions")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { viewModel.clearFilters() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#fbd600"))
                }
                
                Button(action: { viewModel.showingAddExpense = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color(hex: "#fbd600"))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

struct ExpenseFiltersView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search expenses...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            
            // Filter Options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Time Period
                    Menu {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Button(period.rawValue) {
                                viewModel.selectedTimePeriod = period
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedTimePeriod.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Category Filter
                    Menu {
                        Button("All Categories") {
                            viewModel.selectedCategory = nil
                        }
                        
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                viewModel.selectedCategory = category
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedCategory?.rawValue ?? "All Categories")
                            Image(systemName: "chevron.down")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Sort Options
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                viewModel.sortOption = option
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Sort")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
}

struct SummaryView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "Total",
                value: String(format: "$%.2f", viewModel.totalAmount),
                icon: "sum",
                color: Color(hex: "#fbd600")
            )
            
            SummaryCard(
                title: "Average",
                value: String(format: "$%.2f", viewModel.averageAmount),
                icon: "chart.bar.fill",
                color: .blue
            )
            
            SummaryCard(
                title: "Count",
                value: "\(viewModel.filteredExpenses.count)",
                icon: "number",
                color: .green
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct ExpenseList: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        if viewModel.filteredExpenses.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "tray")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("No expenses found")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Try adjusting your filters or add a new expense")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Button("Add Expense") {
                    viewModel.showingAddExpense = true
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "#fbd600"))
                .cornerRadius(25)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 60)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredExpenses) { expense in
                        ExpenseCard(expense: expense) {
                            viewModel.editExpense(expense)
                        } onDelete: {
                            viewModel.deleteExpense(expense)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

struct ExpenseCard: View {
    let expense: Expense
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: expense.category.icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: expense.category.color))
                .frame(width: 44, height: 44)
                .background(Color(hex: expense.category.color).opacity(0.2))
                .clipShape(Circle())
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                if !expense.description.isEmpty {
                    Text(expense.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
                
                // Tags
                if !expense.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(expense.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "#fbd600"))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "#fbd600").opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "-$%.2f", expense.amount))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                if expense.isRecurring {
                    HStack(spacing: 2) {
                        Image(systemName: "repeat")
                        Text("Recurring")
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddEditExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    let isEditing: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(hex: "#1a1a1a")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter expense title", text: $viewModel.expenseTitle)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Amount Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "#fbd600"))
                                
                                TextField("0.00", text: $viewModel.expenseAmount)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Category", selection: $viewModel.expenseCategory) {
                                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                    .tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DatePicker("", selection: $viewModel.expenseDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .colorScheme(.dark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Add a note about this expense", text: $viewModel.expenseDescription)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Tags Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter tags separated by commas", text: $viewModel.expenseTags)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Recurring Toggle
                        HStack {
                            Text("Recurring Expense")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Toggle("", isOn: $viewModel.isRecurring)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#fbd600")))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.clearForm()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fbd600"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        if isEditing {
                            viewModel.updateExpense()
                        } else {
                            viewModel.addExpense()
                        }
                        dismiss()
                    }
                    .foregroundColor(viewModel.canSaveExpense ? Color(hex: "#fbd600") : .gray)
                    .disabled(!viewModel.canSaveExpense)
                }
            }
        }
    }
}

#Preview {
    ExpenseListView()
}
