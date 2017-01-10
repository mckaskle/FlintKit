//
//  MIT License
//
//  UTI.swift
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
import MobileCoreServices

/**
 
 Converts a MIME type to a UTI.
 
 - Parameter MIMEType: The MIME type to be converted
 
 - Returns: The UTI for the given MIME type.
 
 - Note: If no result is found, this function creates a dynamic type beginning
    with the dyn prefix. This allows you to pass the UTI around and convert
    it back to the original tag.
 
 */
public func UTIForMIMEType(_ MIMEType: String) -> String {
  // Note: because we are not constraining the UTI to conform
  // to any UTI, there will always be a return value. It is
  // therefore known to be safe to force unwrap the return
  // value.
  let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType as CFString, nil)
  return UTI!.takeRetainedValue() as String
}


public func fileExtension(forUTI UTI: String) -> String? {
  let fileExtension = UTTypeCopyPreferredTagWithClass(UTI as CFString, kUTTagClassFilenameExtension)
  return fileExtension?.takeRetainedValue() as String?
}
