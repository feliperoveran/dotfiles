require 'rake'

desc 'Install dotfiles'
task :install do
  install_files(Dir.glob([
    "tmux.conf",
    "tmux",
    "vimrc",
    "vim",
    "bash_aliases",
    "git/*",
  ]))

  # symlink ./bin files to /usr/local/bin
  install_binaries(Dir.glob('bin/*'), '/usr/local/bin')

  install_prereqs

  install_fonts

  install_vim_plugins

  install_tmux_plugins
end

private

def install_vim_plugins
  system "vim -N \"+set hidden\" \"+syntax on\" +PlugInstall +qall"
end

def install_tmux_plugins
  system '~/.tmux/plugins/tpm/bin/install_plugins'
end

def install_files(files)
  files.each do |f|
    file_name = f.split('/').last
    source = "#{ENV["PWD"]}/#{f}"
    file = "#{ENV["HOME"]}/.#{file_name}"

    if File.exists?(file)
      puts "Moving #{file} to #{file}.bkp"
      run_command %{ mv #{file} #{file}.bkp }
    end

    run_command %{ ln -nfs "#{source}" "#{file}" }
  end
end

def install_binaries(files, destination)
  files.each do |f|
    source = "#{ENV['PWD']}/#{f}"
    target = "#{destination}/#{f.split('/').last}"

    run_command "sudo ln -nfs #{source} #{target}"
  end
end

def install_fonts
  puts "======================================================"
  puts "Installing patched fonts for Powerline/Lightline."
  puts "======================================================"
  run_command %{ mkdir -p ~/.fonts && cp ~/.dotfiles/fonts/* ~/.fonts && fc-cache -vf ~/.fonts }
  puts
end

def run_command(cmd)
  puts "running #{cmd}"
  system cmd
end

def install_prereqs
  run_command %{ ./ubuntu.sh }
end
