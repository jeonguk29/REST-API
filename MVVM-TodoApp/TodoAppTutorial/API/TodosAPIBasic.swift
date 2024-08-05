//
//  TodosAPI.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation
import MultipartForm

extension TodosAPI {
    

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
    
    
    /// 할 일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    /*
     curl -X 'POST' \
       'https://phplaravel-574671-2962113.cloudwaysapps.com/api/v2/todos' \
       -H 'accept: application/json' \
       -H 'Content-Type: multipart/form-data' \
       -H 'X-CSRF-TOKEN: YRDMXUJh9PenQZP12D9GgTXxdGmhMpb2wRjAIAN6' \
       -F 'title=난나나나나나나나나나난' \
       -F 'is_done=false'
    */
    static func addATodo(title: String,
                         isDone: Bool = false,
                         completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void){
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        
        // 헤더 부분에 대한 설정
        urlRequest.httpMethod = "POST"
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        print("form.contentType : \(form.contentType)") // ⭐️ MultipartForm에서 제일 중요한거 1 contentType 생성
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = form.bodyData // ⭐️ MultipartForm에서 제일 중요한거 2 post 방식 사용시 httpBody에 date 넣어줘야함 이걸 제공해줌 
        
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
            case 422:
                if let data = data,
                   let errResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    return completion(.failure(ApiError.errResponseFromServer(errResponse)))
                }
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
    
    
    
    /// 할 일 추가하기 - Json
    /// requestParams를 가지고 Json data를  만들어서 리퀘스트 httpBody 에 넣어서 호출하는 방식
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    static func addATodoJson(title: String,
                         isDone: Bool = false,
                         completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void){
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["title": title, "is_done" : "\(isDone)"]
        
        // dic => data로 변환하여 body에 담기
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
            
        } catch {
            
            return completion(.failure(ApiError.jsonEncoding))
        }
        
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
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                  // decoding error
                    completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
    }
    
    /// 할 일 수정하기 - Json
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료여부
    ///   - completion: 응답결과
    static func editTodoJson(id: Int,
                             title: String,
                             isDone: Bool = false,
                             completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void){
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["title": title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
            
        } catch {
            
            return completion(.failure(ApiError.jsonEncoding))
        }
        
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
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                  // decoding error
                    completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
    }
    
    /// 할 일 수정하기 - PUT urlEncoded
    /// -H 'Content-Type: application/x-www-form-urlencoded' \   - 라고 되어있음 encoded 로 들어간다는건 뭔가 암호화 식으로 들어간다는 뜻
    /// -d 'title=%EA%B0%80%EC%A6%88%EC%95%84%EC%95%84%EC%95%84%EC%95%84%EC%95%84%EC%95%84%EC%95%84%EC%95%84&is_done=true'
    /// 위 처럼 들어감
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료여부
    ///   - completion: 응답결과
    static func editTodo(id: Int,
                             title: String,
                             isDone: Bool = false,
                             completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void){
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : String] = ["title": title, "is_done" : "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams) // 헤당 메서드가 바디에 넣는거 까지 해줌 
        
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
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                  // decoding error
                    completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
    }
    
    /// 할 일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답결과
    static func deleteATodo(id: Int,
                         completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void){
        
        print(#fileID, #function, #line, "- deleteATodo 호출됨 / id: \(id)")
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
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
                  let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                  // decoding error
                    completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
    }
    
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 응답 결과
    ///  동시 처리를 하다가 중간에 하나 에러가 발생했을때 어떻게 처리 즉 어떻게 반환할지(컴플리션으로)
    static func fetchSelectedTodos(selectedTodoIds: [Int],
                                    completion: @escaping (Result<[Todo], ApiError>) -> Void){
        
        let group = DispatchGroup()
        
        // 가져온 할일들
        var fetchedTodos : [Todo] = [Todo]()
        
        // 에러들
        var apiErrors : [ApiError] = []
        
        // 응답 결과들
        var apiResults = [Int : Result<BaseResponse<Todo>, ApiError>]()
        
        
        selectedTodoIds.forEach { aTodoId in // 특정아이디로 할일을 조회
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            self.fetchATodo(id: aTodoId,
                             completion: { result in
                switch result {
                case .success(let response):
                    // 가져온 할일을 가져온 할일 배열에 넣는다
                    if let todo = response.data {
                        fetchedTodos.append(todo)
                        print("inner fetchATodo - success: \(todo)")
                    }
                case .failure(let failure):
                    apiErrors.append(failure) // 실패시 에러를 에러 배열에 넣는다
                    print("inner fetchATodo - failure: \(failure)")
                }
                group.leave()
            })// 단일 할일 조회 API 호출
        }
        
        // Configure a completion callback
        group.notify(queue: .main) {
            // All requests completed
            print("모든 api 완료 됨")
            
            // 만약 에러가 있다면 에러 올려주기
            if !apiErrors.isEmpty {
                if let firstError = apiErrors.first {
                    completion(.failure(firstError)) // 에러가 존재한다면 첫번째 에러를 던짐
                    return
                }
            }
            
            completion(.success(fetchedTodos)) // 아무 이상이 없다면 가져온 할일들 던짐
        }
    }
}




