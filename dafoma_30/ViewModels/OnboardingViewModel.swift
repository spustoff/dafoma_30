//
//  OnboardingViewModel.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var isCompleted = false
    @Published var userName = ""
    @Published var monthlyBudget = ""
    @Published var selectedFinancialGoals: Set<FinancialGoal> = []
    @Published var selectedTheme: FinancialTheme = .neon
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("userFinancialTheme") var userFinancialTheme = "neon"
    @AppStorage("userMonthlyBudget") var userMonthlyBudget = 0.0
    @AppStorage("userName") var storedUserName = ""
    
    let totalSteps = 4
    
    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }
    
    func nextStep() {
        if currentStep < totalSteps {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }
    
    func completeOnboarding() {
        // Save user preferences
        storedUserName = userName
        userFinancialTheme = selectedTheme.rawValue
        userMonthlyBudget = Double(monthlyBudget) ?? 0.0
        hasCompletedOnboarding = true
        
        // Load sample data for demonstration
        DataService.shared.loadSampleData()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            isCompleted = true
        }
    }
    
    func skipOnboarding() {
        hasCompletedOnboarding = true
        DataService.shared.loadSampleData()
        withAnimation(.easeInOut(duration: 0.5)) {
            isCompleted = true
        }
    }
    
    var canProceed: Bool {
        switch currentStep {
        case 0: return !userName.isEmpty
        case 1: return !monthlyBudget.isEmpty && Double(monthlyBudget) != nil
        case 2: return !selectedFinancialGoals.isEmpty
        case 3: return true
        default: return false
        }
    }
}

enum FinancialGoal: String, CaseIterable, Identifiable {
    case saveForEmergency = "Build Emergency Fund"
    case payOffDebt = "Pay Off Debt"
    case saveForRetirement = "Save for Retirement"
    case buyHome = "Buy a Home"
    case investInStocks = "Invest in Stocks"
    case startBusiness = "Start a Business"
    case travelMore = "Travel More"
    case educationFund = "Education Fund"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .saveForEmergency: return "shield.fill"
        case .payOffDebt: return "creditcard.fill"
        case .saveForRetirement: return "clock.fill"
        case .buyHome: return "house.fill"
        case .investInStocks: return "chart.line.uptrend.xyaxis"
        case .startBusiness: return "briefcase.fill"
        case .travelMore: return "airplane"
        case .educationFund: return "graduationcap.fill"
        }
    }
    
    var description: String {
        switch self {
        case .saveForEmergency: return "Build a safety net for unexpected expenses"
        case .payOffDebt: return "Eliminate high-interest debt"
        case .saveForRetirement: return "Secure your financial future"
        case .buyHome: return "Save for your dream home"
        case .investInStocks: return "Grow wealth through investments"
        case .startBusiness: return "Fund your entrepreneurial dreams"
        case .travelMore: return "Explore the world"
        case .educationFund: return "Invest in knowledge and skills"
        }
    }
}

enum FinancialTheme: String, CaseIterable, Identifiable {
    case neon = "neon"
    case minimalist = "minimalist"
    case luxury = "luxury"
    case nature = "nature"
    case tech = "tech"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .neon: return "Neon Futuristic"
        case .minimalist: return "Clean Minimalist"
        case .luxury: return "Premium Luxury"
        case .nature: return "Natural Zen"
        case .tech: return "Tech Forward"
        }
    }
    
    var description: String {
        switch self {
        case .neon: return "Vibrant neon colors with futuristic vibes"
        case .minimalist: return "Clean lines and simple elegance"
        case .luxury: return "Rich colors and premium feel"
        case .nature: return "Calming earth tones and organic shapes"
        case .tech: return "Modern tech-inspired design"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .neon: return Color(hex: "#fbd600")
        case .minimalist: return Color.gray
        case .luxury: return Color(hex: "#DAA520")
        case .nature: return Color.green
        case .tech: return Color.blue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .neon: return Color.black
        case .minimalist: return Color.white
        case .luxury: return Color(hex: "#1a1a1a")
        case .nature: return Color(hex: "#f5f5dc")
        case .tech: return Color(hex: "#0a0a0a")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
