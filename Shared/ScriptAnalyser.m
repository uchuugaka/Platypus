/*
 Copyright (c) 2003-2015, Sveinbjorn Thordarson <sveinbjornt@gmail.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 
 3. Neither the name of the copyright holder nor the names of its contributors may
 be used to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

//
//  This is a class with convenience and analytical methods for the
//  script file types handled by Platypus.
//

#import "ScriptAnalyser.h"

@implementation ScriptAnalyser

+ (NSArray *)interpreters {
    return [NSArray arrayWithObjects:
            @"/bin/sh",
            @"/bin/bash",
            @"/bin/csh",
            @"/bin/tcsh",
            @"/bin/ksh",
            @"/bin/zsh",
            @"/usr/bin/env",
            @"/usr/bin/perl",
            @"/usr/bin/python",
            @"/usr/bin/ruby",
            @"/usr/bin/osascript",
            @"/usr/bin/tclsh",
            @"/usr/bin/expect",
            @"/usr/bin/php",
            @"",
            nil];
}

+ (NSArray *)interpreterDisplayNames {
    return [NSArray arrayWithObjects:
            @"Shell",
            @"Bash",
            @"Csh",
            @"Tcsh",
            @"Ksh",
            @"Zsh",
            @"Env",
            @"Perl",
            @"Python",
            @"Ruby",
            @"AppleScript",
            @"Tcl",
            @"Expect",
            @"PHP",
            @"Other...",
            nil];
}

// a mapping between scripting languages and a simple hello world program
// implemented in said language

+ (NSDictionary *)interpreterHelloWorlds {
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                @"echo 'Hello, World'",
                                                @"echo 'Hello, World'",
                                                @"echo 'Hello, World'",
                                                @"echo 'Hello, World'",
                                                @"echo 'Hello, World'",
                                                @"echo 'Hello, World'",
                                                @"",
                                                @"print \"Hello, World\\n\";",
                                                @"print \"Hello, World\";",
                                                @"puts \"Hello, World\";",
                                                @"",
                                                @"puts \"Hello, World\";",
                                                @"send \"Hello, world\\n\"",
                                                @"<?php\necho \"Hello, World\";\n?>",
                                                @"",
                                                nil] forKeys:[NSArray arrayWithObjects:
                                                              @"Shell",
                                                              @"Bash",
                                                              @"Csh",
                                                              @"Tcsh",
                                                              @"Ksh",
                                                              @"Zsh",
                                                              @"Env",
                                                              @"Perl",
                                                              @"Python",
                                                              @"Ruby",
                                                              @"AppleScript",
                                                              @"Tcl",
                                                              @"Expect",
                                                              @"PHP",
                                                              @"Other...",
                                                              nil]];
}

+ (NSString *)displayNameForInterpreter:(NSString *)theInterpreter {
    NSArray *interpreters = [self interpreters];
    int i;
    for (i = 0; i < [interpreters count]; i++)
        if ([theInterpreter isEqualToString:[interpreters objectAtIndex:i]])
            return [[self interpreterDisplayNames] objectAtIndex:i];
    
    return @"Other...";
}

+ (NSString *)interpreterForDisplayName:(NSString *)name {
    NSArray *interpreters = [self interpreters];
    NSArray *interpreterDisplayNames = [self interpreterDisplayNames];
    
    int i;
    for (i = 0; i < [interpreterDisplayNames count]; i++)
        if ([name isEqualToString:[interpreterDisplayNames objectAtIndex:i]])
            return [interpreters objectAtIndex:i];
    
    return @"";
}

/**************************************************
 - Determine script type based on a file's suffix
 **************************************************/

+ (NSString *)interpreterFromSuffix:(NSString *)fileName {
    NSArray *interpreters = [self interpreters];
    
    if ([fileName hasSuffix:@".sh"] || [fileName hasSuffix:@".command"])
        return [interpreters objectAtIndex:0];
    else if ([fileName hasSuffix:@".bash"])
        return [interpreters objectAtIndex:1];
    else if ([fileName hasSuffix:@".csh"])
        return [interpreters objectAtIndex:2];
    else if ([fileName hasSuffix:@".tcsh"])
        return [interpreters objectAtIndex:3];
    else if ([fileName hasSuffix:@".ksh"])
        return [interpreters objectAtIndex:4];
    else if ([fileName hasSuffix:@".zsh"])
        return [interpreters objectAtIndex:5];
    else if ([fileName hasSuffix:@".pl"] || [fileName hasSuffix:@".perl"] || [fileName hasSuffix:@".pm"])
        return [interpreters objectAtIndex:6];
    else if ([fileName hasSuffix:@".py"] || [fileName hasSuffix:@".python"] || [fileName hasSuffix:@".objpy"])
        return [interpreters objectAtIndex:7];
    else if ([fileName hasSuffix:@".rb"] || [fileName hasSuffix:@".rbx"] || [fileName hasSuffix:@".ruby"] | [fileName hasSuffix:@".rbw"])
        return [interpreters objectAtIndex:8];
    else if ([fileName hasSuffix:@".scpt"] || [fileName hasSuffix:@".applescript"] || [fileName hasSuffix:@".osascript"])
        return [interpreters objectAtIndex:9];
    else if ([fileName hasSuffix:@".tcl"] || [fileName hasSuffix:@".tcsh"])
        return [interpreters objectAtIndex:10];
    else if ([fileName hasSuffix:@".exp"] || [fileName hasSuffix:@".expect"])
        return [interpreters objectAtIndex:11];
    else if ([fileName hasSuffix:@".php"] || [fileName hasSuffix:@".php4"] || [fileName hasSuffix:@".php5"] ||
             [fileName hasSuffix:@".php3"] || [fileName hasSuffix:@".hp3"] || [fileName hasSuffix:@".ph4"] || [fileName hasSuffix:@".phtml"])
        return [interpreters objectAtIndex:12];
    
    return @"";
}

