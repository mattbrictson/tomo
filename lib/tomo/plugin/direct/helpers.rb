# frozen_string_literal: true

require "shellwords"

module Tomo::Plugin::Direct
  module Helpers
    class << self
      attr_accessor :system_proc
    end
    self.system_proc = ->(cmd) { Kernel.system(cmd, exception: true) }

    def upload_archive(source_path:, destination_path:, exclusions:)
      tar_excludes = exclusions.map { |e| "--exclude=#{e.shellescape}" }.join(" ")
      local_tar = "COPYFILE_DISABLE=1 tar --no-xattrs -c -C #{source_path.shellescape} #{tar_excludes} ."
      remote_tar = "tar -x -C #{destination_path.to_s.shellescape}"
      ssh_args = ssh_args_for_pipe.shelljoin

      full_command = "#{local_tar} | #{ssh_args} #{remote_tar}"
      Tomo.logger.info("Streaming archive to #{destination_path}")
      Tomo.logger.debug(full_command)

      Helpers.system_proc.call(full_command) unless Tomo.dry_run?
    end
  end
end
