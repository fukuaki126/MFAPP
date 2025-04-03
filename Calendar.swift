import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            Text("カレンダー")
                .font(.largeTitle)
                .padding()

            DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle()) // iOS標準のカレンダースタイル
                .padding()

            Spacer()
        }
        .navigationTitle("カレンダー")
    }
}
