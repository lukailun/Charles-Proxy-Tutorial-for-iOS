/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

protocol CountriesRepositoryProtocol {
  func loadCountries(_ countriesDidLoad: @escaping (Result<[Country], CountriesLoadError>) -> Void)
}

final class CountriesRepository: CountriesRepositoryProtocol {
  private let endpoint = "https://restcountries.eu/rest/v2/all"

  func loadCountries(_ countriesDidLoad: @escaping (Result<[Country], CountriesLoadError>) -> Void) {
    guard let url = URL(string: endpoint) else {
      countriesDidLoad(.failure(.invalidURL))
      return
    }
    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    URLSession.shared.dataTask(with: request) { data, _, error in
      if let data = data {
        if let decodedResponse = try? JSONDecoder().decode([Country].self, from: data) {
          DispatchQueue.main.async {
            countriesDidLoad(.success(decodedResponse))
          }
          return
        }
      }

      countriesDidLoad(.failure(.other(description: error?.localizedDescription ?? "Unknown error")))
    }
    .resume()
  }
}

enum CountriesLoadError: Error {
  case invalidURL, other(description: String)
}
