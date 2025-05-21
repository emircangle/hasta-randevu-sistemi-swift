import Foundation
import Alamofire

class ExportService {
    static let shared = ExportService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/export"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    // Ortak CSV indirme fonksiyonu
    private func downloadCSV(from endpoint: String, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let url = "\(baseURL)/\(endpoint)"
        AF.download(url, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                        try data.write(to: fileURL)
                        completion(.success(fileURL))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // Export endpointleri (7 adet)
    func exportUsers(completion: @escaping (Result<URL, Error>) -> Void) {
        downloadCSV(from: "users", fileName: "users.csv", completion: completion)
    }

    func exportAppointments(completion: @escaping (Result<URL, Error>) -> Void) {
        downloadCSV(from: "appointments", fileName: "appointments.csv", completion: completion)
    }

    func exportComplaints(completion: @escaping (Result<URL, Error>) -> Void) {
        downloadCSV(from: "complaints", fileName: "complaints.csv", completion: completion)
    }

    func exportTestResults(completion: @escaping (Result<URL, Error>) -> Void) {
        downloadCSV(from: "test-results", fileName: "test-results.csv", completion: completion)
    }

    func exportPrescriptions(completion: @escaping (Result<URL, Error>) -> Void) {
        downloadCSV(from: "prescriptions", fileName: "prescriptions.csv", completion: completion)
    }

    func exportPatientHistories(completion: @escaping (Result<URL, Error>) -> Void) {
        downloadCSV(from: "patient-histories", fileName: "patient-histories.csv", completion: completion)
    }

    func exportPatientReports(completion: @escaping (Result<URL, Error>) -> Void) {
        downloadCSV(from: "patient-reports", fileName: "patient-reports.csv", completion: completion)
    }
}
