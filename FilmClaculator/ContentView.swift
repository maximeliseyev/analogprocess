//
//  ContentView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var minutes = ""
    @State private var seconds = ""
    @State private var coefficient = "1.33"
    @State private var pushSteps = 3
    @State private var isPushMode = true
    @State private var pushResults: [(label: String, minutes: Int, seconds: Int)] = []
    @State private var showResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Калькулятор времени проявки")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Базовое время:")
                    .font(.headline)
                
                HStack {
                    TextField("Минуты", text: $minutes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    Text("мин")
                    
                    TextField("Секунды", text: $seconds)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    Text("сек")
                }
                
                Text("Коэффициент:")
                    .font(.headline)
                
                HStack {
                    TextField("1.33", text: $coefficient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                    Text("(стандартный 1.33)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("Тип процесса:")
                    .font(.headline)
                
                Picker("Тип процесса", selection: $isPushMode) {
                    Text("PULL").tag(false)
                    Text("PUSH").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("Количество ступеней:")
                    .font(.headline)
                
                HStack {
                    Stepper(value: $pushSteps, in: 1...5) {
                        Text("\(pushSteps)")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Text("(от \(isPushMode ? "+" : "-")1 до \(isPushMode ? "+" : "-")\(pushSteps))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            Button(action: calculateTime) {
                Text("Рассчитать")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if showResult {
                VStack(spacing: 15) {
                    Text("Результаты \(isPushMode ? "push" : "pull")-процесса:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(pushResults, id: \.label) { result in
                            HStack {
                                Text(result.label)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(width: 80, alignment: .leading)
                                
                                Text(String(format: "%d:%02d", result.minutes, result.seconds))
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func calculateTime() {
        guard let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0, sec < 60,
              let coeff = Double(coefficient), coeff > 0 else {
            return
        }
        
        let baseSeconds = min * 60 + sec
        pushResults = []
        
        // Базовое время (+0)
        pushResults.append((
            label: "+0",
            minutes: min,
            seconds: sec
        ))
        
        if isPushMode {
            calculatePushProcess(baseSeconds: baseSeconds, coefficient: coeff)
        } else {
            calculatePullProcess(baseSeconds: baseSeconds, coefficient: coeff)
        }
        
        showResult = true
        hideKeyboard()
    }
    
    func calculatePushProcess(baseSeconds: Int, coefficient: Double) {
        for i in 1...pushSteps {
            let multiplier = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) * multiplier)
            
            let resultMinutes = adjustedSeconds / 60
            let resultSeconds = adjustedSeconds % 60
            
            pushResults.append((
                label: "push +\(i)",
                minutes: resultMinutes,
                seconds: resultSeconds
            ))
        }
    }
    
    func calculatePullProcess(baseSeconds: Int, coefficient: Double) {
        for i in 1...pushSteps {
            let divisor = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) / divisor)
            
            let resultMinutes = adjustedSeconds / 60
            let resultSeconds = adjustedSeconds % 60
            
            pushResults.append((
                label: "pull -\(i)",
                minutes: resultMinutes,
                seconds: resultSeconds
            ))
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
