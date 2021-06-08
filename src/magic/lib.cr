@[Link("magic")]
lib LibMagic
  type MagicT = Void*

  fun magic_open(x0 : LibC::Int) : MagicT

  fun magic_close(x0 : MagicT)
  fun magic_getpath(x0 : LibC::Char*, x1 : LibC::Int) : LibC::Char*
  fun magic_file(x0 : MagicT, x1 : LibC::Char*) : LibC::Char*
  fun magic_descriptor(x0 : MagicT, x1 : LibC::Int) : LibC::Char*
  fun magic_buffer(x0 : MagicT, x1 : Void*, x2 : LibC::SizeT) : LibC::Char*
  fun magic_error(x0 : MagicT) : LibC::Char*
  fun magic_getflags(x0 : MagicT) : LibC::Int
  fun magic_setflags(x0 : MagicT, x1 : LibC::Int) : LibC::Int
  fun magic_version : LibC::Int
  fun magic_load(x0 : MagicT, x1 : LibC::Char*) : LibC::Int
  fun magic_load_buffers(x0 : MagicT, x1 : Void**, x2 : LibC::SizeT*, x3 : LibC::SizeT) : LibC::Int
  fun magic_compile(x0 : MagicT, x1 : LibC::Char*) : LibC::Int
  fun magic_check(x0 : MagicT, x1 : LibC::Char*) : LibC::Int
  fun magic_list(x0 : MagicT, x1 : LibC::Char*) : LibC::Int
  fun magic_errno(x0 : MagicT) : LibC::Int
  fun magic_setparam(x0 : MagicT, x1 : LibC::Int, x2 : Void*) : LibC::Int
  fun magic_getparam(x0 : MagicT, x1 : LibC::Int, x2 : Void*) : LibC::Int
end
