//
//  Memoize.swift
//  TogglWatch WatchKit Extension
//
//  Created by Juxhin Bakalli on 21/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

func memoize<Input, Output>(_ function: @escaping (Input) -> Output, areEqual: @escaping (Input, Input) -> Bool) -> (Input) -> Output
{
    var cache: (input: Input, output: Output)?
    
    func funcRef(_ param: Input) -> Output {
        if let cacheInput = cache?.input, areEqual(cacheInput, param), let cachedOutput = cache?.output { return cachedOutput }
        let newOutput = function(param)
        cache = (param, newOutput)
        return newOutput
    }
    
    return funcRef
}

func memoize<Input, Output>(_ function: @escaping (Input) -> Output) -> (Input) -> Output where Input: Equatable
{
    return memoize(function, areEqual: ==)
}
