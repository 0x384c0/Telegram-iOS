//
//  UnixTime.swift
//  _idx_AccountContext_FFB9E9C3_ios_min9.0
//
//  Created by andrew on 10/8/22.
//

import Foundation
import SwiftSignalKit

/// API Fetcher, that works with time and timezones
public protocol UnixTimeFetcher {
    /// Asynchronously requests current timestamp.
    ///
    /// - Returns: Signal with timestamp or error
    func getTimeStamp() -> Signal<Int32, UnixTimeFetcherError>
}

/// Error, that could be returned from UnixTimeFetcher
public enum UnixTimeFetcherError: Error {
    case illegalUrl
    case noData
    case networkError
    case decodingError
}

extension TelegramEngine {
    /// private Implementation of UnixTimeFetcher
    final class UnixTimeFetcherImpl: UnixTimeFetcher {
        //MARK: Constants
        private static let BASE_URL = "http://worldtimeapi.org/api/"
        private static let MOSCOW_TIMEZONE_URL = "timezone/Europe/Moscow"
        private static let UNIX_TIME_FIELD = "unixtime"
        private static let STATUS_CODE_OK = 200

        //MARK: UnixTimeFetcher
        public func getTimeStamp() -> Signal<Int32, UnixTimeFetcherError> {
            return getDataSignal(
                baseUrl: TelegramEngine.UnixTimeFetcherImpl.BASE_URL,
                path: TelegramEngine.UnixTimeFetcherImpl.MOSCOW_TIMEZONE_URL
            ) |> mapToSignal({ [unowned self] data in
                self.getTimeDecodeSignal(data: data, field: TelegramEngine.UnixTimeFetcherImpl.UNIX_TIME_FIELD)
            })
        }

        //MARK: Private
        /// Performs data reques from url
        ///
        /// - parameter baseUrl: base url for request
        /// - parameter path: path to resource
        /// - returns: Signal with Data response
        private func getDataSignal(baseUrl:String, path:String) -> Signal<Data, UnixTimeFetcherError> {
            return Signal { subsriber in
                if let baseURL = URL(string: baseUrl),
                   let url = URL(
                    string: path,
                    relativeTo: baseURL
                   ){
                    let request = URLRequest(url: url)
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if error != nil || (response as? HTTPURLResponse)?.statusCode != TelegramEngine.UnixTimeFetcherImpl.STATUS_CODE_OK {
                            subsriber.putError(.networkError)
                        } else if let data = data {
                            subsriber.putNext(data)
                        } else {
                            subsriber.putError(.noData)
                        }
                    }
                    task.resume()
                } else {
                    subsriber.putError(.illegalUrl)
                }
                return EmptyDisposable
            }
        }

        /// Attemps to decode JSON field in to given T type
        ///
        /// - parameter data: data to decode
        /// - parameter field: JSON field for decoding
        /// - returns: Signal with decoded data of type T
        private func getTimeDecodeSignal<T>(data:Data, field:String) -> Signal<T, UnixTimeFetcherError> {
            return Signal { subsriber in
                if let dict = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                   let unixtime = dict[field] as? T {
                    subsriber.putNext(unixtime)
                } else {
                    subsriber.putError(.decodingError)
                }
                return EmptyDisposable
            }
        }
    }
}
