require 'net/sftp/protocol/04/base'

module Net; module SFTP; module Protocol; module V05

  class Base < V04::Base

    F_CREATE_NEW         = 0x00000000
    F_CREATE_TRUNCATE    = 0x00000001
    F_OPEN_EXISTING      = 0x00000002
    F_OPEN_OR_CREATE     = 0x00000003
    F_TRUNCATE_EXISTING  = 0x00000004

    F_APPEND_DATA        = 0x00000008
    F_APPEND_DATA_ATOMIC = 0x00000010
    F_TEXT_MODE          = 0x00000020
    F_READ_LOCK          = 0x00000040
    F_WRITE_LOCK         = 0x00000080
    F_DELETE_LOCK        = 0x00000100

    module ACE
      F_READ_DATA         = 0x00000001
      F_LIST_DIRECTORY    = 0x00000001
      F_WRITE_DATA        = 0x00000002
      F_ADD_FILE          = 0x00000002
      F_APPEND_DATA       = 0x00000004
      F_ADD_SUBDIRECTORY  = 0x00000004
      F_READ_NAMED_ATTRS  = 0x00000008
      F_WRITE_NAMED_ATTRS = 0x00000010
      F_EXECUTE           = 0x00000020
      F_DELETE_CHILD      = 0x00000040
      F_READ_ATTRIBUTES   = 0x00000080
      F_WRITE_ATTRIBUTES  = 0x00000100
      F_DELETE            = 0x00010000
      F_READ_ACL          = 0x00020000
      F_WRITE_ACL         = 0x00040000
      F_WRITE_OWNER       = 0x00080000
      F_SYNCHRONIZE       = 0x00100000
    end

    def open(path, flags, options)
      flags = normalize_open_flags(flags)

      sftp_flags, desired_access = case
        when flags & IO::WRONLY != 0 then
          [ F_CREATE_TRUNCATE, ACE::F_WRITE_DATA | ACE::F_WRITE_ATTRIBUTES ]
        when flags & IO::RDWR != 0 then
          [ F_OPEN_OR_CREATE, ACE::F_READ_DATA | ACE::F_READ_ATTRIBUTES | ACE::F_WRITE_DATA | ACE::F_WRITE_ATTRIBUTES ]
        when flags & IO::APPEND != 0 then
          [ F_OPEN_OR_CREATE | F_APPEND_DATA, ACE::F_WRITE_DATA | ACE::F_WRITE_ATTRIBUTES | ACE::F_APPEND_DATA ]
        else
          [ F_OPEN_EXISTING, ACE::F_READ_DATA | ACE::F_READ_ATTRIBUTES ]
      end

      sftp_flags |= F_OPEN_OR_CREATE    if flags & IO::CREAT != 0
      sftp_flags |= F_TRUNCATE_EXISTING if flags & IO::TRUNC != 0

      attributes = attribute_factory.new(options)

      send_request(FXP_OPEN, :string, path, :long, desired_access, :long, sftp_flags, :raw, attributes)
    end

  end

end; end; end; end