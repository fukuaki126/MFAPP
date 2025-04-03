import SwiftUI

struct TaskRow: View {
    var task: Task

    var body: some View {
        HStack {
            Button(action: {
                // 完了状態の切り替え
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.system(size: 30))
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.title3)
                if let days = task.lastCompletedDate {
                    Text("経過: \(days)日")
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
