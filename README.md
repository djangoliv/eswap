# eswap
eswap-mode is a minor mode for toggling between src and target files
the mode just toggle path of the current buffer file

To use eswap-mode, make sure that this file is in Emacs load-path
    (add-to-list 'load-path "/path/to/directory/")

Then require eswap-mode
    (require 'eswap-mode)

To start eswap-mode
    (deswap-mode t) or M-x eswap-mode

eswap-mode is buffer local, so hook it up
    (add-hook 'python-mode-hook 'eswap-mode)

Or use the global mode to activate it in all buffers.

    (eswap-global-mode t)

eswap stores a list (`eswap-except-modes') of modes in
which `eswap-mode' should not be activated in (note, only if
you use the global mode) because of conflicting use.

You can add new except modes:
    (add-to-list 'eswap-except-modes 'conflicting-mode)

eswap-mode need to know about the path of your source and target files
please replace the path of the `eswap-toggle-path-alist' variable

    (setq eswap-toggle-path-alist ;; (srcPath . targetPath )
          (quote
          (("/path/to/root/of/project1/src/files" . "/path/to/root/of/project1/target/files")
          ("/path/to/root/of/project2/src/files" . "/path/to/root/of/project2/target/files")
          ;; ("" . "") ;;...
          )))

example:
    source path is /path/to/my/sourceDir/subdir1/subdir2/fileName
    target path is /path/to/my/targetDir/subdir1/subdir2/fileName
    (setq eswap-toggle-path-alist
          (quote
           (("/path/to/my/sourceDir" . "path/to/my/targetDir"))))
