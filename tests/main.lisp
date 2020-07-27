(defpackage toml-parser/tests/main
  (:use :cl
        :toml-parser
        :rove))
(in-package :lisp-toml-parser/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :lisp-toml-parser)' in your Lisp.
(defun str-repeat (str len)
  (let ((result ""))
	(dotimes (n len)
	  (setf result (concatenate 'string result str)))
	result))

(defun hashmap-deep-format (tree &optional (deep 0))
  (maphash #'(lambda (k v)
			   (format t "~A~A => " (str-repeat (concatenate 'string '(#\Tab)) deep) k)
			   (cond ((hash-table-p v)
					  (format t "~A~%" (str-repeat (concatenate 'string '(#\Tab)) deep))
					  (hashmap-deep-format v (1+ deep)))
					 (t (format t "~A~%" v))))
		   tree))

(defun table-test (table expected)
  (let ((kv-lst '()))
	(maphash #'(lambda (k v)
				 (push (cons k v) kv-lst))
			 table)
	(is (reverse kv-lst)
		expected)))

(defun table-plist-test (table expected)
  (is (toml-parser:deep-hashtable-to-plist table)
	  expected))

(deftest table-test
	(testing "simple key-value test"
			 (table-plist-test (toml-parser:parse "test = \"test\"") '((|test| . "test")))
			 (table-plist-test (toml-parser:parse "test = \"te===st2\"
test2=1") '((|test| . "te===st2") (|test2| . 1)))
			 (table-plist-test (toml-parser:parse "sample = [1,2,3]")
							   '((|test| . "te===st2") (|test2| . 1) (|sample| 1 2 3)))
			 (table-plist-test (toml-parser:parse "sample2 = [[1,2,3],[4,5,6]]")
							   '((|test| . "te===st2") (|test2| . 1) (|sample| 1 2 3)
								 (|sample2| (1 2 3) (4 5 6))))
			 (table-plist-test (toml-parser:parse "sample4 = true sample5 = false")
							   '((|test| . "te===st2") (|test2| . 1) (|sample| 1 2 3)
								 (|sample2| (1 2 3) (4 5 6)) (|sample4| . T) (|sample5|)))
			 (table-plist-test (toml-parser:parse "sample6 = 2000-04-01 sample7 = [true, false]")
							   '((|test| . "te===st2") (|test2| . 1) (|sample| 1 2 3)
								 (|sample2| (1 2 3) (4 5 6)) (|sample4| . T) (|sample5|)
								 (|sample6| . "2000-04-01") (|sample7| T NIL)))
			 (toml-parser:toml-reset)
			 (table-plist-test (toml-parser:parse "test         =      1 test2      =       \"test\"          ")
							   '((|test| . 1) (|test2| . "test"))))
  (testing "table test"
		   (toml-parser:toml-reset)
		   (toml-parser:parse "[test] foo = 1 [hoge] bar = 2")
		   (is (toml-parser:toml-key-list)
			   '(|test| |hoge|))
		   (table-test (car (toml-parser:toml-value-list)) '((|foo| . 1)))
		   (table-test (nth 1 (toml-parser:toml-value-list)) '((|bar| . 2))))

  (testing "deep table test"
		   (toml-parser:toml-reset)
		   (toml-parser:parse "[test] foo = 1 [test.test] foo = 10")
		   (is (toml-parser:toml-key-list)
			   '(|test|)))
  )

(deftest errors
	(testing "error mechanism"
			 (is-error (toml-parser:parse "test ========= \"aa\"") 'simple-error)
			 (is-error (toml-parser:parse "i3qu0@34-0;wafioadkopew:k:pjpvnfprwfpewiefio") 'simple-error)
			 (is-error (toml-parser:parse "¥12]4]5[4¥322:12]:21:43:456:5765__89]890]0--jk]jy]re[3e]f") 'simple-error)
			 (is-error (toml-parser:parse "/mcxzjiof23489sadk:") 'simple-error)))
