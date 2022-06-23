//
//  SecureInputField.swift
//  ShipItToMe
//
//  Created by Peter Friese on 01.05.21.
//

import SwiftUI
import Combine

public struct SecureInputField: View {
  private var title: String
  @Binding private var text: String
  @Environment(\.clearButtonHidden) var clearButtonHidden
  @Environment(\.isMandatory) var isMandatory
  @Environment(\.validationHandler) var validationHandler

  @Binding private var isValidBinding: Bool
  @State private var isValid: Bool = true {
    didSet {
      isValidBinding = isValid
    }
  }
  @State var validationMessage: String = ""

  public init(_ title: String, text: Binding<String>, isValid isValidBinding: Binding<Bool>? = nil) {
    self.title = title
    self._text = text
    self._isValidBinding = isValidBinding ?? .constant(true)
  }

  var clearButton: some View {
    HStack {
      if !clearButtonHidden {
        Spacer()
        Button(action: { text = "" }) {
          Image(systemName: "multiply.circle.fill")
            .foregroundColor(Color(UIColor.systemGray))
        }
      }
      else  {
        EmptyView()
      }
    }
  }

  var clearButtonPadding: CGFloat {
    !clearButtonHidden ? 25 : 0
  }

  fileprivate func validate(_ value: String) {
    isValid = true
    if isMandatory {
      isValid = !value.isEmpty
      validationMessage = isValid ? "" : "This is a mandatory field"
    }

    if isValid {
      guard let validationHandler = self.validationHandler else { return }

      let validationResult = validationHandler(value)

      if case .failure(let error) = validationResult {
        isValid = false
        self.validationMessage = "\(error.localizedDescription)"
      }
      else if case .success(let isValid) = validationResult {
        self.isValid = isValid
        self.validationMessage = ""
      }
    }
  }

  public var body: some View {
    ZStack(alignment: .leading) {
      if !isValid {
        Text(validationMessage)
          .foregroundColor(.red)
          .offset(y: -25)
          .scaleEffect(0.8, anchor: .leading)
      }
      if (text.isEmpty || isValid) {
        Text(title)
          .foregroundColor(text.isEmpty ? Color(.placeholderText) : .accentColor)
          .offset(y: text.isEmpty ? 0 : -25)
          .scaleEffect(text.isEmpty ? 1: 0.8, anchor: .leading)
      }
      SecureField("", text: $text)
        .onAppear {
          validate(text)
        }
        .onChange(of: text) { value in
          validate(value)
        }
        .padding(.trailing, clearButtonPadding)
        .overlay(clearButton)
    }
    .padding(.top, 15)
    .animation(.default, value: text)
  }
}

// MARK: - Previews

struct SecureInputField_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SecureInputField("First Name", text: .constant("Bowerick Wowbagger the Infinitely Prolonged from outer space"))
        .clearButtonHidden()
        .previewLayout(.sizeThatFits)
      SecureInputField("First Name", text: .constant("Peter"))
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
  }
}

// MARK: - Component Library

struct SecureInputField_Library: LibraryContentProvider {
  var views: [LibraryItem] {
    [LibraryItem(SecureInputField("First Name", text: .constant("Peter")), title: "SecureInputField", category: .control)]
  }

  func modifiers(base: SecureInputField) -> [LibraryItem] {
    [LibraryItem(base.clearButtonHidden(true), category: .control)]
  }
}
