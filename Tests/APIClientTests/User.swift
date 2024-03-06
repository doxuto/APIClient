//
//  User.swift
//
//
//  Created by doxuto on 06/03/2024.
//

import Foundation

struct User: Decodable {
    let userId: String
    let email: String
    let name: String
    let givenName: String
    let familyName: String
    let nickname: String
    let lastIp: String
    let loginsCount: Int
    let createdAt: Date
    let updatedAt: Date
    let lastLogin: Date
    let emailVerified: Bool
}


let userJson =
"""
{
"user_id": "583c3ac3f38e84297c002546",
"email": "test@test.com",
"name": "test@test.com",
"given_name": "Hello",
"family_name": "Test",
"nickname": "test",
"last_ip": "94.121.163.63",
"logins_count": 15,
"created_at": "2016-11-28T14:10:11.338Z",
"updated_at": "2016-12-02T01:17:29.310Z",
"last_login": "2016-12-02T01:17:29.310Z",
"email_verified": true
  }
"""

let userJsonWithTimestamp =
"""
{
"user_id": "583c3ac3f38e84297c002546",
"email": "test@test.com",
"name": "test@test.com",
"given_name": "Hello",
"family_name": "Test",
"nickname": "test",
"last_ip": "94.121.163.63",
"logins_count": 15,
"created_at": "1600000000000",
"updated_at": "1600000000000",
"last_login": "1600000000000",
"email_verified": true
  }
"""
