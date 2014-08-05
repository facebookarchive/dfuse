# dfuse
*dfuse* is a [D language binding](http://dlang.org) for the high level
[fuse](http://fuse.sourceforge.net) library. It allows to write a fuse
filesystem for Linux or Mac OS (using [osxfuse](http://osxfuse.github.io)) in D.

Fuse is a library and kernel extension to write filesystems in userspace. These
filesystems are easy to implement and have access to userland components like
HTTP libraries, etc. For more information about fuse see: http://fuse.sourceforge.net.

## Examples
A simple filesystems implementing a directory listing can be found in the [examples/](https://github.com/facebook/dfuse/tree/master/example) directory.
You can build the examples using:
```Shell
$ make examples
$ mkdir /mnt/simplefs
$ ./simplefs /mnt/simplefs
```

## Implementing a filesystem
dfuse provides a high level interface for libfuse. To implement a filesystem, extend the *Operations* class in the *dfuse.fuse* module:
```D
import dfuse.fuse;

class MyFS : Operations
{
    override void getattr(const(char)[] path, ref stat_t s)
    {
        /* implementation */
        throw new FuseException(EOPNOTSUPP);
    }
    
    override string[] readdir(const(char)[] path)
    {
       return [/*...list of files...*/];
    }
    
    override ulong read(const(char)[] path, ubyte[] buf, ulong offset)
    {
       /* implementation */
       throw new FuseException(EOPNOTSUPP);
    }
}
```

A minimal filesystem implements `Operations.getattr()`, `Operations.readdir()`, `Operations.read()`. See [dfuse/fuse.d](https://github.com/facebook/dfuse/blob/master/dfuse/fuse.d) for implementation specific details.

To mount a filesystem use a Fuse object and call mount:
```D
import dfuse.fuse;

int main(string[] args)
{
    /* foreground=true, threading=false */
    auto fs = new Fuse("MyFS", true, false);
    fs.mount(new MyFS(), "/mnt", ["allow_other"]);
}
```

Error conditions are handled by throwin a *FuseException* with the appropriate error number. See `man 3 errno` for more information about errno.

## Requirements
dfuse requires:
* Mac OS X or Linux
* fuse >= 2.8.0 or [osxfuse](http://osxfuse.github.io/) >= 2.6.0
* DMD/Druntime/Phobos >= 2.065

## Building dfuse
dfuse comes with a standard makefile that assumes that DMD (the D-compiler) is
in your $PATH.

### Linux
In order to compile dfuse on Linux:
```Shell
$ make dfuse
or
$ make dfuse ENABLE_DEBUG=1
to build a debug version
```

### MacOS
MacOS supports two inode sizes which are both supported by OSXfuse, however when
compiling dfuse you have to be aware which OSXfuse should be linked.

By default dfuse is trying to build with a 32bit inode size and link against
osxfuse_i32 which is part of OSXfuse for compatibility. Please note that your
library itself will still be 64bit on a 64bit system. The setting only affects
the size of the inode.

To build just run
```Shell
$ make dfuse
```

If you want to compile with 64bit inodes you need a at least DMD, Druntime,
Phobos in version 2.066:
```Shell
$ make dfuse ENABLE_64BIT=1
```

### Dub
dfuse comes with experimental support for [dub](http://code.dlang.org/), a package manager for D. See the dub documentation how to build and use dub.

## Installing dfuse
At the moment the dfuse makefile doesn't support an install target. It is
recommended to just include the library in a project at this point.

## How dfuse works
dfuse is a simple D wrapper. It exposes a lowelevel interface to the libfuse C
functions in c/fuse/fuse.d. The lowlevel interface preserves C types.

A highlevel interface is provided by fs/fuse.d. The D interface initializes fuse filsystems operations structure and installs it's own handlers. Every dfuse handler converts C
types to D types and is trapping FuseExceptions used for error handling. The
handlers keep track of the initialized Operations object and call the
appropriate method once types are converted and pass the result into the D
layer.

The user facing interface is the *Operations* class in fs/fuse.d. It provides
default implementations for all handlers and every method can be invidually
overwritten to provide an interface.

## Issues and Bugs
If you encounter issues or bugs with dfuse, please file an issue on [github](https://github.com/facebook/dfuse/issues). Please ensure that you maintain a constructive feedback atmosphere and if possible attach a reproduction step. If you have any questions, feel free to write to the D mailinglist or ask in IRC.

Pull requests are highly appreciated!

## Join the dfuse community
* Website: https://github.com/facebook/dfuse/wiki
* Mailing list: [The D Mailinglist](http://lists.puremagic.com/cgi-bin/mailman/listinfo/digitalmars-d)
* irc: irc.freenode.net #d

## License
dfuse is Boost-licensed. We also provide an additional patent grant.
