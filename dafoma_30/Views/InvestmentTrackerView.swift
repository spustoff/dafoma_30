//
//  InvestmentTrackerView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct InvestmentTrackerView: View {
    @StateObject private var viewModel = InvestmentViewModel()
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
                    InvestmentHeaderView(viewModel: viewModel)
                    
                    // Portfolio Summary
                    PortfolioSummaryView(viewModel: viewModel)
                    
                    // Filters and Search
                    InvestmentFiltersView(viewModel: viewModel)
                    
                    // Investment List
                    InvestmentList(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingAddInvestment) {
            AddEditInvestmentView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showingEditInvestment) {
            AddEditInvestmentView(viewModel: viewModel, isEditing: true)
        }
    }
}

struct InvestmentHeaderView: View {
    @ObservedObject var viewModel: InvestmentViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Portfolio")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.filteredInvestments.count) investments")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { viewModel.refreshPrices() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#fbd600"))
                }
                
                Button(action: { viewModel.clearFilters() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#fbd600"))
                }
                
                Button(action: { viewModel.showingAddInvestment = true }) {
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

struct PortfolioSummaryView: View {
    @ObservedObject var viewModel: InvestmentViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Total Portfolio Value
            VStack(spacing: 8) {
                Text("Portfolio Value")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(String(format: "$%.2f", viewModel.totalPortfolioValue))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Image(systemName: viewModel.totalGainLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(String(format: "$%.2f", abs(viewModel.totalGainLoss)))
                        .font(.system(size: 18, weight: .medium))
                    
                    Text(String(format: "(%.2f%%)", viewModel.totalGainLossPercentage))
                        .font(.system(size: 16))
                }
                .foregroundColor(viewModel.totalGainLoss >= 0 ? .green : .red)
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                InvestmentStatCard(
                    title: "Total Cost",
                    value: String(format: "$%.2f", viewModel.totalPortfolioCost),
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
                
                InvestmentStatCard(
                    title: "Investments",
                    value: "\(viewModel.filteredInvestments.count)",
                    icon: "chart.bar.fill",
                    color: Color(hex: "#fbd600")
                )
                
                InvestmentStatCard(
                    title: "Types",
                    value: "\(Set(viewModel.filteredInvestments.map { $0.type }).count)",
                    icon: "square.grid.2x2.fill",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct InvestmentStatCard: View {
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

struct InvestmentFiltersView: View {
    @ObservedObject var viewModel: InvestmentViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search investments...", text: $viewModel.searchText)
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
                    // Type Filter
                    Menu {
                        Button("All Types") {
                            viewModel.selectedType = nil
                        }
                        
                        ForEach(InvestmentType.allCases, id: \.self) { type in
                            Button(type.rawValue) {
                                viewModel.selectedType = type
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedType?.rawValue ?? "All Types")
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
                        ForEach(InvestmentViewModel.InvestmentSortOption.allCases, id: \.self) { option in
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

struct InvestmentList: View {
    @ObservedObject var viewModel: InvestmentViewModel
    
    var body: some View {
        if viewModel.filteredInvestments.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("No investments found")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Start building your portfolio by adding your first investment")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Button("Add Investment") {
                    viewModel.showingAddInvestment = true
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
                    ForEach(viewModel.filteredInvestments) { investment in
                        InvestmentCard(investment: investment) {
                            viewModel.editInvestment(investment)
                        } onDelete: {
                            viewModel.deleteInvestment(investment)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

struct InvestmentCard: View {
    let investment: Investment
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(investment.symbol)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: investment.type.icon)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: investment.type.color))
                            .padding(4)
                            .background(Color(hex: investment.type.color).opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Text(investment.name)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Text(investment.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", investment.totalValue))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: investment.isProfit ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12))
                        
                        Text(String(format: "$%.2f", abs(investment.gainLoss)))
                            .font(.system(size: 14, weight: .medium))
                        
                        Text(String(format: "(%.2f%%)", investment.gainLossPercentage))
                            .font(.system(size: 12))
                    }
                    .foregroundColor(investment.isProfit ? .green : .red)
                }
            }
            
            // Details
            VStack(spacing: 8) {
                HStack {
                    DetailRow(title: "Shares", value: String(format: "%.4f", investment.shares))
                    Spacer()
                    DetailRow(title: "Current Price", value: String(format: "$%.2f", investment.currentPrice))
                }
                
                HStack {
                    DetailRow(title: "Purchase Price", value: String(format: "$%.2f", investment.purchasePrice))
                    Spacer()
                    DetailRow(title: "Purchase Date", value: investment.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                }
                
                if !investment.notes.isEmpty {
                    HStack {
                        Text("Notes:")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(investment.notes)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, 8)
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

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct AddEditInvestmentView: View {
    @ObservedObject var viewModel: InvestmentViewModel
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
                        // Symbol Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Symbol")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("e.g., AAPL, BTC", text: $viewModel.investmentSymbol)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("e.g., Apple Inc.", text: $viewModel.investmentName)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Type Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Type", selection: $viewModel.investmentType) {
                                ForEach(InvestmentType.allCases, id: \.self) { type in
                                    HStack {
                                        Image(systemName: type.icon)
                                        Text(type.rawValue)
                                    }
                                    .tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Shares Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shares")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("0.0000", text: $viewModel.investmentShares)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Purchase Price Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Price")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "#fbd600"))
                                
                                TextField("0.00", text: $viewModel.investmentPurchasePrice)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Current Price Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Price")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "#fbd600"))
                                
                                TextField("0.00", text: $viewModel.investmentCurrentPrice)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Purchase Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Date")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DatePicker("", selection: $viewModel.investmentPurchaseDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .colorScheme(.dark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        // Notes Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Add notes about this investment", text: $viewModel.investmentNotes)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
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
            .navigationTitle(isEditing ? "Edit Investment" : "Add Investment")
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
                            viewModel.updateInvestment()
                        } else {
                            viewModel.addInvestment()
                        }
                        dismiss()
                    }
                    .foregroundColor(viewModel.canSaveInvestment ? Color(hex: "#fbd600") : .gray)
                    .disabled(!viewModel.canSaveInvestment)
                }
            }
        }
    }
}

#Preview {
    InvestmentTrackerView()
}
