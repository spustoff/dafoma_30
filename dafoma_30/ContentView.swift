//
//  ContentView.swift
//  dafoma_30
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @State private var showingOnboarding = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            if !hasCompletedOnboarding {
                showingOnboarding = true
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardMainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            ExpenseListView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Expenses")
                }
            
            BudgetTrackerView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Budgets")
                }
            
            SavingsGoalView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            InvestmentTrackerView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Investments")
                }
            
            FinancialHealthView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Health")
                }
        }
        .accentColor(Color(hex: "#fbd600"))
    }
}

struct DashboardMainView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        DashboardHeaderView(viewModel: viewModel)
                        
                        // Quick Stats
                        QuickStatsView(viewModel: viewModel)
                        
                        // Budget Progress
                        if viewModel.userMonthlyBudget > 0 {
                            BudgetProgressView(viewModel: viewModel)
                        }
                        
                        // Quick Actions
                        QuickActionsView()
                        
                        // Recent Activity
                        RecentActivityView(viewModel: viewModel)
                        
                        // Financial Insight
                        InsightCardView(viewModel: viewModel)
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
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Your financial overview")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: { viewModel.refreshData() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
        }
        .padding(.top, 10)
    }
}

struct QuickStatsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "This Month",
                value: String(format: "$%.0f", viewModel.totalExpenses),
                subtitle: "Expenses",
                icon: "minus.circle.fill",
                color: .red
            )
            
            StatCard(
                title: "Portfolio",
                value: String(format: "$%.0f", viewModel.totalInvestmentValue),
                subtitle: String(format: "%.1f%%", viewModel.investmentGainLossPercentage),
                icon: "chart.line.uptrend.xyaxis",
                color: viewModel.totalInvestmentGainLoss >= 0 ? .green : .red
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct BudgetProgressView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Monthly Budget")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "$%.0f remaining", viewModel.budgetRemaining))
                    .font(.subheadline)
                    .foregroundColor(viewModel.isOverBudget ? .red : Color(hex: "#fbd600"))
            }
            
            ProgressView(value: viewModel.budgetProgress)
                .progressViewStyle(LinearProgressViewStyle(
                    tint: viewModel.isOverBudget ? .red : Color(hex: "#fbd600")
                ))
                .scaleEffect(y: 2)
            
            HStack {
                Text(String(format: "%.0f%% used", viewModel.budgetProgress * 100))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text(String(format: "$%.0f / $%.0f", 
                     viewModel.userMonthlyBudget - viewModel.budgetRemaining, 
                     viewModel.userMonthlyBudget))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct QuickActionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: ExpenseListView()) {
                    QuickActionButton(
                        title: "Add Expense",
                        icon: "plus.circle.fill",
                        color: .red
                    )
                }
                
                NavigationLink(destination: BudgetTrackerView()) {
                    QuickActionButton(
                        title: "View Budgets",
                        icon: "chart.pie.fill",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: SavingsGoalView()) {
                    QuickActionButton(
                        title: "Savings Goals",
                        icon: "target",
                        color: .green
                    )
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
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
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#fbd600"))
                }
            }
            
            if viewModel.recentExpenses.isEmpty {
                Text("No recent expenses")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentExpenses.prefix(3)) { expense in
                        RecentExpenseRow(expense: expense)
                    }
                }
            }
        }
    }
}

struct RecentExpenseRow: View {
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
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct InsightCardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
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
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
