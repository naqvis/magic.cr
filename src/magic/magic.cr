require "./lib"

module Magic
  # Represents File Magic details
  record Info, mime_type : String, encoding : String, name : String do
    protected def initialize(mime, name)
      raise "Invalid mime value passed" if mime.nil?
      parts = mime.split("; ")
      raise mime unless parts.size >= 2
      @name = name || ""
      @mime_type = parts[0]
      @encoding = parts[1].gsub("charset=", "")
    end

    def to_s(io : IO) : Nil
      io << "Detected MIME type: #{mime_type}\n"
      io << "Detected Encoding: #{encoding}\n"
      io << "Detected file type name: #{name}\n"
    end
  end

  class Magic
    def initialize(flags : MagicFlags)
      @handle = LibMagic.magic_open(flags.value)
      raise "Unable to get magic handle" if @handle.nil?
      load
    end

    # Returns a textual description of the contents of the argument passed
    # as a filename or Nil if an error occurred and the `MagicFlags::ERROR` flag
    # is set. A call to errno() will return the numeric error code.
    def file(filename)
      if ret = LibMagic.magic_file(self, filename)
        return String.new(ret)
      end
      if err = error
        raise err
      end
    end

    # Returns a textual description of the contents of the argument passed
    # as a file or Nil if an error occurred and the `MagicFlags::ERROR`
    # flag is set. A call to errno() will return the numeric error code.
    def descriptor(file : File)
      if ret = LibMagic.magic_descriptor(self, file.fd)
        return String.new(ret)
      end
    end

    # Returns a textual description of the contents of the argument passed
    # as a buffer or Nil if an error occurred and the `MagicFlags::ERROR`
    # flag is set. A call to errno() will return the numeric error code.
    def buffer(buf : Bytes)
      if ret = LibMagic.magic_buffer(self, buf.to_unsafe, buf.size)
        return String.new(ret)
      end
    end

    # Returns a textual description of the contents of the argument passed
    # as a buffer or Nil if an error occurred and the `MagicFlags::ERROR`
    # flag is set. A call to errno() will return the numeric error code.
    def buffer(buf : String)
      if ret = LibMagic.magic_buffer(self, buf.to_unsafe, buf.bytesize)
        return String.new(ret)
      end
    end

    # Returns a textual explanation of the last error or Nil
    # if there was no error.
    def error
      if ret = LibMagic.magic_error(self)
        return String.new(ret)
      end
    end

    # Set flags on the magic object which determine how magic checking
    # behaves; a bitwise OR of the flags described in libmagic(3).
    # Raises on systems that don't support utime(2) or utimes(2)
    # when `MagicFlags::PRESERVE_ATIME` is set.
    def set_flags(flags : MagicFlags)
      ret = LibMagic.magic_setflags(self, flags.value)
      if (ret == -1) && (err = error)
        raise err
      end
    end

    # Must be called to load entries in the colon separated list of database
    # files passed as argument or the default database file if no argument
    # before any magic queries can be performed.
    def load(filename = nil)
      ret = LibMagic.magic_load(self, filename)
      if (ret == -1) && (err = error)
        raise err
      end
    end

    # Compile entries in the colon separated list of database files
    # passed as argument or the default database file if no argument.
    # The compiled files created are named from the basename(1) of each file
    # argument with ".mgc" appended to it.
    def compile(dbs : String)
      ret = LibMagic.magic_compile(self, dbs)
      if (ret == -1) && (err = error)
        raise err
      end
    end

    # Check the validity of entries in the colon separated list of
    # database files passed as argument or the default database file
    # if no argument.
    def check(dbs : String)
      ret = LibMagic.magic_check(self, dbs)
      if (ret == -1) && (err = error)
        raise err
      end
    end

    def list(dbs : String)
      ret = LibMagic.magic_list(self, dbs)
      if (ret == -1) && (err = error)
        raise err
      end
    end

    # Returns a numeric error code. If return value is 0, an internal
    # magic error occurred. If return value is non-zero, the value is
    # an OS error code. Use the errno module or os.strerror() can be used
    # to provide detailed error information.
    def errno
      LibMagic.magic_errno(self)
    end

    # Returns the param value if successful, raises if param was unknown
    def get_param(param : MagicParam)
      LibMagic.magic_getparam(self, param.value, out val)
      raise error if val == -1 && error
      val
    end

    # Returns true if successful
    def set_param(param : MagicParam)
      LibMagic.magic_getparam(self, param.value, out val)
      raise error if val == -1 && error
      val == 0
    end

    # Closes the magic database and deallocates any resources used.
    def close
      LibMagic.magic_close(self)
    end

    private def to_unsafe
      @handle
    end
  end

  # Flags for Magic open
  @[Flags]
  enum MagicFlags
    # Turn on debuggin
    DEBUG = 1
    # Follow symlinks
    SYMLINK = 2
    # Check inside compressed files
    COMPRESS = 4
    # Look at the contents of devices
    DEVICES = 8
    # Return the MIME type
    MIME_TYPE = 16
    # Return all matches
    CONTINUE = 32
    # Print warnings to stderr
    CHECK = 64
    # Restore access time on exit
    PRESERVE_ATIME = 128
    # Don't convert unprintable chars
    RAW = 256
    # Handle ENOENT etc as real errors
    ERROR = 512
    # Return the MIME encoding
    MIME_ENCODING = 1024

    MIME = MIME_TYPE | MIME_ENCODING
    # Return the Apple creator/type
    APPLE = 2048
    # Return a /-separated list of extensions
    EXTENSION = 16777216
    # Check inside compressed files but not report compression
    COMPRESS_TRANSP = 33554432
    NODESC          = (EXTENSION | MIME | APPLE)

    # Don't check for compressed files
    NO_CHECK_COMPRESS = 4096
    # Don't check for tar files
    NO_CHECK_TAR = 8192
    # Don't check magic entries
    NO_CHECK_SOFT = 16384
    # Don't check application type
    NO_CHECK_APPTYPE = 32768
    # Don't check for elf details
    NO_CHECK_ELF = 65536
    # Don't check for text files
    NO_CHECK_TEXT = 131072
    # Don't check for cdf files
    NO_CHECK_CDF = 262144
    # Don't check for CSV files
    NO_CHECK_CSV = 524288
    #  Don't check tokens
    NO_CHECK_TOKENS = 1048576
    # Don't check text encodings
    NO_CHECK_ENCODING = 2097152
    # Don't check for JSON files
    NO_CHECK_JSON = 4194304
    # No built-in tests; only consult the magic file
    NO_CHECK_BUILTIN = NO_CHECK_COMPRESS | NO_CHECK_TAR | NO_CHECK_APPTYPE |
      NO_CHECK_ELF | NO_CHECK_TEXT | NO_CHECK_CSV | NO_CHECK_CDF |
      NO_CHECK_TOKENS | NO_CHECK_ENCODING | NO_CHECK_JSON | 0
  end

  enum MagicParam
    PARAM_INDIR_MAX     = 0
    PARAM_NAME_MAX      = 1
    PARAM_ELF_PHNUM_MAX = 2
    PARAM_ELF_SHNUM_MAX = 3
    PARAM_ELF_NOTES_MAX = 4
    PARAM_REGEX_MAX     = 5
    PARAM_BYTES_MAX     = 6
    PARAM_ENCODING_MAX  = 7
  end

  # :nodoc:
  MIME_MAGIC = Magic.new(MagicFlags::MIME)
  # :nodoc:
  NONE_MAGIC = Magic.new(MagicFlags::None)

  at_exit {
    MIME_MAGIC.close
    NONE_MAGIC.close
  }
end