/***********************************************************************************************
 - Parse the Shebang line (#!) to get the interpreter for the script + arguments to interpreter
 ***********************************************************************************************/

+ (NSArray *)getInterpreterFromShebang:(NSString *)path {
    // get the first line of the script
    NSString *script = [NSString stringWithContentsOfFile:path encoding:DEFAULT_OUTPUT_TXT_ENCODING error:nil];
    NSArray *lines = [script componentsSeparatedByString:@"\n"];
    if (![lines count]) // empty file
        return [NSArray arrayWithObject:@""];
    NSString *firstLine = [lines objectAtIndex:0];

    // if shorter than 2 chars, it can't possibly be a shebang line
    if ([firstLine length] <= 2)
        return [NSArray arrayWithObject:@""];
    
    // get first two characters of first line
    NSString *shebang = [firstLine substringToIndex:2];  // first two characters should be #!
    if (![shebang isEqualToString:@"#!"])
        return [NSArray arrayWithObject:@""];
    
    // get everything that follows after the #!
    // seperate it by whitespaces, in order not to get also the params to the interpreter
    NSString *interpreterCmd = [firstLine substringFromIndex:2];
    NSArray *words = [interpreterCmd componentsSeparatedByString:@" "];
    return ([[words retain] autorelease]); // return array w. interpreter + arguments for it
}

/********************************************************
 - Utility method used by both app and command line tool
 ********************************************************/

+ (NSString *)appNameFromScriptFileName:(NSString *)path {
    NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
    
    // replace these common filename word separators w. spaces
    name = [name stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    name = [name stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    
    // iterate over each word, capitalize and append to app name
    NSArray *words = [name componentsSeparatedByString:@" "];
    NSString *appName = @"";
    int i;
    for (i = 0; i < [words count]; i++) {
        if (i != 0)
            appName = [appName stringByAppendingString:@" "];
        appName = [appName stringByAppendingString:[[words objectAtIndex:i] capitalizedString]];
    }
    return appName;
}

/*****************************************
 - Try to determine the interpreter of the script, return path to it
 *****************************************/

+ (NSString *)determineInterpreterForScriptFile:(NSString *)path {
    NSString *interpreter = [[self getInterpreterFromShebang:path] objectAtIndex:0];
    if (![interpreter isEqualToString:@""])
        return interpreter;
    
    return [self interpreterFromSuffix:path];
}

/*****************************************
 - Report on syntax of script
 *****************************************/

+ (NSString *)checkSyntaxOfFile:(NSString *)scriptPath withInterpreter:(NSString *)suggestedInterpreter {
    NSTask *task;
    NSString *interpreter = suggestedInterpreter;
    NSPipe *outputPipe = [NSPipe pipe];
    NSFileHandle *readHandle;
    
    if (![FILEMGR fileExistsAtPath:scriptPath])  //make sure it exists
        return @"File does not exist";
    
    if (interpreter == nil || [interpreter isEqualToString:@""])
        interpreter = [self determineInterpreterForScriptFile:scriptPath];
    
    if ([interpreter isEqualToString:@""])
        return @"Unable to determine script interpreter";
    
    //let's see if the script type is supported for syntax checking
    //if so, we set up the task's launch path as the script interpreter and set the relevant flags and arguments
    NSArray *args = nil;
    
    if ([interpreter isEqualToString:@"/bin/sh"])
        args = [NSArray arrayWithObjects:@"-n", scriptPath, nil];
    else if ([interpreter isEqualToString:@"/bin/bash"])
        args = [NSArray arrayWithObjects:@"-n", scriptPath, nil];
    else if ([interpreter isEqualToString:@"/usr/bin/perl"])
        args = [NSArray arrayWithObjects:@"-c", scriptPath, nil];
    else if ([interpreter isEqualToString:@"/usr/bin/ruby"])
        args = [NSArray arrayWithObjects:@"-c", scriptPath, nil];
    else if ([interpreter isEqualToString:@"/usr/bin/php"])
        args = [NSArray arrayWithObjects:@"-l", scriptPath, nil];
    else {
        return [NSString stringWithFormat:@"Syntax Checking is not supported by interpreter %@", interpreter];
    }
    
    task = [[NSTask alloc] init];
    
    [task setLaunchPath:interpreter];
    [task setArguments:args];
    
    //direct the output of the task into a file handle for reading
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    readHandle = [outputPipe fileHandleForReading];
    
    //launch task
    [task launch];
    [task waitUntilExit];
    
    //get output in string
    NSString *outputStr = [[[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:DEFAULT_OUTPUT_TXT_ENCODING] autorelease];
    
    [task release];
    
    //if the syntax report string is empty --> no complaints, so we report syntax as OK
    outputStr = [outputStr length] ? outputStr : @"Syntax OK";
    
    return outputStr;
}

@end
