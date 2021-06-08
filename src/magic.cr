require "./magic/magic"

# Crystal bindings to `libmagic`
module Magic
  VERSION = "0.1.0"

  # Detect mime type, encoding and file type
  def self.detect(filename : String)
    Info.new(MIME_MAGIC.file(filename), NONE_MAGIC.file(filename))
  end

  # Detect mime type, encoding and file type
  def self.detect(file : File)
    Info.new(MIME_MAGIC.descriptor(file), NONE_MAGIC.descriptor(file))
  end

  # Detect mime type, encoding and file type
  def self.detect(buffer : Bytes)
    Info.new(MIME_MAGIC.buffer(buffer), NONE_MAGIC.buffer(buffer))
  end

  # Returns the libmagic version
  def self.version
    LibMagic.magic_version
  end
end
