//
//  BudgetTrackerView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct BudgetTrackerView: View {
    @StateObject private var viewModel = BudgetViewModel()
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
                    BudgetHeaderView(viewModel: viewModel)
                    
                    // Overview Cards
                    BudgetOverviewView(viewModel: viewModel)
                    
                    // Filters and Search
                    BudgetFiltersView(viewModel: viewModel)
                    
                    // Budget List
                    BudgetListView(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingAddBudget) {
            AddEditBudgetView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showingEditBudget) {
            AddEditBudgetView(viewModel: viewModel, isEditing: true)
        }
    }
}

struct BudgetHeaderView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Budget Tracker")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.activeBudgets.count) active budgets")
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
                
                Button(action: { viewModel.showingAddBudget = true }) {
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

struct BudgetOverviewView: View {
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Main Progress Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: viewModel.overallProgress)
                    .stroke(
                        viewModel.overallProgress > 0.9 ? Color.red : 
                        viewModel.overallProgress > 0.8 ? Color.orange : Color(hex: "#fbd600"),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: viewModel.overallProgress)
                
                VStack(spacing: 2) {
                    Text("\(Int(viewModel.overallProgress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Used")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Summary Stats
            HStack(spacing: 16) {
                BudgetStatCard(
                    title: "Total Budget",
                    value: String(format: "$%.0f", viewModel.totalBudgetAmount),
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
                
                BudgetStatCard(
                    title: "Spent",
                    value: String(format: "$%.0f", viewModel.totalSpentAmount),
                    icon: "minus.circle.fill",
                    color: viewModel.overallProgress > 0.8 ? .red : .green
                )
                
                BudgetStatCard(
                    title: "Remaining",
                    value: String(format: "$%.0f", viewModel.totalBudgetAmount - viewModel.totalSpentAmount),
                    icon: "plus.circle.fill",
                    color: Color(hex: "#fbd600")
                )
            }
            
            // Alerts if any
            if viewModel.budgetsOverLimit > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text("\(viewModel.budgetsOverLimit) budget(s) over limit")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct BudgetStatCard: View {
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
                .font(.system(size: 14, weight: .semibold))
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

struct BudgetFiltersView: View {
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search budgets...", text: $viewModel.searchText)
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
                    // Period Filter
                    Menu {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Button(period.rawValue) {
                                viewModel.selectedPeriod = period
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedPeriod.rawValue)
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
                        ForEach(BudgetSortOption.allCases, id: \.self) { option in
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

struct BudgetListView: View {
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        if viewModel.filteredBudgets.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "chart.pie")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("No budgets found")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Create your first budget to start tracking your spending")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Button("Create Budget") {
                    viewModel.showingAddBudget = true
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
                    ForEach(viewModel.filteredBudgets) { budget in
                        BudgetCard(budget: budget, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

struct BudgetCard: View {
    let budget: Budget
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(budget.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        if !budget.isActive {
                            Text("Inactive")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        if budget.isExpired {
                            Text("Expired")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: budget.period.icon)
                                .font(.caption)
                            Text(budget.period.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.6))
                        
                        if budget.daysRemaining > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                Text("\(budget.daysRemaining) days left")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.0f", budget.totalSpent))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("of $\(String(format: "%.0f", budget.totalBudget))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(budget.budgetProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ProgressView(value: budget.budgetProgress)
                    .progressViewStyle(LinearProgressViewStyle(
                        tint: viewModel.getBudgetStatusColor(budget)
                    ))
                    .scaleEffect(y: 2)
            }
            
            // Categories Preview
            if !budget.categories.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("Categories")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(budget.categories.count) categories")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(budget.categories.prefix(4)) { category in
                            BudgetCategoryMiniCard(category: category, viewModel: viewModel)
                        }
                    }
                    
                    if budget.categories.count > 4 {
                        Text("and \(budget.categories.count - 4) more...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .contextMenu {
            Button(action: { viewModel.editBudget(budget) }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: { viewModel.toggleBudgetStatus(budget) }) {
                Label(budget.isActive ? "Deactivate" : "Activate", 
                      systemImage: budget.isActive ? "pause.circle" : "play.circle")
            }
            
            Button(action: { viewModel.deleteBudget(budget) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct BudgetCategoryMiniCard: View {
    let category: BudgetCategory
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: category.color))
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                ProgressView(value: category.spentPercentage)
                    .progressViewStyle(LinearProgressViewStyle(
                        tint: viewModel.getCategoryStatusColor(category)
                    ))
                    .scaleEffect(y: 1.5)
            }
            
            Text("\(Int(category.spentPercentage * 100))%")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.05))
        .cornerRadius(6)
    }
}

struct AddEditBudgetView: View {
    @ObservedObject var viewModel: BudgetViewModel
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
                        // Budget Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Budget Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("e.g., Monthly Budget", text: $viewModel.budgetName)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Budget Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Budget")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "#fbd600"))
                                
                                TextField("0.00", text: $viewModel.budgetAmount)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Budget Period
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Budget Period")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Period", selection: $viewModel.budgetPeriod) {
                                ForEach(BudgetPeriod.allCases, id: \.self) { period in
                                    HStack {
                                        Image(systemName: period.icon)
                                        Text(period.rawValue)
                                    }
                                    .tag(period)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Date Range
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start Date")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                DatePicker("", selection: $viewModel.budgetStartDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .colorScheme(.dark)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Date")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                DatePicker("", selection: $viewModel.budgetEndDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .colorScheme(.dark)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Categories Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Budget Categories")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { viewModel.showingAddCategory = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "#fbd600"))
                                }
                            }
                            
                            if viewModel.budgetCategories.isEmpty {
                                VStack(spacing: 12) {
                                    Text("No categories added yet")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Button("Add Your First Category") {
                                        viewModel.showingAddCategory = true
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "#fbd600"))
                                    .cornerRadius(20)
                                }
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.budgetCategories) { category in
                                        BudgetCategoryRow(
                                            category: category,
                                            onDelete: { viewModel.removeCategoryFromBudget(category) }
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Notifications
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notifications")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Enable Budget Alerts")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $viewModel.enableNotifications)
                                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#fbd600")))
                                }
                                
                                if viewModel.enableNotifications {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Alert Threshold: \(Int(viewModel.alertThreshold))%")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Slider(value: $viewModel.alertThreshold, in: 50...95, step: 5)
                                            .accentColor(Color(hex: "#fbd600"))
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Budget" : "Create Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.clearBudgetForm()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fbd600"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        if isEditing {
                            viewModel.updateBudget()
                        } else {
                            viewModel.addBudget()
                        }
                        dismiss()
                    }
                    .foregroundColor(viewModel.canSaveBudget ? Color(hex: "#fbd600") : .gray)
                    .disabled(!viewModel.canSaveBudget)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddCategory) {
            AddBudgetCategoryView(viewModel: viewModel)
        }
    }
}

struct BudgetCategoryRow: View {
    let category: BudgetCategory
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: category.color))
                .frame(width: 24, height: 24)
                .background(Color(hex: category.color).opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(category.expenseCategory.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.0f", category.limit))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text("\(Int(category.alertThreshold * 100))% alert")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct AddBudgetCategoryView: View {
    @ObservedObject var viewModel: BudgetViewModel
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
                        // Category Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("e.g., Groceries", text: $viewModel.categoryName)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Category Limit
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Budget Limit")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "#fbd600"))
                                
                                TextField("0.00", text: $viewModel.categoryLimit)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Expense Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Expense Type")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Category", selection: $viewModel.categoryExpenseType) {
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
                        
                        // Alert Threshold
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alert Threshold: \(Int(viewModel.categoryAlertThreshold))%")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Get notified when spending reaches this percentage")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Slider(value: $viewModel.categoryAlertThreshold, in: 50...95, step: 5)
                                .accentColor(Color(hex: "#fbd600"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.clearCategoryForm()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#fbd600"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addCategoryToBudget()
                        dismiss()
                    }
                    .foregroundColor(viewModel.canSaveCategory ? Color(hex: "#fbd600") : .gray)
                    .disabled(!viewModel.canSaveCategory)
                }
            }
        }
    }
}

#Preview {
    BudgetTrackerView()
}
