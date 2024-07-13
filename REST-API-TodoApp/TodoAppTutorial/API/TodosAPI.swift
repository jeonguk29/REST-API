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
        case parsingError
        case noContent
        case decodingError
        case badStatus(code: Int)
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
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
                  let todosResponse = try JSONDecoder().decode(TodosResponse.self, from: jsonData)
                  let modelObjects = todosResponse.data // data 즉 todo 배열만 사용하고 싶다
                    print("todosResponse: \(todosResponse)")
                    completion(.success(todosResponse)) // completion 함수이고 매개변수가 Result 타입임 
                } catch {
                  // decoding error
                    completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
    }
    
}




