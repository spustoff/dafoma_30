//
//  InvestmentViewModel.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import SwiftUI
import Combine

class InvestmentViewModel: ObservableObject {
    @Published var investments: [Investment] = []
    @Published var selectedType: InvestmentType? = nil
    @Published var searchText = ""
    @Published var showingAddInvestment = false
    @Published var showingEditInvestment = false
    @Published var selectedInvestment: Investment? = nil
    @Published var sortOption: InvestmentSortOption = .gainLossDescending
    
    // Add/Edit investment form
    @Published var investmentSymbol = ""
    @Published var investmentName = ""
    @Published var investmentShares = ""
    @Published var investmentPurchasePrice = ""
    @Published var investmentCurrentPrice = ""
    @Published var investmentPurchaseDate = Date()
    @Published var investmentType: InvestmentType = .stocks
    @Published var investmentNotes = ""
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var filteredInvestments: [Investment] {
        var result = dataService.investments
        
        // Filter by type
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { investment in
                investment.symbol.localizedCaseInsensitiveContains(searchText) ||
                investment.name.localizedCaseInsensitiveContains(searchText) ||
                investment.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort
        switch sortOption {
        case .gainLossAscending:
            result = result.sorted { $0.gainLoss < $1.gainLoss }
        case .gainLossDescending:
            result = result.sorted { $0.gainLoss > $1.gainLoss }
        case .valueAscending:
            result = result.sorted { $0.totalValue < $1.totalValue }
        case .valueDescending:
            result = result.sorted { $0.totalValue > $1.totalValue }
        case .symbolAscending:
            result = result.sorted { $0.symbol < $1.symbol }
        case .symbolDescending:
            result = result.sorted { $0.symbol > $1.symbol }
        case .purchaseDateAscending:
            result = result.sorted { $0.purchaseDate < $1.purchaseDate }
        case .purchaseDateDescending:
            result = result.sorted { $0.purchaseDate > $1.purchaseDate }
        }
        
        return result
    }
    
    var totalPortfolioValue: Double {
        filteredInvestments.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalPortfolioCost: Double {
        filteredInvestments.reduce(0) { $0 + $1.totalCost }
    }
    
    var totalGainLoss: Double {
        totalPortfolioValue - totalPortfolioCost
    }
    
    var totalGainLossPercentage: Double {
        guard totalPortfolioCost > 0 else { return 0 }
        return (totalGainLoss / totalPortfolioCost) * 100
    }
    
    var investmentsByType: [(type: InvestmentType, value: Double, count: Int, gainLoss: Double)] {
        let investments = filteredInvestments
        var typeData: [InvestmentType: (value: Double, count: Int, gainLoss: Double)] = [:]
        
        for investment in investments {
            let current = typeData[investment.type] ?? (value: 0, count: 0, gainLoss: 0)
            typeData[investment.type] = (
                value: current.value + investment.totalValue,
                count: current.count + 1,
                gainLoss: current.gainLoss + investment.gainLoss
            )
        }
        
        return typeData.map { (type, data) in
            (type: type, value: data.value, count: data.count, gainLoss: data.gainLoss)
        }.sorted { $0.value > $1.value }
    }
    
    var topPerformers: [Investment] {
        Array(filteredInvestments.sorted { $0.gainLossPercentage > $1.gainLossPercentage }.prefix(3))
    }
    
    var worstPerformers: [Investment] {
        Array(filteredInvestments.sorted { $0.gainLossPercentage < $1.gainLossPercentage }.prefix(3))
    }
    
    var canSaveInvestment: Bool {
        !investmentSymbol.isEmpty &&
        !investmentName.isEmpty &&
        !investmentShares.isEmpty &&
        !investmentPurchasePrice.isEmpty &&
        !investmentCurrentPrice.isEmpty &&
        Double(investmentShares) != nil &&
        Double(investmentPurchasePrice) != nil &&
        Double(investmentCurrentPrice) != nil
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataService.$investments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] investments in
                self?.investments = investments
            }
            .store(in: &cancellables)
    }
    
    func addInvestment() {
        guard canSaveInvestment,
              let shares = Double(investmentShares),
              let purchasePrice = Double(investmentPurchasePrice),
              let currentPrice = Double(investmentCurrentPrice) else { return }
        
        let investment = Investment(
            symbol: investmentSymbol.uppercased(),
            name: investmentName,
            shares: shares,
            purchasePrice: purchasePrice,
            currentPrice: currentPrice,
            purchaseDate: investmentPurchaseDate,
            type: investmentType,
            notes: investmentNotes
        )
        
        dataService.addInvestment(investment)
        clearForm()
        showingAddInvestment = false
    }
    
    func updateInvestment() {
        guard let investment = selectedInvestment,
              canSaveInvestment,
              let shares = Double(investmentShares),
              let purchasePrice = Double(investmentPurchasePrice),
              let currentPrice = Double(investmentCurrentPrice) else { return }
        
        let updatedInvestment = Investment(
            symbol: investmentSymbol.uppercased(),
            name: investmentName,
            shares: shares,
            purchasePrice: purchasePrice,
            currentPrice: currentPrice,
            purchaseDate: investmentPurchaseDate,
            type: investmentType,
            notes: investmentNotes
        )
        
        dataService.updateInvestment(updatedInvestment)
        clearForm()
        showingEditInvestment = false
        selectedInvestment = nil
    }
    
    func deleteInvestment(_ investment: Investment) {
        dataService.deleteInvestment(investment)
    }
    
    func editInvestment(_ investment: Investment) {
        selectedInvestment = investment
        investmentSymbol = investment.symbol
        investmentName = investment.name
        investmentShares = String(investment.shares)
        investmentPurchasePrice = String(investment.purchasePrice)
        investmentCurrentPrice = String(investment.currentPrice)
        investmentPurchaseDate = investment.purchaseDate
        investmentType = investment.type
        investmentNotes = investment.notes
        showingEditInvestment = true
    }
    
    func clearForm() {
        investmentSymbol = ""
        investmentName = ""
        investmentShares = ""
        investmentPurchasePrice = ""
        investmentCurrentPrice = ""
        investmentPurchaseDate = Date()
        investmentType = .stocks
        investmentNotes = ""
    }
    
    func clearFilters() {
        selectedType = nil
        searchText = ""
        sortOption = .gainLossDescending
    }
    
    func refreshPrices() {
        // Simulate price updates with random variations
        for investment in investments {
            let variation = Double.random(in: -0.05...0.05) // ±5% variation
            let newPrice = investment.currentPrice * (1 + variation)
            dataService.updateInvestmentPrice(investment.id, newPrice: max(newPrice, 0.01))
        }
    }
}

enum InvestmentSortOption: String, CaseIterable {
    case gainLossAscending = "Gain/Loss (Low to High)"
    case gainLossDescending = "Gain/Loss (High to Low)"
    case valueAscending = "Value (Low to High)"
    case valueDescending = "Value (High to Low)"
    case symbolAscending = "Symbol (A to Z)"
    case symbolDescending = "Symbol (Z to A)"
    case purchaseDateAscending = "Purchase Date (Oldest First)"
    case purchaseDateDescending = "Purchase Date (Newest First)"
}
