/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the Boost-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */
import dfuse.fuse;

import std.algorithm, std.conv, std.stdio;

/**
 * A simple directory listing using dfuse
 */
class SimpleFS : Operations
{
    override void getattr(const(char)[] path, ref stat_t s)
    {
        if (path == "/")
        {
            s.st_mode = S_IFDIR | octal!755;
            s.st_size = 0;
            return;
        }

        if (path.among("/a", "/b"))
        {
            s.st_mode = S_IFREG | octal!644;
            s.st_size = 42;
            return;
        }

        throw new FuseException(errno.ENOENT);
    }

    override string[] readdir(const(char)[] path)
    {
        if (path == "/")
        {
            return ["a", "b"];
        }

        throw new FuseException(errno.ENOENT);
    }
}

int main(string[] args)
{
    if (args.length != 2)
    {
        stderr.writeln("simplefs <MOUNTPOINT>");
        return -1;
    }

    stdout.writeln("mounting simplefs");

    auto fs = new Fuse("SimpleFS", true, false);
    fs.mount(new SimpleFS(), args[1], []);

    return 0;
}
