msysdir = File.join(self.sandboxdir, package.msysdir)
directory File.dirname(msysdir)

file msysdir => [msys2_task.devtools, File.dirname(msysdir)] do |t|

  # find files that were created by msys2 initialization procedure
  init_files = File.readlines(msys2_task.after_init_filelist).map(&:chomp) - File.readlines(msys2_task.before_init_filelist).map(&:chomp)

  # Find all files to be copied
  # reject files that were created by msys2 initialization procedure
  cp_files = nil
  chdir msys2_task.sandboxdir do
    cp_files = Dir.glob("./**/*") - init_files
  end

  mkdir msysdir

  # Copy all files to the sandbox msys32 or msys64 directory
  cp_files.each do |fn|
    src = File.join(msys2_task.sandboxdir, fn)
    dst = File.join(t.name, fn)
    if File.directory?(src)
      mkdir_p dst
    else
      rm dst if File.exist?(dst)
      cp src, dst
    end
  end
end
self.sandboxfiles << msysdir
