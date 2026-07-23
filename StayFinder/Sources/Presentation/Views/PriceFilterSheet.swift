import SwiftUI

struct PriceFilterSheet: View {
    @Binding var filter: AccommodationFilter
    @Environment(\.dismiss) private var dismiss

    @State private var range: ClosedRange<Double> = 0...1000

    var body: some View {
        NavigationStack {
            Form {
                Section("Price per night") {
                    Stepper("Min: €\(Int(range.lowerBound))", value: Binding(
                        get: { range.lowerBound },
                        set: { range = min($0, range.upperBound)...range.upperBound }
                    ), in: 0...1000, step: 25)

                    Stepper("Max: €\(Int(range.upperBound))", value: Binding(
                        get: { range.upperBound },
                        set: { range = range.lowerBound...max($0, range.lowerBound) }
                    ), in: 0...1000, step: 25)
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        filter = .empty
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        filter = AccommodationFilter(
                            minPricePerNight: range.lowerBound,
                            maxPricePerNight: range.upperBound
                        )
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            range = (filter.minPricePerNight ?? 0)...(filter.maxPricePerNight ?? 1000)
        }
        .presentationDetents([.medium])
    }
}

#Preview("No filter") {
    @Previewable @State var filter = AccommodationFilter.empty
    PriceFilterSheet(filter: $filter)
}

#Preview("Active filter") {
    @Previewable @State var filter = AccommodationFilter(minPricePerNight: 100, maxPricePerNight: 500)
    PriceFilterSheet(filter: $filter)
}
