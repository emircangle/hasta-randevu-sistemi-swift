import Foundation
import Alamofire

class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}
    
    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/analytics"
    
    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getAppointmentCountByClinic(completion: @escaping (Result<[ClinicAppointmentCount], Error>) -> Void) {
        AF.request("\(baseURL)/appointments/clinic", headers: headers)
            .validate()
            .responseDecodable(of: [ClinicAppointmentCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getAppointmentCountByDate(completion: @escaping (Result<[DateAppointmentCount], Error>) -> Void) {
        AF.request("\(baseURL)/appointments/date", headers: headers)
            .validate()
            .responseDecodable(of: [DateAppointmentCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getAppointmentCountByStatus(completion: @escaping (Result<[AppointmentStatusCount], Error>) -> Void) {
        AF.request("\(baseURL)/appointments/status", headers: headers)
            .validate()
            .responseDecodable(of: [AppointmentStatusCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getAppointmentCountByDoctor(completion: @escaping (Result<[DoctorAppointmentCount], Error>) -> Void) {
        AF.request("\(baseURL)/appointments/doctor", headers: headers)
            .validate()
            .responseDecodable(of: [DoctorAppointmentCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getMonthlyUserRegistration(completion: @escaping (Result<[MonthlyUserRegistration], Error>) -> Void) {
        AF.request("\(baseURL)/users/monthly", headers: headers)
            .validate()
            .responseDecodable(of: [MonthlyUserRegistration].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getComplaintCountByStatus(completion: @escaping (Result<[ComplaintStatusCount], Error>) -> Void) {
        AF.request("\(baseURL)/complaints/status", headers: headers)
            .validate()
            .responseDecodable(of: [ComplaintStatusCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getComplaintCountByClinic(completion: @escaping (Result<[ClinicComplaintCount], Error>) -> Void) {
        AF.request("\(baseURL)/complaints/clinic", headers: headers)
            .validate()
            .responseDecodable(of: [ClinicComplaintCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getAppointmentCountByTimeSlot(completion: @escaping (Result<[TimeSlotAppointmentCount], Error>) -> Void) {
        AF.request("\(baseURL)/appointments/time-slot", headers: headers)
            .validate()
            .responseDecodable(of: [TimeSlotAppointmentCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }
    // 1. Kullanıcı rol dağılımı
    func getUserCountByRole(completion: @escaping (Result<[UserRoleCount], Error>) -> Void) {
        AF.request("\(baseURL)/users/roles", headers: headers)
            .validate()
            .responseDecodable(of: [UserRoleCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // 2. Cinsiyet dağılımı
    func getUserCountByGender(completion: @escaping (Result<[GenderCount], Error>) -> Void) {
        AF.request("\(baseURL)/users/genders", headers: headers)
            .validate()
            .responseDecodable(of: [GenderCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // 3. Kan grubu dağılımı
    func getUserCountByBloodType(completion: @escaping (Result<[BloodTypeCount], Error>) -> Void) {
        AF.request("\(baseURL)/users/blood-types", headers: headers)
            .validate()
            .responseDecodable(of: [BloodTypeCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // 4. Kliniklere göre doktor sayısı
    func getDoctorCountByClinic(completion: @escaping (Result<[ClinicDoctorCount], Error>) -> Void) {
        AF.request("\(baseURL)/clinics/doctor-count", headers: headers)
            .validate()
            .responseDecodable(of: [ClinicDoctorCount].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    
}
