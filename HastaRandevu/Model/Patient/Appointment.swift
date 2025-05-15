import Foundation

struct Appointments: Identifiable, Decodable {
    var id: Int
    var date: String
    var time: String
    var clinic: Clinic
    var status: String
    var description: String?
    
    var doctor: User?       // 👈 Bu alan eksikti
    var patient: User?  
}
