import SwiftUI

struct StagingView: View {
    @StateObject private var viewModel = StagingViewModel()
    @State private var showingStagePicker = false
    @State private var draggedStage: StagingStage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(LocalizedStringKey("stagingIntro"))
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
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.removeStage(at: index)
                                    }
                                },
                                onDuplicate: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.duplicateStage(stage)
                                    }
                                }
                            )
                            .onDrag {
                                self.draggedStage = stage
                                return NSItemProvider(object: stage.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(
                                draggedStage: $draggedStage,
                                stages: $viewModel.selectedStages,
                                currentIndex: index
                            ))
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
                            Text(LocalizedStringKey("totalTime"))
                                .font(.headline)
                            Spacer()
                            Text(formatDuration(viewModel.getTotalDuration()))
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text(LocalizedStringKey("stagesInProcess"))
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
            .navigationTitle(LocalizedStringKey("staging"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingStagePicker) {
            StagePickerView(
                availableStages: viewModel.getAvailableStages(),
                onSelectStage: { stage in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.addStage(stage)
                    }
                    showingStagePicker = false
                },
                viewModel: viewModel
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
    let onDuplicate: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка стадии
            Image(systemName: stage.iconName)
                .font(.title2)
                .foregroundColor(Color(stage.color))
                .frame(width: 32, height: 32)
            
            // Информация о стадии
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(stage.name))
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(LocalizedStringKey(stage.description))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Индикатор drag
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDelete()
                }
            } label: {
                Label(LocalizedStringKey("delete"), systemImage: "trash.fill")
            }
            .tint(.red)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDuplicate()
                }
            } label: {
                Label(LocalizedStringKey("duplicate"), systemImage: "plus.square.on.square")
            }
            .tint(.blue)
        }
    }
}

struct AddStageButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 32, height: 32)
                
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 32, height: 32)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
    }
}

struct StagePickerView: View {
    let availableStages: [StagingStage]
    let onSelectStage: (StagingStage) -> Void
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StagingViewModel
    
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
                            HStack {
                                Text(stage.name)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                // Показываем количество уже добавленных стадий этого типа
                                let count = viewModel.selectedStages.filter { $0.name.hasPrefix(stage.name) }.count
                                if count > 0 {
                                    Text("(\(count))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Text(stage.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(LocalizedStringKey("chooseStage"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    @Binding var draggedStage: StagingStage?
    @Binding var stages: [StagingStage]
    let currentIndex: Int
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedStage = draggedStage,
              let draggedIndex = stages.firstIndex(where: { $0.id == draggedStage.id }) else {
            return false
        }
        
        if draggedIndex != currentIndex {
            withAnimation(.easeInOut(duration: 0.3)) {
                let stage = stages.remove(at: draggedIndex)
                let newIndex = draggedIndex < currentIndex ? currentIndex - 1 : currentIndex
                stages.insert(stage, at: newIndex)
            }
        }
        
        self.draggedStage = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Можно добавить визуальную обратную связь при перетаскивании
    }
    
    func dropExited(info: DropInfo) {
        // Можно добавить визуальную обратную связь при перетаскивании
    }
}

#Preview {
    StagingView()
} 
