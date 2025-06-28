import Foundation

struct LumaEvent: Codable, Sendable, Identifiable {
    let id: Int
    
    // New structure fields
    let event_id: String?
    let name: String?
    let description: String?
    let start_at: String?
    let end_at: String?
    let url: String?
    let cover_url: String?
    let latitude: Double?
    let longitude: Double?
    let city: String?
    let region: String?
    let similarity: Double?
    
    // Legacy fields for compatibility
    let title: String?
    let date: String?
    let time: String?
    let location: String?
    let organizer: String?
    let status: String?
    let cover_image: String?
    let link: String?
    
    // Computed properties for backward compatibility
    var displayTitle: String? { name ?? title ?? "No Title" }
    var displayDate: String? { start_at ?? date ?? "No Date" }
    var displayTime: String? { time ?? "" }
    var displayCoverImage: String? { cover_url ?? cover_image }
    var displayLink: String? { url ?? link }
    
    // Custom initializer to handle potential decoding issues
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required field
        id = try container.decode(Int.self, forKey: .id)
        
        // Optional new structure fields
        event_id = try container.decodeIfPresent(String.self, forKey: .event_id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        start_at = try container.decodeIfPresent(String.self, forKey: .start_at)
        end_at = try container.decodeIfPresent(String.self, forKey: .end_at)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        cover_url = try container.decodeIfPresent(String.self, forKey: .cover_url)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        similarity = try container.decodeIfPresent(Double.self, forKey: .similarity)
        
        // Optional legacy fields
        title = try container.decodeIfPresent(String.self, forKey: .title)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        time = try container.decodeIfPresent(String.self, forKey: .time)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        organizer = try container.decodeIfPresent(String.self, forKey: .organizer)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        cover_image = try container.decodeIfPresent(String.self, forKey: .cover_image)
        link = try container.decodeIfPresent(String.self, forKey: .link)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case event_id
        case name
        case description
        case start_at
        case end_at
        case url
        case cover_url
        case latitude
        case longitude
        case city
        case region
        case similarity
        case title
        case date
        case time
        case location
        case organizer
        case status
        case cover_image
        case link
    }
} 