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
    @Published var userName = ""
    @Published var monthlyBudget = ""
    @Published var selectedFinancialGoals: Set<FinancialGoal> = []
    @Published var selectedTheme: FinancialTheme = .neon
    @Published var isCompleted = false
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("userName") var savedUserName = ""
    @AppStorage("userMonthlyBudget") var savedMonthlyBudget = 0.0
    @AppStorage("userFinancialTheme") var savedFinancialTheme = "neon"
    @AppStorage("userFinancialGoals") var savedFinancialGoals = ""
    
    let totalSteps = 4
    
    var progress: Double {
        Double(currentStep) / Double(totalSteps - 1)
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
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
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
    
    func skipOnboarding() {
        completeOnboarding()
    }
    
    func completeOnboarding() {
        // Save user preferences
        savedUserName = userName
        savedMonthlyBudget = Double(monthlyBudget) ?? 0.0
        savedFinancialTheme = selectedTheme.rawValue
        
        // Save financial goals as comma-separated string
        let goalsString = selectedFinancialGoals.map { $0.rawValue }.joined(separator: ",")
        savedFinancialGoals = goalsString
        
        hasCompletedOnboarding = true
        isCompleted = true
    }
}

enum FinancialGoal: String, CaseIterable, Identifiable {
    case budgeting = "Better Budgeting"
    case saving = "Increase Savings"
    case investing = "Smart Investing"
    case debtReduction = "Reduce Debt"
    case emergencyFund = "Emergency Fund"
    case retirement = "Retirement Planning"
    case homeOwnership = "Buy a Home"
    case travelFund = "Travel More"
    case education = "Education Fund"
    case businessInvestment = "Start Business"
    case wealthBuilding = "Build Wealth"
    case financialFreedom = "Financial Freedom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .budgeting: return "chart.pie.fill"
        case .saving: return "banknote.fill"
        case .investing: return "chart.line.uptrend.xyaxis"
        case .debtReduction: return "minus.circle.fill"
        case .emergencyFund: return "shield.fill"
        case .retirement: return "person.fill"
        case .homeOwnership: return "house.fill"
        case .travelFund: return "airplane"
        case .education: return "book.fill"
        case .businessInvestment: return "building.2.fill"
        case .wealthBuilding: return "dollarsign.circle.fill"
        case .financialFreedom: return "star.fill"
        }
    }
    
    var description: String {
        switch self {
        case .budgeting: return "Track and manage your spending effectively"
        case .saving: return "Build consistent saving habits"
        case .investing: return "Grow wealth through smart investments"
        case .debtReduction: return "Pay off debts strategically"
        case .emergencyFund: return "Create a financial safety net"
        case .retirement: return "Secure your future retirement"
        case .homeOwnership: return "Save for your dream home"
        case .travelFund: return "Fund your travel adventures"
        case .education: return "Invest in education and skills"
        case .businessInvestment: return "Start or grow your business"
        case .wealthBuilding: return "Accumulate long-term wealth"
        case .financialFreedom: return "Achieve complete financial independence"
        }
    }
}

enum FinancialTheme: String, CaseIterable, Identifiable {
    case neon = "neon"
    case minimal = "minimal"
    case professional = "professional"
    case vibrant = "vibrant"
    case dark = "dark"
    case nature = "nature"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .neon: return "Neon Glow"
        case .minimal: return "Minimal Clean"
        case .professional: return "Professional"
        case .vibrant: return "Vibrant Colors"
        case .dark: return "Dark Mode"
        case .nature: return "Nature Inspired"
        }
    }
    
    var description: String {
        switch self {
        case .neon: return "Futuristic neon aesthetics with glowing accents"
        case .minimal: return "Clean, simple design with plenty of white space"
        case .professional: return "Corporate-friendly with muted colors"
        case .vibrant: return "Bold, energetic colors that inspire action"
        case .dark: return "Easy on the eyes with dark backgrounds"
        case .nature: return "Earth tones and natural color palette"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .neon: return Color(hex: "#fbd600")
        case .minimal: return Color(hex: "#2c3e50")
        case .professional: return Color(hex: "#34495e")
        case .vibrant: return Color(hex: "#e74c3c")
        case .dark: return Color(hex: "#ecf0f1")
        case .nature: return Color(hex: "#27ae60")
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .neon: return Color.black
        case .minimal: return Color.white
        case .professional: return Color(hex: "#ecf0f1")
        case .vibrant: return Color.white
        case .dark: return Color(hex: "#2c3e50")
        case .nature: return Color(hex: "#f8f9fa")
        }
    }
    
    var accentColor: Color {
        switch self {
        case .neon: return Color(hex: "#00ff88")
        case .minimal: return Color(hex: "#3498db")
        case .professional: return Color(hex: "#2980b9")
        case .vibrant: return Color(hex: "#f39c12")
        case .dark: return Color(hex: "#e67e22")
        case .nature: return Color(hex: "#e67e22")
        }
    }
}

// Extension to support hex colors
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
