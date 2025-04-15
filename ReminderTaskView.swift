import SwiftUI

struct ReminderTaskView: View {
    @Binding var tasks: [Task]
    @Binding var selectedTaskIndex: Int
    @State private var isEditPresented = false

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if tasks.filter({ $0.taskType == .reminder }).isEmpty {
                    Text("リマインダーがありません")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(tasks.indices, id: \.self) { index in
                            if tasks[index].taskType == .reminder {
                                HStack {
                                    Button(action: {
                                        tasks[index].isCompleted.toggle()
                                    }) {
                                        Image(systemName: tasks[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(tasks[index].isCompleted ? .green : .gray)
                                            .font(.system(size: 30))
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(tasks[index].title)
                                                .font(.headline)
                                                .foregroundColor(.primary)

                                            if let dueDate = tasks[index].dueDate {
                                                Text(formatDate(dueDate))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTaskIndex = index
                                        isEditPresented = true
                                    }
                                }
                            }
                        }
                        
                        .onDelete { indexSet in
                            tasks.remove(atOffsets: indexSet)
                            saveTasks()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
        }
        .fullScreenCover(isPresented: $isEditPresented,content:{
            EditTaskView(task: $tasks[selectedTaskIndex])
        })
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }

    private func saveTasks() {
        UserDefaults.standard.set(try? JSONEncoder().encode(tasks), forKey: "tasks")
    }
}
