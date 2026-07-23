import Foundation
import Supabase

enum SupabaseConfig {
    static let projectURL = URL(string: "https://ndoiiozenylzuyagjdms.supabase.co")!
    static let apiKey = "sb_publishable_ae7jbMqLasOeV__yYR9UHA_uLurykOe"
}

enum SupabaseClientFactory {
    static func make(
        url: URL = SupabaseConfig.projectURL,
        key: String = SupabaseConfig.apiKey
    ) -> SupabaseClient {
        SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
