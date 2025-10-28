//
//  CategoryBadge.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct CategoryBadge: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black)
            .cornerRadius(8)
    }
}

#Preview {
    HStack(spacing: 20) {
        CategoryBadge(title: "bday")
        CategoryBadge(title: "congrats")
    }
}

