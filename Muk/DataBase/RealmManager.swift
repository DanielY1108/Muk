//
//  RealmManager.swift
//  Muk
//
//  Created by JINSEOK on 2023/05/15.
//

import UIKit
import RealmSwift

final class RealmManager {
    
    static let shared = RealmManager()
    
    let realm: Realm
    
    private init() {
        self.realm = try! Realm()
    }
    
    ///  쓰기
    /// - Parameter object: 모델
    func write<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
                print("Sucess save \(realm.configuration.fileURL)")
            }
        } catch {
            print(error)
        }
    }
    
    /// 읽기
    /// - Parameter objectTpye: 모델 타입
    /// - Returns: 선택한 모델들을 리턴
    func load<T: Object>(_ objectTpye: T.Type) -> Results<T> {
        let realm = realm.objects(objectTpye)
        return realm
    }
    
    
    /// 삭제
    /// - Parameter object: 모델
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    func update<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            print("Failed Update")
        }
    }
    
    // 정렬하기
    func sort<T: Object>(_ objectTpye: T.Type, by keyPath: String, ascending: Bool) -> Results<T> {
        return load(objectTpye).sorted(byKeyPath: keyPath, ascending: ascending)
    }
}
