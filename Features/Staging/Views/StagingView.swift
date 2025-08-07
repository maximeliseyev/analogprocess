import SwiftUI

struct StagingView: View {
    @StateObject private var viewModel = StagingViewModel()
    @State private var showingStagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Заголовок
                VStack(spacing: 8) {
                    Text("Стадии обработки")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Добавьте стадии обработки плёнки в нужном порядке")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Список добавленных стадий
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.selectedStages.indices, id: \.self) { index in
                            let stage = viewModel.selectedStages[index]
                            StageRowView(
                                stage: stage,
                                onDelete: {
                                    viewModel.removeStage(at: index)
                                },
                                onMoveUp: index > 0 ? {
                                    viewModel.moveStage(from: index, to: index - 1)
                                } : nil,
                                onMoveDown: index < viewModel.selectedStages.count - 1 ? {
                                    viewModel.moveStage(from: index, to: index + 1)
                                } : nil
                            )
                        }
                        
                        // Блок добавления новой стадии
                        AddStageButton(onTap: {
                            showingStagePicker = true
                        })
                    }
                    .padding(.horizontal)
                }
                
                // Итоговая информация
                if !viewModel.selectedStages.isEmpty {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Общее время:")
                                .font(.headline)
                            Spacer()
                            Text(formatDuration(viewModel.getTotalDuration()))
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Стадий в процессе:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.selectedStages.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Стадии")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingStagePicker) {
            StagePickerView(
                availableStages: viewModel.getAvailableStages(),
                onSelectStage: { stage in
                    viewModel.addStage(stage)
                    showingStagePicker = false
                }
            )
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StageRowView: View {
    let stage: StagingStage
    let onDelete: () -> Void
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка стадии
            Image(systemName: stage.iconName)
                .font(.title2)
                .foregroundColor(Color(stage.color))
                .frame(width: 32, height: 32)
            
            // Информация о стадии
            VStack(alignment: .leading, spacing: 4) {
                Text(stage.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(stage.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Кнопки управления
            HStack(spacing: 8) {
                if let onMoveUp = onMoveUp {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if let onMoveDown = onMoveDown {
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct AddStageButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                
                Text("Добавить стадию")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .background(Color(.secondarySystemBackground))
            )
            .cornerRadius(12)
        }
    }
}

struct StagePickerView: View {
    let availableStages: [StagingStage]
    let onSelectStage: (StagingStage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(availableStages) { stage in
                Button(action: {
                    onSelectStage(stage)
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: stage.iconName)
                            .font(.title2)
                            .foregroundColor(Color(stage.color))
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stage.name)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(stage.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Выберите стадию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StagingView()
} 