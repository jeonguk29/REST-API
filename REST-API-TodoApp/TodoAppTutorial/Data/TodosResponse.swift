//
//  TodosResponse.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

// https://quicktype.io/ 들어가서 Json 값을 넣으면 잘 변환해줌
// 꼭 옵션에서 Make all properties optional 체크해주기 - 서버에서 들어오는 데이터가 없다면 크래시가 남
// 클라이언트 개발자는 최대한 파싱이 안될때에 대한 에러는 막아야함 (모든 화살이 나에게로)
import Foundation

// MARK: - TodosResponse
// JSON -> struct, class : 디코딩한다
struct TodosResponse: Decodable {
    let data: [Todo]?
    let meta: Meta?
    let message: String?
    let hey: String // 디코딩 에러 테스트
}

// MARK: - Datum
struct Todo: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey { // CodingKeys 서버에서 주는 이름이랑 다르게 사용하고 싶을때 사용
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}
