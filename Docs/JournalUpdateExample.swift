//
//  JournalUpdateExample.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

// Пример использования обновленного журнала
struct JournalUpdateExample: View {
    @State private var showingCreateRecord = false
    @State private var showingJournal = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Обновленный журнал")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Новая структура записи:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Дата со временем (автоматически)")
                    Text("• Название (необязательно)")
                    Text("• Плёнка")
                    Text("• Проявитель")
                    Text("• Разбавление")
                    Text("• Температура")
                    Text("• Время")
                    Text("• Комментарий (необязательно)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            VStack(spacing: 12) {
                Button("Создать запись с нуля") {
                    showingCreateRecord = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("Перейти в журнал") {
                    showingJournal = true
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingCreateRecord) {
            CreateRecordView()
        }
        .sheet(isPresented: $showingJournal) {
            JournalExampleView()
        }
    }
}

// Пример журнала
struct JournalExampleView: View {
    @State private var records: [JournalRecord] = [
        JournalRecord(
            date: Date(),
            name: "Портрет в парке",
            filmName: "Ilford HP5 Plus",
            developerName: "Kodak Xtol",
            dilution: "1+1",
            temperature: 20.0,
            time: 480,
            comment: "Хорошие результаты, контраст немного мягкий"
        ),
        JournalRecord(
            date: Date().addingTimeInterval(-86400),
            name: nil,
            filmName: "Kodak Tri-X 400",
            developerName: "HC-110",
            dilution: "B",
            temperature: 20.0,
            time: 600,
            comment: nil
        )
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(records, id: \.id) { record in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if let name = record.name, !name.isEmpty {
                                Text(name)
                                    .font(.headline)
                            } else {
                                Text("\(record.filmName ?? "Плёнка") + \(record.developerName ?? "Проявитель")")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Text(record.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let dilution = record.dilution, !dilution.isEmpty {
                                Text("Разведение: \(dilution)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let temperature = record.temperature {
                                Text("Температура: \(String(format: "%.1f", temperature))°C")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let time = record.time {
                                let minutes = time / 60
                                let seconds = time % 60
                                Text("Время: \(String(format: "%d:%02d", minutes, seconds))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let comment = record.comment, !comment.isEmpty {
                            Text(comment)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    records.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Журнал")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("+") {
                        // Добавить новую запись
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    JournalUpdateExample()
} 