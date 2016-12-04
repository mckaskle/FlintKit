//
//  MIT License
//
//  FileManager+FlintKit.swift
//
//  Copyright (c) 2016 Devin McKaskle
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation


extension FileManager {
  
  // MARK: - Enum
  
  private enum FileManagerError: Error {
    case cannotLoadCachesDirectory
    case cannotLoadDocumentDirectory
    case cannotLoadLibraryDirectory
  }
  
  
  // MARK: - Public Methods
  
  public func cachesDirectory() throws -> URL {
    guard let directory = urls(for: .cachesDirectory, in: .userDomainMask).first else {
      throw FileManagerError.cannotLoadCachesDirectory
    }
    
    return directory
  }
  
  public func documentsDirectory() throws -> URL {
    guard let directory = urls(for: .documentDirectory, in: .userDomainMask).first else {
      throw FileManagerError.cannotLoadDocumentDirectory
    }
    
    return directory
  }
  
  public func libraryDirectory() throws -> URL {
    guard let directory = urls(for: .libraryDirectory, in: .userDomainMask).first else {
      throw FileManagerError.cannotLoadLibraryDirectory
    }
    
    return directory
  }
  
  public func newUniqueFilename(in directory: URL, withExtension fileExtension: String) throws -> String {
    repeat {
      let fileUrl = directory
        .appendingPathComponent(UUID().uuidString, isDirectory: false)
        .appendingPathExtension(fileExtension)
      
      let path = fileUrl.path
      let filename = fileUrl.lastPathComponent
      
      guard !fileExists(atPath: path) else { continue } // try again;
      
      return filename
    } while true
  }
  
}
