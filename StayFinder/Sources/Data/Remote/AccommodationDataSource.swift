import Foundation
import Supabase

protocol AccommodationDataSource: Sendable {
    func fetchAccommodations() async throws -> [AccommodationDTO]
    func fetchAccommodationDetail(id: UUID) async throws -> AccommodationDetailDTO
}

struct SupabaseAccommodationDataSource: AccommodationDataSource {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchAccommodations() async throws -> [AccommodationDTO] {
        try await client
            .from("accommodations")
            .select()
            .execute()
            .value
    }

    func fetchAccommodationDetail(id: UUID) async throws -> AccommodationDetailDTO {
        try await client
            .from("accommodations")
            .select("*, hosts(*), reviews(*)")
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
}
