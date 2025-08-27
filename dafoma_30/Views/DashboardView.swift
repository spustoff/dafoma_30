//
//  DashboardView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                if viewModel.isZenModeActive {
                    ZenModeBackground()
                } else {
                    RegularBackground()
                }
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header
                        DashboardHeaderView(viewModel: viewModel)
                        
                        // Quick Stats
                        QuickStatsView(viewModel: viewModel)
                        
                        // Budget Progress
                        BudgetProgressView(viewModel: viewModel)
                        
                        // Recent Activity
                        RecentActivityView(viewModel: viewModel)
                        
                        // Investment Overview
                        InvestmentOverviewView(viewModel: viewModel)
                        
                        // Expense Categories
                        ExpenseCategoriesView(viewModel: viewModel)
                        
                        // Financial Insight
                        FinancialInsightView(viewModel: viewModel)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct DashboardHeaderView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Ready to manage your finances?")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: viewModel.toggleZenMode) {
                    Image(systemName: viewModel.isZenModeActive ? "moon.fill" : "moon")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#fbd600"))
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: viewModel.refreshData) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#fbd600"))
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.top, 10)
    }
}

struct QuickStatsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Overview")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Picker("Period", selection: $viewModel.selectedTimePeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(Color(hex: "#fbd600"))
            }
            
            HStack(spacing: 12) {
                DashboardStatCard(
                    title: "Expenses",
                    value: String(format: "$%.2f", viewModel.totalExpenses),
                    icon: "minus.circle.fill",
                    color: .red
                )
                
                DashboardStatCard(
                    title: "Investments",
                    value: String(format: "$%.2f", viewModel.totalInvestmentValue),
                    icon: "chart.line.uptrend.xyaxis",
                    color: viewModel.totalInvestmentGainLoss >= 0 ? .green : .red
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct BudgetProgressView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Monthly Budget")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "$%.0f left", viewModel.budgetRemaining))
                    .font(.subheadline)
                    .foregroundColor(viewModel.isOverBudget ? .red : Color(hex: "#fbd600"))
            }
            
            VStack(spacing: 8) {
                ProgressView(value: viewModel.budgetProgress)
                    .progressViewStyle(LinearProgressViewStyle(
                        tint: viewModel.isOverBudget ? .red : Color(hex: "#fbd600")
                    ))
                    .scaleEffect(y: 3)
                
                HStack {
                    Text("$0")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text(String(format: "$%.0f", viewModel.userMonthlyBudget))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            if viewModel.isOverBudget {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    
                    Text("You've exceeded your monthly budget")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct RecentActivityView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Expenses")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: ExpenseListView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#fbd600"))
                }
            }
            
            if viewModel.recentExpenses.isEmpty {
                Text("No recent expenses")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.recentExpenses.prefix(3)) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: expense.category.color))
                .frame(width: 32, height: 32)
                .background(Color(hex: expense.category.color).opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "-$%.2f", expense.amount))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}

struct InvestmentOverviewView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Portfolio")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: InvestmentTrackerView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#fbd600"))
                }
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(String(format: "$%.2f", viewModel.totalInvestmentValue))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Gain/Loss")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.totalInvestmentGainLoss >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        
                        Text(String(format: "$%.2f", abs(viewModel.totalInvestmentGainLoss)))
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(String(format: "(%.1f%%)", viewModel.investmentGainLossPercentage))
                            .font(.caption)
                    }
                    .foregroundColor(viewModel.totalInvestmentGainLoss >= 0 ? .green : .red)
                }
            }
            
            if !viewModel.topInvestments.isEmpty {
                VStack(spacing: 8) {
                    ForEach(viewModel.topInvestments) { investment in
                        InvestmentRowView(investment: investment)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct InvestmentRowView: View {
    let investment: Investment
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(investment.symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(investment.name)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", investment.totalValue))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 2) {
                    Image(systemName: investment.isProfit ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    
                    Text(String(format: "%.1f%%", investment.gainLossPercentage))
                        .font(.caption)
                }
                .foregroundColor(investment.isProfit ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExpenseCategoriesView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Spending by Category")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if viewModel.expensesByCategory.isEmpty {
                Text("No expenses for this period")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.expensesByCategory.prefix(5), id: \.category) { item in
                        CategoryRowView(
                            category: item.category,
                            amount: item.amount,
                            percentage: item.percentage
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct CategoryRowView: View {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: category.color))
                .frame(width: 32, height: 32)
                .background(Color(hex: category.color).opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                ProgressView(value: percentage / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: category.color)))
                    .scaleEffect(y: 0.5)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", amount))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(String(format: "%.1f%%", percentage))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}

struct FinancialInsightView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#fbd600"))
                
                Text("Financial Insight")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(viewModel.getFinancialInsight())
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct RegularBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.black, Color(hex: "#1a1a1a")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct ZenModeBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0a0a0a"), Color(hex: "#1a1a2e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle animated particles
            ForEach(0..<20, id: \.self) { _ in
                Circle()
                    .fill(Color(hex: "#fbd600").opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            }
        }
    }
}

#Preview {
    DashboardView()
}
