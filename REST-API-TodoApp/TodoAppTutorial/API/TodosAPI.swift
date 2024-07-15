//
//  TodosAPI.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation

enum TodosAPI {
    
    static let version = "v2"
    
    /*
     회사가면 디버그 서버, 릴리즈 서버 따로 있을 수 있음 + 앱스토어 배포 위해서는 릴리즈 버전으로 올라감
     디버그, 릴리즈에 따라 baseURL 변경을 해줄 수 있음
     */
#if DEBUG // 디버그
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
#else // 릴리즈
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
#endif
    
    // 커스텀 에러타입 정의
    enum ApiError : Error {
        case noContent
        case decodingError
        case unauthorized
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        
        // 이렇게 변수 하나 만들어서 우리가 문자열로 만들어 사용 할 수 있음
        var info : String {
            switch self {
            case .noContent :           return "데이터가 없습니다."
            case .decodingError :       return "디코딩 에러입니다."
            case .unauthorized :        return "인증되지 않은 사용자 입니다."
            case let .badStatus(code):  return "에러 상태코드 : \(code)"
            case .unknown(let err):     return "알 수 없는 에러입니다 \n \(err)"
            }
        }
    }
    
    /// 모든 할 일 목록 가져오기
    /// 페이지가 아무것도 안들어오면 1페이지로 설정
    /// 비동기 처리를 위해 completion 클로저 사용 성공시 TodosResponse, 실패시 ApiError 를 반환
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<TodosResponse, ApiError>) -> Void){
        
        /*
         curl -X 'GET' \
         'https://phplaravel-574671-2962113.cloudwaysapps.com/api/v2/todos?page=1&filter=created_at&order_by=desc&per_page=10' \
         -H 'accept: application/json' \
         -H 'X-CSRF-TOKEN: YRDMXUJh9PenQZP12D9GgTXxdGmhMpb2wRjAIAN6'
         */
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        let url = URL(string: urlString)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept") // 헤더에 값 넣기
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print("data: \(data)") // 실제 Json 데이터
            print("urlResponse: \(urlResponse)") // 호출시 들어오는 모든 데이터 ex 상태 값
            print("err: \(err)")
            
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            // HTTPURLResponse가 아니면 모르는 에러
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            // 인증이 되지 않았으면 에러 반환
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            default: print("default")
            }
            
            // 200번대가 아니면 에러를 던짐
            if !(200...299).contains(httpResponse.statusCode){
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
                    let todosResponse = try JSONDecoder().decode(TodosResponse.self, from: jsonData)
                    let todos = todosResponse.data
                    print("todosResponse: \(todosResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos, // todos가 비어있거나 nil이면 에러 바놘
                          !todos.isEmpty else {
                        return completion(.failure(ApiError.noContent))
                    }
                    
                    completion(.success(todosResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
    }
    
}




