//
//  OnboardingView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.black, Color(hex: "#1a1a1a")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Progress Bar
                VStack(spacing: 16) {
                    HStack {
                        Text("Step \(viewModel.currentStep + 1) of \(viewModel.totalSteps)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Button("Skip") {
                            viewModel.skipOnboarding()
                        }
                        .font(.caption)
                        .foregroundColor(Color(hex: "#fbd600"))
                    }
                    
                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#fbd600")))
                        .scaleEffect(y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Main Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(viewModel: viewModel)
                        .tag(0)
                    
                    BudgetStepView(viewModel: viewModel)
                        .tag(1)
                    
                    GoalsStepView(viewModel: viewModel)
                        .tag(2)
                    
                    ThemeStepView(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if viewModel.currentStep > 0 {
                        Button(action: viewModel.previousStep) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(25)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.currentStep == viewModel.totalSteps - 1 {
                            viewModel.completeOnboarding()
                        } else {
                            viewModel.nextStep()
                        }
                    }) {
                        HStack {
                            Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Get Started" : "Next")
                            if viewModel.currentStep < viewModel.totalSteps - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.canProceed ? Color(hex: "#fbd600") : Color.gray.opacity(0.3)
                        )
                        .cornerRadius(25)
                    }
                    .disabled(!viewModel.canProceed)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onChange(of: viewModel.isCompleted) { completed in
            if completed {
                dismiss()
            }
        }
    }
}

struct WelcomeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Logo/Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "#fbd600").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color(hex: "#fbd600"))
            }
            
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("NeonFiscal Kangwon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Your futuristic finance companion")
                    .font(.title3)
                    .foregroundColor(Color(hex: "#fbd600"))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 24) {
                Text("What's your name?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("Enter your name", text: $viewModel.userName)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#fbd600").opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct BudgetStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Set Your Monthly Budget")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("This helps us track your spending and provide better insights")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 24) {
                HStack {
                    Text("$")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(hex: "#fbd600"))
                    
                    TextField("0", text: $viewModel.monthlyBudget)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#fbd600").opacity(0.3), lineWidth: 1)
                )
                
                Text("Don't worry, you can change this later")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct GoalsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Financial Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Select your financial priorities")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(FinancialGoal.allCases) { goal in
                        GoalSelectionCard(
                            goal: goal,
                            isSelected: viewModel.selectedFinancialGoals.contains(goal)
                        ) {
                            if viewModel.selectedFinancialGoals.contains(goal) {
                                viewModel.selectedFinancialGoals.remove(goal)
                            } else {
                                viewModel.selectedFinancialGoals.insert(goal)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
}

struct GoalSelectionCard: View {
    let goal: FinancialGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: goal.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .black : Color(hex: "#fbd600"))
                
                Text(goal.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(
                isSelected ? Color(hex: "#fbd600") : Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: "#fbd600") : Color.white.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ThemeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Choose Your Style")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Select a theme that matches your personality")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(FinancialTheme.allCases) { theme in
                        ThemeSelectionCard(
                            theme: theme,
                            isSelected: viewModel.selectedTheme == theme
                        ) {
                            viewModel.selectedTheme = theme
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
}

struct ThemeSelectionCard: View {
    let theme: FinancialTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Theme Preview
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.primaryColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.backgroundColor, lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(theme.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#fbd600"))
                }
            }
            .padding(16)
            .background(
                isSelected ? Color.white.opacity(0.1) : Color.clear
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: "#fbd600") : Color.white.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView()
}


