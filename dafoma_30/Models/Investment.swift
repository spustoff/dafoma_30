//
//  Investment.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation

struct Investment: Identifiable, Codable {
    let id = UUID()
    var symbol: String
    var name: String
    var shares: Double
    var purchasePrice: Double
    var currentPrice: Double
    var purchaseDate: Date
    var type: InvestmentType
    var notes: String
    
    var totalValue: Double {
        shares * currentPrice
    }
    
    var totalCost: Double {
        shares * purchasePrice
    }
    
    var gainLoss: Double {
        totalValue - totalCost
    }
    
    var gainLossPercentage: Double {
        guard totalCost > 0 else { return 0 }
        return (gainLoss / totalCost) * 100
    }
    
    var isProfit: Bool {
        gainLoss >= 0
    }
    
    init(symbol: String, name: String, shares: Double, purchasePrice: Double, currentPrice: Double, purchaseDate: Date = Date(), type: InvestmentType, notes: String = "") {
        self.symbol = symbol
        self.name = name
        self.shares = shares
        self.purchasePrice = purchasePrice
        self.currentPrice = currentPrice
        self.purchaseDate = purchaseDate
        self.type = type
        self.notes = notes
    }
}

enum InvestmentType: String, CaseIterable, Codable {
    case stocks = "Stocks"
    case bonds = "Bonds"
    case crypto = "Cryptocurrency"
    case etf = "ETF"
    case mutualFund = "Mutual Fund"
    case reit = "REIT"
    case commodities = "Commodities"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .stocks: return "chart.line.uptrend.xyaxis"
        case .bonds: return "doc.text.fill"
        case .crypto: return "bitcoinsign.circle.fill"
        case .etf: return "chart.bar.fill"
        case .mutualFund: return "building.columns.fill"
        case .reit: return "house.fill"
        case .commodities: return "cube.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .stocks: return "#2ECC71"
        case .bonds: return "#3498DB"
        case .crypto: return "#F39C12"
        case .etf: return "#9B59B6"
        case .mutualFund: return "#1ABC9C"
        case .reit: return "#E74C3C"
        case .commodities: return "#34495E"
        case .other: return "#95A5A6"
        }
    }
}

struct Portfolio: Codable {
    var investments: [Investment]
    var totalValue: Double {
        investments.reduce(0) { $0 + $1.totalValue }
    }
    var totalCost: Double {
        investments.reduce(0) { $0 + $1.totalCost }
    }
    var totalGainLoss: Double {
        totalValue - totalCost
    }
    var totalGainLossPercentage: Double {
        guard totalCost > 0 else { return 0 }
        return (totalGainLoss / totalCost) * 100
    }
    var lastUpdated: Date
    
    init(investments: [Investment] = []) {
        self.investments = investments
        self.lastUpdated = Date()
    }
}

struct MarketData: Codable {
    var symbol: String
    var currentPrice: Double
    var change: Double
    var changePercentage: Double
    var lastUpdated: Date
    
    var isPositive: Bool {
        change >= 0
    }
}
