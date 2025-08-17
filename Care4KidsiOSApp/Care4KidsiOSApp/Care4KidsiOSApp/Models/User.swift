import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let userType: UserType
    let createdAt: Date
    
    init(id: String = UUID().uuidString, email: String, name: String, userType: UserType) {
        self.id = id
        self.email = email
        self.name = name
        self.userType = userType
        self.createdAt = Date()
    }
}
