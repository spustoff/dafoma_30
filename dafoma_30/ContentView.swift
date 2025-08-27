//
//  ContentView.swift
//  NeonFiscal Kangwon
//
//  Created by Вячеслав on 8/26/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(selectedTab: $selectedTab)
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.black, Color(hex: "#1a1a1a")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Dashboard")
                    }
                    .tag(0)
                
                ExpenseListView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "minus.circle.fill" : "minus.circle")
                        Text("Expenses")
                    }
                    .tag(1)
                
                InvestmentTrackerView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "chart.line.uptrend.xyaxis" : "chart.bar")
                        Text("Investments")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                        Text("Settings")
                    }
                    .tag(3)
            }
            .accentColor(Color(hex: "#fbd600"))
        }
    }
}

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userFinancialTheme") private var userFinancialTheme = "neon"
    @AppStorage("userMonthlyBudget") private var userMonthlyBudget = 0.0
    @AppStorage("userName") private var userName = ""
    
    @State private var showingResetAlert = false
    @State private var tempBudget = ""
    @State private var tempName = ""
    
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
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "#fbd600"))
                            
                            Text("Settings")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // User Settings
                        VStack(spacing: 16) {
                            Text("Personal Information")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                SettingRow(
                                    title: "Name",
                                    value: userName.isEmpty ? "Not set" : userName,
                                    icon: "person.fill"
                                ) {
                                    // Edit name action
                                }
                                
                                SettingRow(
                                    title: "Monthly Budget",
                                    value: userMonthlyBudget > 0 ? String(format: "$%.0f", userMonthlyBudget) : "Not set",
                                    icon: "dollarsign.circle.fill"
                                ) {
                                    // Edit budget action
                                }
                                
                                SettingRow(
                                    title: "Theme",
                                    value: FinancialTheme(rawValue: userFinancialTheme)?.displayName ?? "Neon Futuristic",
                                    icon: "paintbrush.fill"
                                ) {
                                    // Edit theme action
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        
                        // App Settings
                        VStack(spacing: 16) {
                            Text("App Settings")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                SettingRow(
                                    title: "Notifications",
                                    value: "Enabled",
                                    icon: "bell.fill"
                                ) {
                                    // Notification settings
                                }
                                
                                SettingRow(
                                    title: "Privacy",
                                    value: "Secure",
                                    icon: "lock.fill"
                                ) {
                                    // Privacy settings
                                }
                                
                                SettingRow(
                                    title: "Data Export",
                                    value: "Available",
                                    icon: "square.and.arrow.up.fill"
                                ) {
                                    // Export data
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        
                        // About Section
                        VStack(spacing: 16) {
                            Text("About")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                SettingRow(
                                    title: "Version",
                                    value: "1.0.0",
                                    icon: "info.circle.fill"
                                ) {
                                    // Version info
                                }
                                
                                SettingRow(
                                    title: "Support",
                                    value: "Contact Us",
                                    icon: "questionmark.circle.fill"
                                ) {
                                    // Support contact
                                }
                                
                                SettingRow(
                                    title: "Rate App",
                                    value: "⭐⭐⭐⭐⭐",
                                    icon: "star.fill"
                                ) {
                                    // Rate app
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        
                        // Reset Section
                        VStack(spacing: 16) {
                            Button(action: {
                                showingResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16))
                                    
                                    Text("Reset App Data")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.red)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Reset App Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAppData()
            }
        } message: {
            Text("This will delete all your expenses, investments, and settings. This action cannot be undone.")
        }
        .onAppear {
            tempName = userName
            tempBudget = userMonthlyBudget > 0 ? String(userMonthlyBudget) : ""
        }
    }
    
    private func resetAppData() {
        // Clear UserDefaults
        hasCompletedOnboarding = false
        userFinancialTheme = "neon"
        userMonthlyBudget = 0.0
        userName = ""
        
        // Clear DataService
        DataService.shared.expenses.removeAll()
        DataService.shared.investments.removeAll()
        
        // Clear UserDefaults storage
        UserDefaults.standard.removeObject(forKey: "NeonFiscal_Expenses")
        UserDefaults.standard.removeObject(forKey: "NeonFiscal_Investments")
        UserDefaults.standard.removeObject(forKey: "NeonFiscal_Portfolio")
        UserDefaults.standard.removeObject(forKey: "NeonFiscal_Summary")
    }
}

struct SettingRow: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#fbd600"))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
