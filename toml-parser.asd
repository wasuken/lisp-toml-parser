(defsystem "toml-parser"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "toml-parser/tests"))))

(defsystem "toml-parser/tests"
  :author ""
  :license ""
  :depends-on ("toml-parser"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for toml-parser"
  :perform (test-op (op c) (symbol-call :rove :run c)))
