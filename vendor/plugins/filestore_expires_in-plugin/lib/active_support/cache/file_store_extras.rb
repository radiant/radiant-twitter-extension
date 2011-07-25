
module ActiveSupport
  module Cache
    class FileStore < Store
       def read(name, options = nil)
         super
        file_name = real_file_path(name)
        expires = expires_in(options)

        if exist_without_instrument?(file_name, expires)
          File.open(file_name, 'rb') { |f| Marshal.load(f) }
        end
       end

       def exist?(name, options = nil)
         super
        File.exist?(real_file_path(name))
        exist_without_instrument?(real_file_path(name), expires_in(options))
       end

       def exist_without_instrument?(file_name, expires)
          File.exist?(file_name) && (expires <= 0 || Time.now - File.mtime(file_name) < expires)
       end
    end
  end    
end