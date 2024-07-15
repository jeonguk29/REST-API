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
        case notAllowedUrl
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        
        var info : String {
            switch self {
            case .noContent :           return "데이터가 없습니다."
            case .decodingError :       return "디코딩 에러입니다."
            case .unauthorized :        return "인증되지 않은 사용자 입니다."
            case .notAllowedUrl :       return "올바른 URL 형식이 아닙니다."
            case let .badStatus(code):  return "에러 상태코드 : \(code)"
            case .unknown(let err):     return "알 수 없는 에러입니다 \n \(err)"
            }
        }
    }
    
    /// 모든 할 일 목록 가져오기
    /// 페이지가 아무것도 안들어오면 1페이지로 설정
    /// 비동기 처리를 위해 completion 클로저 사용 성공시 TodosResponse, 실패시 ApiError 를 반환
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void){
        
        /*
         curl -X 'GET' \
         'https://phplaravel-574671-2962113.cloudwaysapps.com/api/v2/todos?page=1&filter=created_at&order_by=desc&per_page=10' \
         -H 'accept: application/json' \
         -H 'X-CSRF-TOKEN: YRDMXUJh9PenQZP12D9GgTXxdGmhMpb2wRjAIAN6'
         */
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        
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
                    // 파싱할때 제네릭으로 만든 BaseListResponse로 받고 안에들어가는 타입은 todo로 하겠다 말하기
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos, // todos가 비어있거나 nil이면 에러 바놘
                          !todos.isEmpty else {
                        return completion(.failure(ApiError.noContent))
                    }
                    
                    completion(.success(listResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
    }
    
    
    /// 특정 할 일 가져오기 - 외부에서 아이디만 넣어주면 됨
    /*
     💁 순서는 1. 서버 스웨거 기반으로 파싱 먼저 하기
             2. 잘못된 값으로 전달시 상태코드를 확인하여 에러 처리하기
     
     curl -X 'GET' \
       'https://phplaravel-574671-2962113.cloudwaysapps.com/api/v2/todos/5418' \
       -H 'accept: application/json' \
       -H 'X-CSRF-TOKEN: YRDMXUJh9PenQZP12D9GgTXxdGmhMpb2wRjAIAN6'
     */
    static func fetchATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void){
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
            print("err: \(err)")
            
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            // 에러 체크를 한번 하고 내리기 
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                  // decoding error
                    completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
    }
    
    
    /// 할 일 검색하기
    /*
     curl -X 'GET' \
       'https://phplaravel-574671-2962113.cloudwaysapps.com/api/v2/todos/search?query=%ED%83%80%EC%9D%B4%ED%8B%80&filter=created_at&order_by=desc&page=1&per_page=10' \
       -H 'accept: application/json' \
       -H 'X-CSRF-TOKEN: YRDMXUJh9PenQZP12D9GgTXxdGmhMpb2wRjAIAN6'
     */
    static func searchTodos(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void){
        
        // 1. urlRequest 를 만든다
        
   
        // let urlString = baseURL + "/todos/search" + "?query=\(searchTerm)" + "&page=\(page)"
        // ⭐️ 이렇게 직접 적으면 귀찮고 실수할 가능성이 높아짐 이걸 개선 하는 방법이 URL 컴포넌트를 활용하는 것임

        //        var urlComponents = URLComponents(string: baseURL + "/todos/search")
        //        urlComponents?.queryItems = [
        //            URLQueryItem(name: "query", value: searchTerm),
        //            URLQueryItem(name: "page", value: "\(page)")
        //        ]
        //
        //
        //        guard let url = urlComponents?.url else {
        //            return completion(.failure(ApiError.notAllowedUrl))
        //        }
        
        // extention 활용
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm, "page" : "\(page)"])
        
        guard let url = requestUrl else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
            print("err: \(err)")
            
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
                  let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                  let todos = listResponse.data
                    print("todosResponse: \(listResponse)")
                    
                    // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        return completion(.failure(ApiError.noContent))
                    }
                    
                    completion(.success(listResponse))
                } catch {
                  // decoding error
                    completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
    }
    
}




