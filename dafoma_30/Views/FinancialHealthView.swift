//
//  FinancialHealthView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct FinancialHealthView: View {
    @ObservedObject var dataService = DataService.shared
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HealthHeaderView()
                        
                        // Main Score Display
                        HealthScoreDisplay()
                        
                        // Detailed Metrics
                        HealthMetricsView()
                        
                        // Recommendations
                        HealthRecommendationsView()
                        
                        // Progress Tracking
                        HealthProgressView()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HealthHeaderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Financial Health")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Your financial wellness score")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                DataService.shared.updateFinancialHealthScore()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
        }
        .padding(.top, 10)
    }
}

struct HealthScoreDisplay: View {
    @ObservedObject var dataService = DataService.shared
    
    var healthScore: FinancialHealthScore {
        dataService.financialHealthScore
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Circular Progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(healthScore.overallScore) / 100)
                    .stroke(
                        Color(hex: healthScore.scoreCategory.color),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: healthScore.overallScore)
                
                // Score text
                VStack(spacing: 4) {
                    Text("\(healthScore.overallScore)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/ 100")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Score category
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: healthScore.scoreCategory.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: healthScore.scoreCategory.color))
                    
                    Text(healthScore.scoreCategory.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: healthScore.scoreCategory.color))
                }
                
                Text(getScoreDescription())
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
    
    private func getScoreDescription() -> String {
        switch healthScore.scoreCategory {
        case .excellent:
            return "Outstanding financial health! You're on track for long-term success."
        case .good:
            return "Good financial habits. A few improvements could boost your score."
        case .fair:
            return "Decent foundation. Focus on key areas for improvement."
        case .poor:
            return "Some financial challenges to address. Small steps make big differences."
        case .critical:
            return "Time to focus on financial fundamentals. You can improve with dedication."
        }
    }
}

struct HealthMetricsView: View {
    @ObservedObject var dataService = DataService.shared
    
    var healthScore: FinancialHealthScore {
        dataService.financialHealthScore
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Detailed Breakdown")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                HealthMetricRow(
                    title: "Savings Rate",
                    value: healthScore.savingsRatio,
                    target: 0.2,
                    format: "%.0f%%",
                    multiplier: 100,
                    icon: "banknote.fill"
                )
                
                HealthMetricRow(
                    title: "Debt-to-Income",
                    value: healthScore.debtToIncomeRatio,
                    target: 0.3,
                    format: "%.0f%%",
                    multiplier: 100,
                    icon: "creditcard.fill",
                    isInverted: true
                )
                
                HealthMetricRow(
                    title: "Expense Stability",
                    value: 1 - healthScore.expenseVariability,
                    target: 0.7,
                    format: "%.0f%%",
                    multiplier: 100,
                    icon: "chart.line.flattrend.xyaxis"
                )
                
                HealthMetricRow(
                    title: "Investment Diversity",
                    value: healthScore.investmentDiversification,
                    target: 0.6,
                    format: "%.0f%%",
                    multiplier: 100,
                    icon: "chart.pie.fill"
                )
                
                HealthMetricRow(
                    title: "Emergency Fund",
                    value: healthScore.emergencyFundMonths,
                    target: 3.0,
                    format: "%.1f months",
                    multiplier: 1,
                    icon: "shield.fill"
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct HealthMetricRow: View {
    let title: String
    let value: Double
    let target: Double
    let format: String
    let multiplier: Double
    let icon: String
    let isInverted: Bool
    
    init(title: String, value: Double, target: Double, format: String, multiplier: Double, icon: String, isInverted: Bool = false) {
        self.title = title
        self.value = value
        self.target = target
        self.format = format
        self.multiplier = multiplier
        self.icon = icon
        self.isInverted = isInverted
    }
    
    var progress: Double {
        if isInverted {
            return max(0, min(1, 1 - (value / target)))
        } else {
            return max(0, min(1, value / target))
        }
    }
    
    var progressColor: Color {
        switch progress {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return Color(hex: "#fbd600")
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(progressColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: format, value * multiplier))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(y: 2)
        }
        .padding(.vertical, 4)
    }
}

struct HealthRecommendationsView: View {
    @ObservedObject var dataService = DataService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#fbd600"))
                
                Text("Personalized Recommendations")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(Array(dataService.financialHealthScore.recommendations.enumerated()), id: \.offset) { index, recommendation in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 24, height: 24)
                            .background(Color(hex: "#fbd600"))
                            .clipShape(Circle())
                        
                        Text(recommendation)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct HealthProgressView: View {
    @ObservedObject var dataService = DataService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#fbd600"))
                
                Text("Financial Milestones")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                MilestoneCard(
                    title: "Build Emergency Fund",
                    description: "Save 3-6 months of expenses",
                    progress: min(dataService.financialHealthScore.emergencyFundMonths / 3.0, 1.0),
                    isCompleted: dataService.financialHealthScore.emergencyFundMonths >= 3.0,
                    icon: "shield.fill"
                )
                
                MilestoneCard(
                    title: "Achieve 20% Savings Rate",
                    description: "Save at least 20% of income",
                    progress: min(dataService.financialHealthScore.savingsRatio / 0.2, 1.0),
                    isCompleted: dataService.financialHealthScore.savingsRatio >= 0.2,
                    icon: "banknote.fill"
                )
                
                MilestoneCard(
                    title: "Diversify Investments",
                    description: "Invest in multiple asset types",
                    progress: dataService.financialHealthScore.investmentDiversification,
                    isCompleted: dataService.financialHealthScore.investmentDiversification >= 0.6,
                    icon: "chart.pie.fill"
                )
                
                MilestoneCard(
                    title: "Minimize Debt",
                    description: "Keep debt under 30% of income",
                    progress: max(0, 1 - (dataService.financialHealthScore.debtToIncomeRatio / 0.3)),
                    isCompleted: dataService.financialHealthScore.debtToIncomeRatio <= 0.3,
                    icon: "minus.circle.fill"
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct MilestoneCard: View {
    let title: String
    let description: String
    let progress: Double
    let isCompleted: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isCompleted ? .green : Color(hex: "#fbd600"))
                .frame(width: 32, height: 32)
                .background(
                    (isCompleted ? Color.green : Color(hex: "#fbd600")).opacity(0.2)
                )
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(
                        tint: isCompleted ? .green : Color(hex: "#fbd600")
                    ))
                    .scaleEffect(y: 1.5)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            } else {
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FinancialHealthView()
}

