(declare-project
 :name "hooker"
 :description "a hooker"
 :dependencies ["https://github.com/janet-lang/argparse.git"
                "https://github.com/janet-lang/spork.git"])

(declare-executable
 :name "hooker"
 :entry "main.janet"
 :lflags ["-static"])
